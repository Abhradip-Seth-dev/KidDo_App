const { prisma } = require('../prisma');
const aiEngine = require('../services/aiEngineGateway.service');
const { getNextQuestion } = require('../services/questionSelector.service');
const { processAttempt } = require('../services/scoringEngine.service');
const { getStudentRecommendations } = require('../services/recommendationEngine.service');
const { calculateOverallScore } = require('../services/adaptiveEngine.service');

// Helper to normalize subject codes between Node and FastAPI
function normalizeSubjectCode(code = '') {
  const c = code.toUpperCase();
  if (c.includes('MATH')) return 'MATH';
  if (c.includes('ENG')) return 'ENGLISH';
  if (c.includes('COMP')) return 'COMPUTER';
  if (c.includes('GK') || c.includes('GENERAL')) return 'GK';
  if (c.includes('SCI')) return 'SCIENCE';
  return c;
}

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
 * 1. Start a Practice Session (Gateway to Python FastAPI)
 * POST /api/v1/adaptive/sessions
 */
exports.startSession = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const { subjectId, topicId } = req.body;

    if (!topicId) {
      return res.status(400).json({ success: false, message: 'topicId is required' });
    }

    // Resolve topic & subject details from Prisma
    let topic = await prisma.adaptiveTopic.findUnique({
      where: { id: topicId },
      include: { subject: true },
    });

    // If not found by UUID, try lookup by code
    if (!topic) {
      topic = await prisma.adaptiveTopic.findFirst({
        where: { code: topicId },
        include: { subject: true },
      });
    }

    const subjectCode = topic ? normalizeSubjectCode(topic.subject?.code) : 'MATH';
    const topicCode = topic ? topic.code : topicId;

    // ── Try Gateway to Python FastAPI AI Engine ─────────────────────────────
    const isAiAvailable = await aiEngine.checkHealth();
    if (isAiAvailable) {
      try {
        const aiSession = await aiEngine.startSession({
          studentId,
          subjectCode,
          topicCode,
        });

        return res.status(201).json({
          success: true,
          gateway: 'python-fastapi',
          data: {
            sessionId: aiSession.session_id,
            subjectId: topic?.subjectId || subjectId,
            subjectName: topic?.subject?.name || aiSession.subject_code,
            topicId: topic?.id || topicId,
            topicName: topic?.name || aiSession.topic_code,
            subjectScore: aiSession.subject_score,
            overallScore: aiSession.overall_score,
            topicMastery: aiSession.topic_mastery || 0.0,
            currentDifficulty: aiSession.current_difficulty,
          },
        });
      } catch (gatewayErr) {
        console.warn('⚠️ Python AI Engine session start failed, falling back to Node service:', gatewayErr.message);
      }
    }

    // ── Fallback: Local Node.js / Prisma logic ──────────────────────────────
    if (!topic) {
      return res.status(404).json({ success: false, message: 'Topic not found' });
    }
    const resolvedSubjectId = topic.subjectId;

    const session = await prisma.learningSession.create({
      data: {
        studentId,
        subjectId: resolvedSubjectId,
        topicId: topic.id,
        status: 'in_progress',
      },
    });

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
          score: 100,
        },
      });
    }

    const mastery = await prisma.studentTopicMastery.findUnique({
      where: {
        studentId_topicId: { studentId, topicId: topic.id },
      },
    });

    const overallScore = await calculateOverallScore(studentId);

    res.status(201).json({
      success: true,
      gateway: 'node-fallback',
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
 * 2. Get Next Difficulty-Matched Question (Gateway to Python FastAPI)
 * GET /api/v1/adaptive/sessions/:sessionId/next-question
 */
exports.getNextSessionQuestion = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;
    const { sessionId } = req.params;

    // ── Try Gateway to Python FastAPI AI Engine ─────────────────────────────
    const isAiAvailable = await aiEngine.checkHealth();
    if (isAiAvailable) {
      try {
        const aiQuestion = await aiEngine.getNextQuestion(sessionId);

        if (aiQuestion?.isTopicMastered) {
          return res.status(200).json({
            success: true,
            isTopicMastered: true,
            message: aiQuestion.message,
            data: null,
          });
        }

        if (aiQuestion && aiQuestion.content) {
          return res.status(200).json({
            success: true,
            gateway: 'python-fastapi',
            data: {
              questionId: aiQuestion.question_db_id || aiQuestion.question_id,
              prompt: aiQuestion.content.question,
              options: aiQuestion.content.options,
              mediaUrl: aiQuestion.content.media_url,
              difficulty: aiQuestion.difficulty,
              questionType: aiQuestion.question_type,
              availableHints: aiQuestion.available_hints,
            },
          });
        }
      } catch (gatewayErr) {
        console.warn('⚠️ Python AI Engine getNextQuestion failed, falling back to Node service:', gatewayErr.message);
      }
    }

    // ── Fallback: Local Node.js / Prisma logic ──────────────────────────────
    const session = await prisma.learningSession.findUnique({
      where: { id: sessionId },
    });

    if (!session || session.studentId !== studentId) {
      return res.status(404).json({ success: false, message: 'Session not found or unauthorized' });
    }

    const sessionAttemptsCount = await prisma.questionAttempt.count({
      where: { sessionId: session.id },
    });
    if (sessionAttemptsCount >= 15) {
      await prisma.learningSession.update({
        where: { id: sessionId },
        data: { status: 'completed', endedAt: new Date() },
      });

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
      gateway: 'node-fallback',
      data: result.question,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 3. Submit an Answer (Gateway to Python FastAPI)
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

    // ── Try Gateway to Python FastAPI AI Engine ─────────────────────────────
    const isAiAvailable = await aiEngine.checkHealth();
    if (isAiAvailable) {
      try {
        const parsedQuestionId = typeof questionId === 'number' ? questionId : parseInt(questionId) || 1;
        const aiResult = await aiEngine.submitAttempt({
          sessionId,
          questionDbId: parsedQuestionId,
          submissionId,
          selectedAnswer,
          hintsUsed,
          timeTakenSeconds: durationSeconds,
        });

        // Gamification in Node/PostgreSQL: award coins and IQ when correct
        if (aiResult.is_correct) {
          await prisma.user.update({
            where: { id: studentId },
            data: {
              coins: { increment: 2 },
              iq: { increment: aiResult.score?.points_change || 10 },
            },
          }).catch(() => {});
        }

        return res.status(200).json({
          success: true,
          gateway: 'python-fastapi',
          data: {
            attemptId: aiResult.attempt_id,
            isCorrect: aiResult.is_correct,
            score: {
              pointsChange: aiResult.score?.points_change,
              subjectScore: aiResult.score?.subject_score,
              overallScore: aiResult.score?.overall_score,
            },
            progress: {
              topicMastery: aiResult.progress?.topic_mastery,
              masteryLabel: aiResult.progress?.mastery_label,
              currentDifficulty: aiResult.progress?.current_difficulty,
              recommendedDifficulty: aiResult.progress?.recommended_difficulty,
              difficultyChanged:
                aiResult.progress?.current_difficulty !== aiResult.progress?.recommended_difficulty,
            },
            feedback: {
              message: aiResult.feedback?.message,
              explanation: aiResult.feedback?.explanation,
            },
          },
        });
      } catch (gatewayErr) {
        console.warn('⚠️ Python AI Engine submitAttempt failed, falling back to Node service:', gatewayErr.message);
      }
    }

    // ── Fallback: Local Node.js / Prisma logic ──────────────────────────────
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
      gateway: 'node-fallback',
      data: result,
    });
  } catch (err) {
    next(err);
  }
};

/**
 * 4. Get Student Progress & Recommendations Dashboard (Gateway to Python FastAPI)
 * GET /api/v1/adaptive/progress
 */
exports.getProgressDashboard = async (req, res, next) => {
  try {
    const studentId = req.user.id || req.user._id;

    const isAiAvailable = await aiEngine.checkHealth();
    if (isAiAvailable) {
      try {
        const aiProgress = await aiEngine.getStudentProgress(studentId);
        return res.status(200).json({
          success: true,
          gateway: 'python-fastapi',
          data: aiProgress,
        });
      } catch (gatewayErr) {
        console.warn('⚠️ Python AI Engine getStudentProgress failed, falling back to Node service:', gatewayErr.message);
      }
    }

    // Fallback to Node.js recommendation engine
    const recommendations = await getStudentRecommendations(studentId);
    res.status(200).json({
      success: true,
      gateway: 'node-fallback',
      data: recommendations,
    });
  } catch (err) {
    next(err);
  }
};
