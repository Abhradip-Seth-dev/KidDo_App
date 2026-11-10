const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const { prisma, formatDoc } = require('../prisma');

// ── Helper ─────────────────────────────────────────────────────────────────────
const signToken = (userId) =>
  jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });

const sendAuthResponse = (user, statusCode, res) => {
  const formatted = formatDoc(user);
  const token = signToken(formatted.id);
  res.status(statusCode).json({
    success: true,
    token,
    user: formatted,
  });
};

// ── POST /api/auth/register ────────────────────────────────────────────────────
exports.register = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { name, email, password, age, gradeClass } = req.body;

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'A user with that email already exists',
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        passwordHash,
        age: age ? parseInt(age, 10) : 8,
        gradeClass: gradeClass || 'Class 3',
      },
    });

    sendAuthResponse(user, 201, res);
  } catch (err) {
    next(err);
  }
};

// ── POST /api/auth/login ───────────────────────────────────────────────────────
exports.login = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email, password } = req.body;

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    // Update streak if needed
    const today = new Date();
    const lastActive = user.lastActiveDate ? new Date(user.lastActiveDate) : null;
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    let streak = user.streak;
    if (!lastActive) {
      streak = 1;
    } else if (lastActive.toDateString() === yesterday.toDateString()) {
      streak += 1;
    } else if (lastActive.toDateString() !== today.toDateString()) {
      streak = 1;
    }

    const updated = await prisma.user.update({
      where: { id: user.id },
      data: {
        streak,
        longestStreak: Math.max(streak, user.longestStreak || 0),
        lastActiveDate: today,
        lastLoginAt: today,
      },
    });

    sendAuthResponse(updated, 200, res);
  } catch (err) {
    next(err);
  }
};

// ── GET /api/auth/me ───────────────────────────────────────────────────────────
exports.getMe = async (req, res, next) => {
  try {
    res.status(200).json({ success: true, user: formatDoc(req.user) });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/auth/forgot-password ─────────────────────────────────────────────
exports.forgotPassword = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email } = req.body;
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'No account with that email was found.' });
    }

    return res.status(200).json({
      success: true,
      message: 'Password reset link has been sent to your email address.',
    });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/auth/google ──────────────────────────────────────────────────────
exports.googleAuth = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { email, name, googleId, avatarUrl, age, gradeClass } = req.body;

    let user = await prisma.user.findUnique({ where: { email } });
    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      user = await prisma.user.create({
        data: {
          name: name || email.split('@')[0],
          email,
          googleId: googleId || `google_${Date.now()}`,
          avatarUrl: avatarUrl || 'assets/images/kido_character.png',
          age: age ? parseInt(age, 10) : 8,
          gradeClass: gradeClass || 'Class 3',
          hasCompletedOnboarding: Boolean(age && gradeClass),
        },
      });
    } else {
      const updateData = {};
      if (googleId && !user.googleId) updateData.googleId = googleId;
      if (age && gradeClass) {
        updateData.age = parseInt(age, 10);
        updateData.gradeClass = gradeClass;
        updateData.hasCompletedOnboarding = true;
      }
      if (Object.keys(updateData).length > 0) {
        user = await prisma.user.update({
          where: { id: user.id },
          data: updateData,
        });
      }
    }

    const formatted = formatDoc(user);
    const token = signToken(formatted.id);
    res.status(200).json({
      success: true,
      token,
      user: formatted,
      isNewUser,
      hasCompletedOnboarding: user.hasCompletedOnboarding,
    });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/auth/complete-onboarding ─────────────────────────────────────────
exports.completeOnboarding = async (req, res, next) => {
  try {
    const { name, age, gradeClass, avatarUrl } = req.body;
    const userId = req.user.id || req.user._id;

    const data = { hasCompletedOnboarding: true };
    if (name) data.name = name;
    if (age) data.age = parseInt(age, 10);
    if (gradeClass) data.gradeClass = gradeClass;
    if (avatarUrl) data.avatarUrl = avatarUrl;

    const user = await prisma.user.update({
      where: { id: userId },
      data,
    });

    res.status(200).json({ success: true, user: formatDoc(user) });
  } catch (err) {
    next(err);
  }
};
