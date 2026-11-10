const { validationResult } = require('express-validator');
const { prisma, formatDoc } = require('../prisma');

// Helper to extract numeric quiz number from string like "Quiz 1: Count to 5" or "Quiz 10"
function parseQuizNumber(quizName) {
  if (!quizName) return 0;
  const match = quizName.match(/Quiz\s+(\d+)/i);
  return match ? parseInt(match[1], 10) : 0;
}

function getQuizStars(completedQuizzes, subject, unitNumber, quizName) {
  if (!Array.isArray(completedQuizzes)) return 0;
  const match = completedQuizzes.find(
    (q) => q.subject === subject && q.unitNumber === unitNumber && q.quizName === quizName
  );
  return match ? match.stars : 0;
}

// ── GET /api/quiz/units?subject=Math ──────────────────────────────────────────
exports.getUnits = async (req, res, next) => {
  try {
    const { subject } = req.query;
    const validSubjects = ['Math', 'GK', 'English', 'Computer', 'Science'];

    if (!subject || !validSubjects.includes(subject)) {
      return res.status(400).json({
        success: false,
        message: `subject query param required. Valid: ${validSubjects.join(', ')}`,
      });
    }

    const questions = await prisma.quizQuestion.findMany({
      where: { subject },
      select: { unitNumber: true, unitName: true, quizName: true },
    });

    // Group questions by unitNumber, then by quizName
    const unitsMap = new Map();
    for (const q of questions) {
      if (!unitsMap.has(q.unitNumber)) {
        unitsMap.set(q.unitNumber, {
          unitNumber: q.unitNumber,
          unitName: q.unitName,
          quizzesMap: new Map(),
        });
      }
      const u = unitsMap.get(q.unitNumber);
      if (!u.quizzesMap.has(q.quizName)) {
        u.quizzesMap.set(q.quizName, 0);
      }
      u.quizzesMap.set(q.quizName, u.quizzesMap.get(q.quizName) + 1);
    }

    const units = Array.from(unitsMap.values()).map((u) => ({
      unitNumber: u.unitNumber,
      unitName: u.unitName,
      quizzes: Array.from(u.quizzesMap.entries()).map(([quizName, questionCount]) => ({
        quizName,
        questionCount,
      })),
    }));

    units.sort((a, b) => a.unitNumber - b.unitNumber);

    const user = req.user;
    const userCompletedQuizzes = Array.isArray(user.completedQuizzes)
      ? user.completedQuizzes
      : (typeof user.completedQuizzes === 'string' ? JSON.parse(user.completedQuizzes || '[]') : []);

    let foundCurrent = false;

    const unitsWithProgress = units.map((unit) => {
      unit.quizzes.sort((a, b) => parseQuizNumber(a.quizName) - parseQuizNumber(b.quizName));

      let unitCompletedCount = 0;

      const quizzesWithProgress = unit.quizzes.map((quiz) => {
        const stars = getQuizStars(userCompletedQuizzes, subject, unit.unitNumber, quiz.quizName);
        const completed = stars > 0;
        if (completed) unitCompletedCount++;

        let status = 'locked';
        if (completed) {
          status = 'completed';
        } else if (!foundCurrent) {
          status = 'current';
          foundCurrent = true;
        }

        return {
          quizName: quiz.quizName,
          questionCount: quiz.questionCount,
          stars,
          completed,
          status,
        };
      });

      let unitStatus = 'locked';
      if (unitCompletedCount === unit.quizzes.length && unit.quizzes.length > 0) {
        unitStatus = 'completed';
      } else if (quizzesWithProgress.some((q) => q.status === 'current' || q.status === 'completed')) {
        unitStatus = 'current';
      }

      return {
        unitNumber: unit.unitNumber,
        unitName: unit.unitName,
        status: unitStatus,
        quizzes: quizzesWithProgress,
      };
    });

    res.status(200).json({
      success: true,
      subject,
      units: unitsWithProgress,
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/quiz/questions?subject=Math&unit=1&quiz=Quiz+1 ────────────────────
exports.getQuestions = async (req, res, next) => {
  try {
    const { subject, unit, quiz } = req.query;
    const validSubjects = ['Math', 'GK', 'English', 'Computer', 'Science'];

    if (!subject || !validSubjects.includes(subject)) {
      return res.status(400).json({ success: false, message: 'Valid subject required' });
    }

    const filter = { subject };
    if (unit) filter.unitNumber = parseInt(unit, 10);
    if (quiz) filter.quizName = quiz;

    let questions;
    if (!unit && !quiz) {
      const all = await prisma.quizQuestion.findMany({ where: filter });
      questions = all.sort(() => 0.5 - Math.random()).slice(0, 5);
    } else {
      questions = await prisma.quizQuestion.findMany({
        where: filter,
        orderBy: { createdAt: 'asc' },
      });
    }

    if (questions.length === 0) {
      return res.status(404).json({
        success: false,
        message: `No questions found for subject ${subject}`,
      });
    }

    res.status(200).json({ success: true, count: questions.length, questions: formatDoc(questions) });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/quiz/submit ──────────────────────────────────────────────────────
exports.submitAttempt = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { subject, unitNumber, quizName, correctCount, totalQuestions } = req.body;
    const userId = req.user.id || req.user._id;

    const percentage = Math.round((correctCount / totalQuestions) * 100);

    let stars = 1;
    if (percentage >= 90) stars = 3;
    else if (percentage >= 60) stars = 2;

    const baseIq = stars * 10;
    const coinsEarned = stars * 5;

    const config = await prisma.systemConfig.findUnique({ where: { key: 'global_settings' } });
    const multiplier = config ? (config.doubleXpEnabled ? 2.0 : (config.baseXpMultiplier || 1.0)) : 1.0;
    const iqEarned = Math.round(baseIq * multiplier);

    // Save attempt log
    await prisma.quizAttempt.create({
      data: {
        userId,
        subject,
        score: percentage,
        correctCount,
        totalQuestions,
        iqEarned,
        coinsEarned,
      },
    });

    const user = await prisma.user.findUnique({ where: { id: userId } });
    let completedQuizzes = Array.isArray(user.completedQuizzes)
      ? [...user.completedQuizzes]
      : (typeof user.completedQuizzes === 'string' ? JSON.parse(user.completedQuizzes || '[]') : []);

    const existingIndex = completedQuizzes.findIndex(
      (q) => q.subject === subject && q.unitNumber === unitNumber && q.quizName === quizName
    );

    if (existingIndex > -1) {
      if (stars > completedQuizzes[existingIndex].stars) {
        completedQuizzes[existingIndex].stars = stars;
      }
    } else {
      completedQuizzes.push({
        subject,
        unitNumber,
        quizName,
        stars,
        iqEarned,
        coinsEarned,
        completedAt: new Date().toISOString(),
      });
    }

    let iq = user.iq + iqEarned;
    let coins = user.coins + coinsEarned;
    const totalQuizzesCompleted = user.totalQuizzesCompleted + 1;

    // Unit completion logic
    const unitKey = `${subject}_${unitNumber}`;
    let unitCompleted = false;
    let unitBonus = { iq: 0, coins: 0 };
    let completedUnits = [...(user.completedUnits || [])];

    let currentUnitBySubject = typeof user.currentUnitBySubject === 'string'
      ? JSON.parse(user.currentUnitBySubject || '{}')
      : { ...(user.currentUnitBySubject || {}) };

    if (!completedUnits.includes(unitKey)) {
      const allUnitQuestions = await prisma.quizQuestion.findMany({
        where: { subject, unitNumber: parseInt(unitNumber, 10) },
        select: { quizName: true },
      });
      const uniqueQuizzes = Array.from(new Set(allUnitQuestions.map((q) => q.quizName)));
      const completedInUnit = completedQuizzes.filter(
        (q) => q.subject === subject && q.unitNumber === unitNumber && q.stars > 0
      );

      if (uniqueQuizzes.length > 0 && completedInUnit.length >= uniqueQuizzes.length) {
        unitCompleted = true;
        unitBonus = { iq: 50, coins: 25 };
        completedUnits.push(unitKey);
        iq += unitBonus.iq;
        coins += unitBonus.coins;

        if ((currentUnitBySubject[subject] || 1) <= unitNumber) {
          currentUnitBySubject[subject] = Math.min(10, unitNumber + 1);
        }
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        iq,
        coins,
        totalQuizzesCompleted,
        completedQuizzes,
        completedUnits,
        currentUnitBySubject,
      },
    });

    res.status(201).json({
      success: true,
      score: percentage,
      stars,
      rewards: {
        iqEarned,
        coinsEarned,
        totalIqGained: iqEarned + unitBonus.iq,
        totalCoinsGained: coinsEarned + unitBonus.coins,
      },
      unitCompleted,
      unitBonus,
      nextUnitUnlocked: currentUnitBySubject[subject] || unitNumber + 1,
      user: {
        iq: updatedUser.iq,
        coins: updatedUser.coins,
      },
    });
  } catch (err) {
    next(err);
  }
};
