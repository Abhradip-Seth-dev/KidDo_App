const { validationResult } = require('express-validator');
const { prisma, formatDoc } = require('../prisma');

// ── GET /api/users/profile ─────────────────────────────────────────────────────
exports.getProfile = async (req, res, next) => {
  try {
    res.status(200).json({ success: true, user: formatDoc(req.user) });
  } catch (err) {
    next(err);
  }
};

// ── PATCH /api/users/profile ───────────────────────────────────────────────────
exports.updateProfile = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const userId = req.user.id || req.user._id;
    const allowed = ['name', 'avatarUrl', 'activeTheme', 'activeAvatar', 'age', 'gradeClass'];
    const updates = {};
    allowed.forEach((field) => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });

    const user = await prisma.user.update({
      where: { id: userId },
      data: updates,
    });

    res.status(200).json({ success: true, user: formatDoc(user) });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/users/leaderboard ─────────────────────────────────────────────────
exports.getLeaderboard = async (req, res, next) => {
  try {
    const limit = Math.min(parseInt(req.query.limit) || 20, 50);

    const users = await prisma.user.findMany({
      orderBy: { iq: 'desc' },
      take: limit,
      select: {
        id: true,
        name: true,
        avatarUrl: true,
        iq: true,
        coins: true,
        streak: true,
      },
    });

    res.status(200).json({ success: true, count: users.length, users: formatDoc(users) });
  } catch (err) {
    next(err);
  }
};
