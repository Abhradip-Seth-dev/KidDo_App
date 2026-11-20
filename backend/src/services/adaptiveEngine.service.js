const { prisma } = require('../prisma');

const DIFFICULTY_LEVELS = ['beginner', 'intermediate', 'expert'];

const DEFAULT_SCORING_RULES = {
  beginner: { correct: 5, incorrect: -2, hintPenalty: 1 },
  intermediate: { correct: 10, incorrect: -5, hintPenalty: 1 },
  expert: { correct: 15, incorrect: -8, hintPenalty: 2 },
};

/**
 * Evaluates the next difficulty level for a student in a specific topic
 * using the sliding 5-attempt evidence window (Section 4.4 & 8.4).
 *
 * Rules:
 *  - 4-5 correct: consider moving up one level
 *  - 2-3 correct: keep current difficulty
 *  - 0-1 correct: consider moving down and flag for support
 *  - Clamped between beginner and expert
 */
async function evaluateDifficulty(studentId, topicId) {
  // Fetch mastery state to know current difficulty
  const mastery = await prisma.studentTopicMastery.findUnique({
    where: {
      studentId_topicId: { studentId, topicId },
    },
  });

  const currentDifficulty = mastery?.currentDifficulty || 'beginner';

  // Fetch last 5 valid attempts for this topic
  const recentAttempts = await prisma.questionAttempt.findMany({
    where: {
      studentId,
      question: { topicId },
    },
    orderBy: { submittedAt: 'desc' },
    take: 5,
    select: { isCorrect: true, hintsUsed: true, durationSeconds: true },
  });

  // Need at least 5 attempts to adjust difficulty
  if (recentAttempts.length < 5) {
    return {
      currentDifficulty,
      recommendedDifficulty: currentDifficulty,
      difficultyChanged: false,
      reason: 'insufficient_evidence_for_difficulty_change',
      recentCount: recentAttempts.length,
      needsSupport: false,
    };
  }

  const correctCount = recentAttempts.filter((a) => a.isCorrect).length;
  let recommendedDifficulty = currentDifficulty;
  let needsSupport = false;

  if (correctCount >= 4) {
    // Level up
    if (currentDifficulty === 'beginner') {
      recommendedDifficulty = 'intermediate';
    } else if (currentDifficulty === 'intermediate') {
      recommendedDifficulty = 'expert';
    }
  } else if (correctCount <= 1) {
    // Level down & offer support
    needsSupport = true;
    if (currentDifficulty === 'expert') {
      recommendedDifficulty = 'intermediate';
    } else if (currentDifficulty === 'intermediate') {
      recommendedDifficulty = 'beginner';
    }
  }

  const difficultyChanged = recommendedDifficulty !== currentDifficulty;

  return {
    currentDifficulty,
    recommendedDifficulty,
    difficultyChanged,
    correctCount,
    recentCount: recentAttempts.length,
    needsSupport,
  };
}

/**
 * Calculates topic mastery percentage (0-100%) using weighted recent accuracy
 * with a minimum evidence safeguard (Section 4.3 & 9.2).
 */
async function calculateMastery(studentId, topicId) {
  const attempts = await prisma.questionAttempt.findMany({
    where: {
      studentId,
      question: { topicId },
    },
    orderBy: { submittedAt: 'desc' },
    take: 10,
    select: { isCorrect: true, hintsUsed: true, submittedAt: true },
  });

  const evidenceCount = attempts.length;

  // Safeguard: under 3 attempts is insufficient evidence
  if (evidenceCount < 3) {
    return {
      masteryValue: 0.0,
      evidenceCount,
      hasSufficientEvidence: false,
      status: 'insufficient_evidence',
      label: 'Collecting practice data...',
    };
  }

  // Weights decaying from recent to older (attempts are sorted newest first)
  const weights = [1.5, 1.4, 1.3, 1.2, 1.1, 1.0, 1.0, 0.9, 0.8, 0.7];
  let totalWeight = 0;
  let weightedScore = 0;

  for (let i = 0; i < attempts.length; i++) {
    const w = weights[i] || 0.5;
    totalWeight += w;
    if (attempts[i].isCorrect) {
      // Slight deduction if hints were heavily used
      const hintPenaltyRatio = Math.max(0.7, 1.0 - (attempts[i].hintsUsed * 0.1));
      weightedScore += w * hintPenaltyRatio;
    }
  }

  const masteryValue = Number(((weightedScore / totalWeight) * 100).toFixed(1));
  const clampedMastery = Math.min(100.0, Math.max(0.0, masteryValue));

  let status = 'in_progress';
  let label = 'Practicing';
  if (clampedMastery >= 85.0 && evidenceCount >= 5) {
    status = 'mastered';
    label = 'Mastered 🏆';
  } else if (clampedMastery < 50.0) {
    status = 'needs_practice';
    label = 'Needs Support 💡';
  }

  return {
    masteryValue: clampedMastery,
    evidenceCount,
    hasSufficientEvidence: true,
    status,
    label,
  };
}

/**
 * Calculates overall score as average of active subject scores (Section 4.1).
 */
async function calculateOverallScore(studentId) {
  const subjectScores = await prisma.studentSubjectScore.findMany({
    where: { studentId },
    select: { score: true },
  });

  if (!subjectScores || subjectScores.length === 0) {
    return 100;
  }

  const total = subjectScores.reduce((sum, item) => sum + item.score, 0);
  return Math.round(total / subjectScores.length);
}

module.exports = {
  DIFFICULTY_LEVELS,
  DEFAULT_SCORING_RULES,
  evaluateDifficulty,
  calculateMastery,
  calculateOverallScore,
};

