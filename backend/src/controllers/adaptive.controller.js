const { prisma } = require('../prisma');
const { getNextQuestion } = require('../services/questionSelector.service');
const { processAttempt } = require('../services/scoringEngine.service');
const { getStudentRecommendations } = require('../services/recommendationEngine.service');
const { calculateOverallScore } = require('../services/adaptiveEngine.service');

/**
 * 0. Get All Adaptive Topics with Student Mastery
 * GET /api/v1/adaptive/topics
 */
exports.getTopics = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;

    const subjects = await prisma.adaptiveSubject.findMany({
      where: { isActive: true },
      include: {
        topics: {
          include: {
            masteries: {
              where: { studentId },
            },
          },
        },
      },
    });

    const formatted = subjects.map((sub) => ({
      subjectId: sub.id,
      subjectName: sub.name,
      subjectCode: sub.code,
      topics: sub.topics.map((t) => {
        const mastery = t.masteries[0];
        return {
          topicId: t.id,
          topicName: t.name,
          topicCode: t.code,
          grade: t.grade,
          masteryValue: mastery ? mastery.masteryValue : 0.0,
          currentDifficulty: mastery ? mastery.currentDifficulty : 'beginner',
          evidenceCount: mastery ? mastery.evidenceCount : 0,
        };
      }),
    }));

    res.status(200).json({
      success: true,
      data: formatted,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 1. Start a Practice Session (Section 10.4)
 * POST /api/v1/adaptive/sessions
 */
exports.startSession = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const { subjectId, topicId } = req.body;

    if (!topicId) {
      return res.status(400).json({ success: false, message: 'topicId is required' });
    }

    // Resolve subjectId from topic if not directly provided
    let resolvedSubjectId = subjectId;
    const topic = await prisma.adaptiveTopic.findUnique({
      where: { id: topicId },
      include: { subject: true },
    });

    if (!topic) {
      return res.status(404).json({ success: false, message: 'Topic not found' });
    }
    resolvedSubjectId = topic.subjectId;

    // Create session record
    const session = await prisma.learningSession.create({
      data: {
        studentId,
        subjectId: resolvedSubjectId,
        topicId,
        status: 'in_progress',
      },
    });

    // Ensure initial subject score exists
    let subjectScore = await prisma.studentSubjectScore.findUnique({
      where: {
        studentId_subjectId: { studentId, subjectId: resolvedSubjectId },
      },
    });

    if (!subjectScore) {
      subjectScore = await prisma.studentSubjectScore.create({
        data: {
          studentId,
          subjectId: resolvedSubjectId,
          score: 100, // Starts at 100 as per Section 1 & 4.1
        },
      });
    }

    // Get current topic mastery if exists
    const mastery = await prisma.studentTopicMastery.findUnique({
      where: {
        studentId_topicId: { studentId, topicId },
      },
    });

    const overallScore = await calculateOverallScore(studentId);

    res.status(201).json({
      success: true,
      data: {
        sessionId: session.id,
        subjectId: resolvedSubjectId,
        subjectName: topic.subject.name,
        topicId: topic.id,
        topicName: topic.name,
        subjectScore: subjectScore.score,
        overallScore,
        topicMastery: mastery ? mastery.masteryValue : 0.0,
        currentDifficulty: mastery ? mastery.currentDifficulty : 'beginner',
      },
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 2. Get Next Difficulty-Matched Question (Section 10.4 & 11)
 * GET /api/v1/adaptive/sessions/:sessionId/next-question
 */
exports.getNextSessionQuestion = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const { sessionId } = req.params;

    const session = await prisma.learningSession.findUnique({
      where: { id: sessionId },
    });

    if (!session || session.studentId !== studentId) {
      return res.status(404).json({ success: false, message: 'Session not found or unauthorized' });
    }

    // Enforce maximum 15 questions per adaptive quiz session
    const sessionAttemptsCount = await prisma.questionAttempt.count({
      where: { sessionId: session.id },
    });
    if (sessionAttemptsCount >= 15) {
      return res.status(200).json({
        success: true,
        isTopicMastered: true,
        isSessionComplete: true,
        message: 'You have completed all 15 questions for this adaptive quiz session!',
        data: null,
      });
    }

    const result = await getNextQuestion({
      studentId,
      topicId: session.topicId,
      grade: req.user.gradeClass ? parseInt(req.user.gradeClass.replace(/\D/g, '')) || 3 : 3,
    });

    if (!result.success) {
      return res.status(404).json(result);
    }

    if (result.isTopicMastered) {
      return res.status(200).json({
        success: true,
        isTopicMastered: true,
        message: result.message,
        data: null,
      });
    }

    res.status(200).json({
      success: true,
      data: result.question,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 3. Submit an Answer (Section 8.3 & 10.4)
 * POST /api/v1/adaptive/attempts
 */
exports.submitAttempt = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const {
      sessionId,
      questionId,
      submissionId,
      selectedAnswer,
      hintsUsed = 0,
      durationSeconds = 0,
    } = req.body;

    if (!questionId || !submissionId || selectedAnswer === undefined) {
      return res.status(400).json({
        success: false,
        message: 'questionId, submissionId, and selectedAnswer are required',
      });
    }

    const result = await processAttempt({
      studentId,
      sessionId,
      questionId,
      submissionId,
      selectedAnswer,
      hintsUsed,
      durationSeconds,
    });

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 4. Get Student Progress & Recommendations Dashboard (Section 10.4)
 * GET /api/v1/adaptive/progress
 */
exports.getProgressDashboard = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const recommendations = await getStudentRecommendations(studentId);

    res.status(200).json({
      success: true,
      data: recommendations,
    });
  } catch (err) {
    next(err);
  }
};

