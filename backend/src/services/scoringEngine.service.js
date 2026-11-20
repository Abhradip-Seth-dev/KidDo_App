const { prisma } = require('../prisma');
const {
  DEFAULT_SCORING_RULES,
  evaluateDifficulty,
  calculateMastery,
  calculateOverallScore,
} = require('./adaptiveEngine.service');

/**
 * Evaluates student answer submission, commits audit score transaction,
 * updates topic mastery and difficulty progression (Sections 8.3, 9.1 & 10.4).
 */
async function processAttempt({
  studentId,
  sessionId,
  questionId,
  submissionId,
  selectedAnswer,
  hintsUsed = 0,
  durationSeconds = 0,
}) {
  // 1. Idempotency Check: if submission was already processed, return previous record
  const existingAttempt = await prisma.questionAttempt.findUnique({
    where: { submissionId },
    include: {
      scoreTransaction: true,
      question: {
        include: { topic: { include: { subject: true } } },
      },
    },
  });

  if (existingAttempt) {
    const rawAnswerKey = typeof existingAttempt.question.answerKey === 'string'
      ? JSON.parse(existingAttempt.question.answerKey)
      : existingAttempt.question.answerKey;

    const subjectScore = await prisma.studentSubjectScore.findUnique({
      where: {
        studentId_subjectId: {
          studentId,
          subjectId: existingAttempt.question.topic.subjectId,
        },
      },
    });

    const mastery = await prisma.studentTopicMastery.findUnique({
      where: {
        studentId_topicId: {
          studentId,
          topicId: existingAttempt.question.topicId,
        },
      },
    });

    const overallScore = await calculateOverallScore(studentId);

    return {
      isDuplicateSubmission: true,
      attemptId: existingAttempt.id,
      isCorrect: existingAttempt.isCorrect,
      feedback: {
        message: existingAttempt.isCorrect ? 'Correct! (Cached)' : 'Incorrect (Cached)',
        explanation: rawAnswerKey?.explanation || '',
      },
      score: {
        pointsChange: existingAttempt.scoreTransaction?.pointsChange || 0,
        subjectScore: subjectScore?.score || 100,
        overallScore,
      },
      progress: {
        topicMastery: mastery?.masteryValue || 0.0,
        currentDifficulty: mastery?.currentDifficulty || 'beginner',
        recommendedDifficulty: mastery?.currentDifficulty || 'beginner',
      },
    };
  }

  // 2. Fetch the question with private answerKey
  const question = await prisma.adaptiveQuestion.findUnique({
    where: { id: questionId },
    include: { topic: { include: { subject: true } } },
  });

  if (!question) {
    throw new Error(`Question ${questionId} not found`);
  }

  const subjectId = question.topic.subjectId;
  const topicId = question.topicId;
  const difficulty = question.difficulty || 'beginner';

  const rawAnswerKey = typeof question.answerKey === 'string'
    ? JSON.parse(question.answerKey)
    : question.answerKey;

  // 3. Evaluate answer
  let isCorrect = false;
  const selectedOptionId = selectedAnswer?.option_id || selectedAnswer?.selectedOptionId || selectedAnswer;
  const correctOptionId = rawAnswerKey?.correct_option_id || rawAnswerKey?.correctAnswer;

  if (question.questionType === 'multiple_choice' || question.questionType === 'true_false') {
    isCorrect = String(selectedOptionId).trim().toUpperCase() === String(correctOptionId).trim().toUpperCase();
  } else {
    // General fallback comparison
    isCorrect = JSON.stringify(selectedAnswer) === JSON.stringify(rawAnswerKey?.correctAnswer);
  }

  // 4. Calculate Points using active rules & hint penalties
  const rule = DEFAULT_SCORING_RULES[difficulty] || DEFAULT_SCORING_RULES.beginner;
  let pointsChange = 0;

  if (isCorrect) {
    let earned = rule.correct;
    // Hint deduction (if any)
    if (hintsUsed > 0) {
      earned = Math.max(1, earned - (hintsUsed * rule.hintPenalty));
    }
    pointsChange = earned;
  } else {
    pointsChange = rule.incorrect; // negative points, e.g. -2, -5, -8
  }

  // 5. Run atomic transaction for attempt, score, mastery, and user rewards
  const transactionResult = await prisma.$transaction(async (tx) => {
    // 5a. Record Question Attempt
    const attempt = await tx.questionAttempt.create({
      data: {
        submissionId,
        sessionId: sessionId || null,
        studentId,
        questionId,
        questionVersion: question.contentVersion,
        selectedAnswer: typeof selectedAnswer === 'object' ? selectedAnswer : { value: selectedAnswer },
        isCorrect,
        hintsUsed,
        durationSeconds,
      },
    });

    // 5b. Update or initialize Subject Score
    let subjectScoreRecord = await tx.studentSubjectScore.findUnique({
      where: {
        studentId_subjectId: { studentId, subjectId },
      },
    });

    const currentScore = subjectScoreRecord ? subjectScoreRecord.score : 100;
    const newScore = Math.max(0, currentScore + pointsChange); // clamp score >= 0

    if (subjectScoreRecord) {
      subjectScoreRecord = await tx.studentSubjectScore.update({
        where: { id: subjectScoreRecord.id },
        data: { score: newScore },
      });
    } else {
      subjectScoreRecord = await tx.studentSubjectScore.create({
        data: {
          studentId,
          subjectId,
          score: newScore,
        },
      });
    }

    // 5c. Record immutable Score Transaction
    const reason = isCorrect
      ? `correct_${difficulty}_answer`
      : `incorrect_${difficulty}_answer`;

    const scoreTx = await tx.scoreTransaction.create({
      data: {
        studentId,
        subjectId,
        attemptId: attempt.id,
        pointsChange,
        scoreAfter: newScore,
        reason,
        scoringRuleVersion: 1,
      },
    });

    // 5d. Update User Gamification (IQ, Coins, Streak)
    const user = await tx.user.findUnique({ where: { id: studentId } });
    if (user) {
      const iqDelta = isCorrect ? (pointsChange * 2) : 0;
      const coinDelta = isCorrect ? 5 : 0;
      const newStreak = isCorrect ? user.streak + 1 : 0;
      const longestStreak = Math.max(user.longestStreak, newStreak);

      await tx.user.update({
        where: { id: studentId },
        data: {
          iq: Math.max(0, user.iq + iqDelta),
          coins: user.coins + coinDelta,
          streak: newStreak,
          longestStreak,
          totalQuizzesCompleted: user.totalQuizzesCompleted + 1,
        },
      });
    }

    return { attempt, subjectScore: newScore, scoreTx };
  });

  // 6. Recalculate Mastery & Evaluate Adaptive Progression for Topic
  const masteryData = await calculateMastery(studentId, topicId);
  const adaptiveDecision = await evaluateDifficulty(studentId, topicId);

  // Update StudentTopicMastery in DB
  await prisma.studentTopicMastery.upsert({
    where: {
      studentId_topicId: { studentId, topicId },
    },
    update: {
      masteryValue: masteryData.masteryValue,
      evidenceCount: masteryData.evidenceCount,
      currentDifficulty: adaptiveDecision.recommendedDifficulty,
      lastPracticedAt: new Date(),
    },
    create: {
      studentId,
      topicId,
      masteryValue: masteryData.masteryValue,
      evidenceCount: masteryData.evidenceCount,
      currentDifficulty: adaptiveDecision.recommendedDifficulty,
      lastPracticedAt: new Date(),
    },
  });

  const overallScore = await calculateOverallScore(studentId);

  return {
    isDuplicateSubmission: false,
    attemptId: transactionResult.attempt.id,
    isCorrect,
    feedback: {
      message: isCorrect ? 'Great work! Outstanding!' : 'Nice try! Keep going!',
      explanation: rawAnswerKey?.explanation || 'Review the topic steps to master this question.',
    },
    score: {
      pointsChange,
      subjectScore: transactionResult.subjectScore,
      overallScore,
    },
    progress: {
      topicMastery: masteryData.masteryValue,
      masteryStatus: masteryData.status,
      masteryLabel: masteryData.label,
      currentDifficulty: difficulty,
      recommendedDifficulty: adaptiveDecision.recommendedDifficulty,
      difficultyChanged: adaptiveDecision.difficultyChanged,
      needsSupport: adaptiveDecision.needsSupport,
    },
  };
}

module.exports = {
  processAttempt,
};

