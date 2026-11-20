const { prisma } = require('../prisma');
const { calculateOverallScore } = require('./adaptiveEngine.service');

/**
 * AI & Adaptive Recommendation Engine
 *
 * Provides personalized learning path recommendations, topic diagnostics,
 * and contextual mascot encouragement based on real performance evidence.
 */
async function getStudentRecommendations(studentId) {
  // 1. Fetch user profile
  const user = await prisma.user.findUnique({
    where: { id: studentId },
    select: { id: true, name: true, gradeClass: true, streak: true, iq: true },
  });

  if (!user) {
    throw new Error(`Student ${studentId} not found`);
  }

  // 2. Fetch all subject scores
  const subjectScores = await prisma.studentSubjectScore.findMany({
    where: { studentId },
    include: { subject: true },
    orderBy: { score: 'asc' }, // lowest score first
  });

  // 3. Fetch all topic masteries
  const topicMasteries = await prisma.studentTopicMastery.findMany({
    where: { studentId },
    include: {
      topic: {
        include: { subject: true },
      },
    },
    orderBy: { masteryValue: 'asc' }, // lowest mastery first
  });

  // 4. Calculate overall score
  const overallScore = await calculateOverallScore(studentId);

  // 5. Categorize topics into weak, developing, and mastered
  const weakTopics = [];
  const inProgressTopics = [];
  const masteredTopics = [];

  for (const m of topicMasteries) {
    const topicSummary = {
      topicId: m.topicId,
      topicName: m.topic.name,
      topicCode: m.topic.code,
      subjectName: m.topic.subject.name,
      masteryValue: m.masteryValue,
      evidenceCount: m.evidenceCount,
      currentDifficulty: m.currentDifficulty,
      lastPracticedAt: m.lastPracticedAt,
    };

    if (m.evidenceCount >= 3 && m.masteryValue < 55.0) {
      weakTopics.push(topicSummary);
    } else if (m.evidenceCount >= 5 && m.masteryValue >= 85.0) {
      masteredTopics.push(topicSummary);
    } else {
      inProgressTopics.push(topicSummary);
    }
  }

  // 6. Formulate Target Recommendation & Mascot Message
  let recommendedTopic = null;
  let recommendationType = 'explore';
  let mascotTitle = `Welcome Back, ${user.name}! 🚀`;
  let mascotMessage = 'Ready for today’s practice adventure? Let’s learn together!';
  let mascotEmoji = '🐘';

  if (weakTopics.length > 0) {
    // Top Priority: Remediate weak topic with supportive practice
    recommendedTopic = weakTopics[0];
    recommendationType = 'targeted_support';
    mascotTitle = `Let’s practice ${recommendedTopic.topicName}! 💡`;
    mascotMessage = `I noticed you encountered a few tricky questions in ${recommendedTopic.topicName}. A quick practice drill will sharpen your skills!`;
    mascotEmoji = '🎯';
  } else if (inProgressTopics.length > 0) {
    // In Progress: Continue building momentum
    recommendedTopic = inProgressTopics[0];
    recommendationType = 'continue_practice';
    mascotTitle = `Keep the Streak Going! 🔥`;
    mascotMessage = `You’re making great progress in ${recommendedTopic.topicName} (${recommendedTopic.masteryValue}% mastery). Let’s reach mastery today!`;
    mascotEmoji = '⭐';
  } else if (masteredTopics.length > 0) {
    // Mastered: Challenge or Level Up
    recommendedTopic = masteredTopics[0];
    recommendationType = 'challenge_review';
    mascotTitle = `Champion Status! 🏆`;
    mascotMessage = `You’ve mastered ${recommendedTopic.topicName}! Ready for an Expert challenge or a new subject?`;
    mascotEmoji = '👑';
  }

  return {
    studentId,
    overallScore,
    activeSubjectCount: subjectScores.length,
    subjects: subjectScores.map((s) => ({
      subjectId: s.subjectId,
      subjectName: s.subject.name,
      subjectCode: s.subject.code,
      score: s.score,
    })),
    topicBreakdown: {
      weak: weakTopics,
      inProgress: inProgressTopics,
      mastered: masteredTopics,
    },
    primaryRecommendation: {
      type: recommendationType,
      topic: recommendedTopic,
    },
    mascotSuggestion: {
      title: mascotTitle,
      message: mascotMessage,
      mascotEmoji,
      suggestedTopicId: recommendedTopic?.topicId || null,
      suggestedTopicName: recommendedTopic?.topicName || 'Mathematics',
    },
  };
}

module.exports = {
  getStudentRecommendations,
};

