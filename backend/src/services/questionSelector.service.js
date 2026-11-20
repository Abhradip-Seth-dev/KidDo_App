const { prisma } = require('../prisma');

/**
 * Controlled Random Question Selector with Anti-Repetition (Section 11)
 *
 * Rules:
 *  1. Filter by grade, topic, status='published', and current difficulty.
 *  2. Exclude the student's last 10 attempts in this topic to avoid immediate repetition.
 *  3. Randomly select from remaining candidates.
 *  4. Fall back safely to older questions if pool is exhausted.
 *  5. Never include answerKey in client payload!
 */
async function getNextQuestion({ studentId, topicId, grade = 3 }) {
  // 1. Get or initialize student's topic mastery / current difficulty
  let mastery = await prisma.studentTopicMastery.findUnique({
    where: {
      studentId_topicId: { studentId, topicId },
    },
  });

  const currentDifficulty = mastery?.currentDifficulty || 'beginner';

  // 2. Fetch recent attempt question IDs in this topic (last 10 lookback)
  const recentAttempts = await prisma.questionAttempt.findMany({
    where: {
      studentId,
      question: { topicId },
    },
    orderBy: { submittedAt: 'desc' },
    take: 10,
    select: { questionId: true },
  });

  const recentQuestionIds = recentAttempts.map((a) => a.questionId);

  // 3. Query eligible questions matching topic and difficulty, excluding recent
  let candidates = await prisma.adaptiveQuestion.findMany({
    where: {
      topicId,
      grade,
      difficulty: currentDifficulty,
      status: 'published',
      id: { notIn: recentQuestionIds },
    },
  });

  let isRevisionFallback = false;

  // 4. Check if student has already mastered this topic at Expert level
  if (currentDifficulty === 'expert' && (mastery?.masteryValue || 0) >= 99.0) {
    if (candidates.length === 0 || recentAttempts.length >= 3) {
      return {
        success: true,
        isTopicMastered: true,
        message: 'Congratulations! You have reached 100% mastery at the Expert tier for this topic!',
        question: null,
      };
    }
  }

  // 5. Fallback if pool is exhausted for this difficulty
  if (candidates.length === 0) {
    // Attempt fallback: allow any published question in this topic and difficulty
    candidates = await prisma.adaptiveQuestion.findMany({
      where: {
        topicId,
        grade,
        difficulty: currentDifficulty,
        status: 'published',
      },
    });

    if (candidates.length > 0) {
      isRevisionFallback = true;
    } else {
      // If still zero, try adjacent difficulty or report pool exhausted
      candidates = await prisma.adaptiveQuestion.findMany({
        where: {
          topicId,
          grade,
          status: 'published',
        },
      });
      isRevisionFallback = true;
    }
  }

  if (candidates.length === 0) {
    return {
      success: false,
      error: 'QUESTION_POOL_EXHAUSTED',
      message: 'No published questions available for this topic and grade.',
    };
  }

  // 5. Controlled random pick
  const randomIndex = Math.floor(Math.random() * candidates.length);
  const selectedQuestion = candidates[randomIndex];

  // 6. Parse and sanitize question payload (NEVER LEAK answerKey!)
  const rawContent = typeof selectedQuestion.content === 'string'
    ? JSON.parse(selectedQuestion.content)
    : selectedQuestion.content;

  const rawAnswerKey = typeof selectedQuestion.answerKey === 'string'
    ? JSON.parse(selectedQuestion.answerKey)
    : selectedQuestion.answerKey;

  const hints = Array.isArray(rawAnswerKey?.hints) ? rawAnswerKey.hints : [];

  // Shuffle options order if multiple choice, keeping option_ids intact
  let sanitizedOptions = rawContent?.options || [];
  if (Array.isArray(sanitizedOptions) && sanitizedOptions.length > 1) {
    sanitizedOptions = [...sanitizedOptions].sort(() => Math.random() - 0.5);
  }

  return {
    success: true,
    question: {
      questionId: selectedQuestion.id,
      grade: selectedQuestion.grade,
      topicId: selectedQuestion.topicId,
      difficulty: selectedQuestion.difficulty,
      questionType: selectedQuestion.questionType,
      prompt: rawContent?.question || rawContent?.prompt,
      media: rawContent?.media || null,
      options: sanitizedOptions,
      availableHintsCount: hints.length,
      availableHints: hints, // hints are safe to show if student requests them
      isRevisionFallback,
    },
  };
}

module.exports = {
  getNextQuestion,
};

