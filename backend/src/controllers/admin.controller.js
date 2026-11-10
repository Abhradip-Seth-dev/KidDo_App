const bcrypt = require('bcryptjs');
const { prisma, formatDoc } = require('../prisma');

// Helper to log audit actions
const recordAudit = async (req, action, resource, resourceId, details) => {
  try {
    const adminId = req.user?.id || req.user?._id || 'system';
    const adminEmail = req.user?.email || 'admin@kiddo.app';
    const adminRole = req.user?.role || 'admin';
    await prisma.auditLog.create({
      data: {
        adminId,
        adminEmail,
        adminRole,
        action,
        resource,
        resourceId: resourceId ? String(resourceId) : null,
        details: details || {},
        ipAddress: req.ip || req.connection?.remoteAddress || '127.0.0.1',
      },
    });
  } catch (err) {
    console.error('Failed to write audit log:', err.message);
  }
};

// Helper to get or initialize SystemConfig
const getOrCreateConfig = async () => {
  let config = await prisma.systemConfig.findUnique({ where: { key: 'global_settings' } });
  if (!config) {
    config = await prisma.systemConfig.create({ data: { key: 'global_settings' } });
  }
  return config;
};

// ─────────────────────────────────────────────────────────────────────────────
// 1. DASHBOARD & STATS (Section 1.1)
// ─────────────────────────────────────────────────────────────────────────────
exports.getDashboardStats = async (req, res, next) => {
  try {
    const [
      totalStudents,
      totalQuestions,
      totalStoreItems,
      totalQuizzesAttempted,
      config,
      activeBroadcasts,
      recentUsers,
      subjectGroups,
      economyStats,
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'student' } }),
      prisma.quizQuestion.count(),
      prisma.shopItem.count(),
      prisma.quizAttempt.count(),
      getOrCreateConfig(),
      prisma.broadcastMessage.count({ where: { active: true } }),
      prisma.user.findMany({
        take: 6,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          email: true,
          iq: true,
          coins: true,
          streak: true,
          gradeClass: true,
          role: true,
          createdAt: true,
          isBanned: true,
        },
      }),
      prisma.quizQuestion.groupBy({
        by: ['subject'],
        _count: { id: true },
      }),
      prisma.user.aggregate({
        _sum: { coins: true, iq: true },
        _avg: { streak: true },
      }),
    ]);

    const subjectBreakdown = subjectGroups.map((g) => ({
      _id: g.subject,
      count: g._count.id,
    }));

    res.status(200).json({
      success: true,
      stats: {
        totalStudents,
        totalQuestions,
        totalStoreItems,
        totalQuizzesAttempted,
        totalCoinsCirculating: economyStats._sum.coins || 0,
        totalIqEarned: economyStats._sum.iq || 0,
        avgStreak: Math.round(economyStats._avg.streak || 0),
        doubleXpEnabled: config.doubleXpEnabled,
        baseXpMultiplier: config.baseXpMultiplier,
        activeBroadcasts,
        subjectBreakdown,
        recentUsers: formatDoc(recentUsers),
      },
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 1.1 CONTENT & QUESTION BANK MANAGEMENT (Section 1.1)
// ─────────────────────────────────────────────────────────────────────────────
exports.getQuestions = async (req, res, next) => {
  try {
    const { subject, gradeClass, difficulty, search, page = 1, limit = 20 } = req.query;

    const where = {};
    if (subject && subject !== 'All') where.subject = subject;
    if (gradeClass && gradeClass !== 'All') where.gradeClass = gradeClass;
    if (difficulty && difficulty !== 'All') where.difficulty = difficulty;
    if (search) {
      where.OR = [
        { question: { contains: search, mode: 'insensitive' } },
        { quizName: { contains: search, mode: 'insensitive' } },
        { unitName: { contains: search, mode: 'insensitive' } },
      ];
    }

    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const skip = (pageNum - 1) * limitNum;

    const [questions, total] = await Promise.all([
      prisma.quizQuestion.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip,
        take: limitNum,
      }),
      prisma.quizQuestion.count({ where }),
    ]);

    res.status(200).json({
      success: true,
      questions: formatDoc(questions),
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum) || 1,
      },
    });
  } catch (err) {
    next(err);
  }
};

exports.createQuestion = async (req, res, next) => {
  try {
    const {
      subject,
      gradeClass = 'Class 3',
      chapter = 'Chapter 1',
      unitNumber,
      unitName,
      quizName,
      question,
      type = 'MCQ',
      options,
      correctAnswer,
      imageAsset,
      explanation,
      difficulty = 'easy',
    } = req.body;

    if (!subject || !unitNumber || !unitName || !quizName || !question || !options || !correctAnswer) {
      return res.status(400).json({
        success: false,
        message: 'Missing required question fields (subject, unitNumber, unitName, quizName, question, options, correctAnswer)',
      });
    }

    const optList = Array.isArray(options) ? options : options.split(',').map((o) => o.trim());
    const correctIndex = optList.findIndex((opt) => opt.trim() === correctAnswer.trim());

    const newQuestion = await prisma.quizQuestion.create({
      data: {
        subject,
        gradeClass,
        chapter,
        unitNumber: parseInt(unitNumber, 10),
        unitName,
        quizName,
        question,
        type,
        options: optList,
        correctAnswer: correctAnswer.trim(),
        correctIndex: correctIndex >= 0 ? correctIndex : 0,
        imageAsset: imageAsset || null,
        explanation: explanation || null,
        difficulty,
      },
    });

    await recordAudit(req, 'CREATE_QUESTION', 'QuizQuestion', newQuestion.id, {
      subject,
      gradeClass,
      question: question.substring(0, 60),
    });

    res.status(201).json({ success: true, question: formatDoc(newQuestion) });
  } catch (err) {
    next(err);
  }
};

exports.updateQuestion = async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = { ...req.body };

    if (updates.options && updates.correctAnswer) {
      const optList = Array.isArray(updates.options)
        ? updates.options
        : updates.options.split(',').map((o) => o.trim());
      updates.options = optList;
      const correctIdx = optList.findIndex((opt) => opt.trim() === updates.correctAnswer.trim());
      updates.correctIndex = correctIdx >= 0 ? correctIdx : 0;
    }
    if (updates.unitNumber) {
      updates.unitNumber = parseInt(updates.unitNumber, 10);
    }

    const question = await prisma.quizQuestion.update({
      where: { id },
      data: updates,
    });

    await recordAudit(req, 'UPDATE_QUESTION', 'QuizQuestion', id, { updates });

    res.status(200).json({ success: true, question: formatDoc(question) });
  } catch (err) {
    next(err);
  }
};

exports.deleteQuestion = async (req, res, next) => {
  try {
    const { id } = req.params;
    const question = await prisma.quizQuestion.delete({ where: { id } });

    await recordAudit(req, 'DELETE_QUESTION', 'QuizQuestion', id, {
      question: question.question.substring(0, 60),
    });

    res.status(200).json({ success: true, message: 'Question deleted successfully' });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 1.2 USER & ACCOUNT MANAGEMENT (Section 1.2)
// ─────────────────────────────────────────────────────────────────────────────
exports.searchStudents = async (req, res, next) => {
  try {
    const { search, role, gradeClass, isBanned, page = 1, limit = 20 } = req.query;

    const where = {};
    if (role && role !== 'All') where.role = role;
    if (gradeClass && gradeClass !== 'All') where.gradeClass = gradeClass;
    if (isBanned !== undefined && isBanned !== 'All') {
      where.isBanned = isBanned === 'true';
    }
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const skip = (pageNum - 1) * limitNum;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        orderBy: [{ lastLoginAt: 'desc' }, { createdAt: 'desc' }],
        skip,
        take: limitNum,
      }),
      prisma.user.count({ where }),
    ]);

    res.status(200).json({
      success: true,
      users: formatDoc(users),
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum) || 1,
      },
    });
  } catch (err) {
    next(err);
  }
};

exports.getStudentDetails = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Student not found' });
    }

    const [recentAttempts, userLogs] = await Promise.all([
      prisma.quizAttempt.findMany({
        where: { userId: id },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
      prisma.auditLog.findMany({
        where: { resourceId: id },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
    ]);

    res.status(200).json({
      success: true,
      user: formatDoc(user),
      recentAttempts: formatDoc(recentAttempts),
      auditHistory: formatDoc(userLogs),
    });
  } catch (err) {
    next(err);
  }
};

exports.toggleBanStudent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const isBanned = !user.isBanned;
    const updated = await prisma.user.update({
      where: { id },
      data: {
        isBanned,
        forceLogoutBefore: isBanned ? new Date() : user.forceLogoutBefore,
      },
    });

    await recordAudit(
      req,
      isBanned ? 'BAN_USER' : 'UNBAN_USER',
      'User',
      user.id,
      { email: user.email, reason: reason || 'Admin action' }
    );

    res.status(200).json({
      success: true,
      message: `User has been ${isBanned ? 'banned' : 'unbanned'} successfully.`,
      isBanned,
    });
  } catch (err) {
    next(err);
  }
};

exports.resetStudentPassword = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters.',
      });
    }

    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    const user = await prisma.user.update({
      where: { id },
      data: {
        passwordHash,
        forceLogoutBefore: new Date(),
      },
    });

    await recordAudit(req, 'RESET_PASSWORD', 'User', user.id, {
      email: user.email,
    });

    res.status(200).json({
      success: true,
      message: `Password reset successfully for ${user.email}. User has been logged out of all active sessions.`,
    });
  } catch (err) {
    next(err);
  }
};

exports.forceLogoutStudent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = await prisma.user.update({
      where: { id },
      data: { forceLogoutBefore: new Date() },
    });

    await recordAudit(req, 'FORCE_LOGOUT', 'User', user.id, {
      email: user.email,
    });

    res.status(200).json({
      success: true,
      message: `User ${user.email} has been forced to log out.`,
    });
  } catch (err) {
    next(err);
  }
};

exports.adjustStudentCurrency = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { iqDelta = 0, coinsDelta = 0, reason } = req.body;

    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const newIq = Math.max(0, user.iq + parseInt(iqDelta, 10));
    const newCoins = Math.max(0, user.coins + parseInt(coinsDelta, 10));

    const updated = await prisma.user.update({
      where: { id },
      data: { iq: newIq, coins: newCoins },
    });

    await recordAudit(req, 'ADJUST_CURRENCY', 'User', user.id, {
      email: user.email,
      iqDelta,
      coinsDelta,
      newIq,
      newCoins,
      reason: reason || 'Administrative adjustment',
    });

    res.status(200).json({
      success: true,
      message: `Adjusted user balance. Current IQ: ${updated.iq}, Coins: ${updated.coins}`,
      user: { id: updated.id, _id: updated.id, iq: updated.iq, coins: updated.coins },
    });
  } catch (err) {
    next(err);
  }
};

exports.restoreStudentStreak = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { streakCount = 1, reason } = req.body;

    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const previousStreak = user.streak;
    const newStreak = parseInt(streakCount, 10);
    const longestStreak = Math.max(newStreak, user.longestStreak);

    const updated = await prisma.user.update({
      where: { id },
      data: {
        streak: newStreak,
        longestStreak,
        lastActiveDate: new Date(),
      },
    });

    await recordAudit(req, 'RESTORE_STREAK', 'User', user.id, {
      email: user.email,
      previousStreak,
      restoredStreak: newStreak,
      reason: reason || 'Streak restoration',
    });

    res.status(200).json({
      success: true,
      message: `Streak updated to ${updated.streak} days.`,
      streak: updated.streak,
    });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 1.3 ENGAGEMENT & COMMUNICATION TOOLS (Section 1.3)
// ─────────────────────────────────────────────────────────────────────────────
exports.getSystemConfig = async (req, res, next) => {
  try {
    const config = await getOrCreateConfig();
    res.status(200).json({ success: true, config: formatDoc(config) });
  } catch (err) {
    next(err);
  }
};

exports.updateSystemConfig = async (req, res, next) => {
  try {
    const {
      doubleXpEnabled,
      baseXpMultiplier,
      bossBattleXpMultiplier,
      doubleXpTitle,
      streakReminderEnabled,
      streakReminderHour,
      inactivityThresholdDays,
    } = req.body;

    const data = {};
    if (doubleXpEnabled !== undefined) data.doubleXpEnabled = doubleXpEnabled;
    if (baseXpMultiplier !== undefined) data.baseXpMultiplier = parseFloat(baseXpMultiplier);
    if (bossBattleXpMultiplier !== undefined) data.bossBattleXpMultiplier = parseFloat(bossBattleXpMultiplier);
    if (doubleXpTitle !== undefined) data.doubleXpTitle = doubleXpTitle;
    if (streakReminderEnabled !== undefined) data.streakReminderEnabled = streakReminderEnabled;
    if (streakReminderHour !== undefined) data.streakReminderHour = parseInt(streakReminderHour, 10);
    if (inactivityThresholdDays !== undefined) data.inactivityThresholdDays = parseInt(inactivityThresholdDays, 10);
    data.updatedBy = (req.user?.id || req.user?._id) ? String(req.user.id || req.user._id) : null;

    const config = await prisma.systemConfig.upsert({
      where: { key: 'global_settings' },
      update: data,
      create: { key: 'global_settings', ...data },
    });

    await recordAudit(req, 'UPDATE_CONFIG', 'SystemConfig', config.id, req.body);

    res.status(200).json({ success: true, message: 'Settings updated successfully', config: formatDoc(config) });
  } catch (err) {
    next(err);
  }
};

exports.getBroadcasts = async (req, res, next) => {
  try {
    const broadcasts = await prisma.broadcastMessage.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.status(200).json({ success: true, broadcasts: formatDoc(broadcasts) });
  } catch (err) {
    next(err);
  }
};

exports.createBroadcast = async (req, res, next) => {
  try {
    const { title, message, type = 'info', targetClass = 'All', endDate } = req.body;
    if (!title || !message) {
      return res.status(400).json({ success: false, message: 'Title and message are required' });
    }

    const broadcast = await prisma.broadcastMessage.create({
      data: {
        title,
        message,
        type,
        targetClass,
        endDate: endDate ? new Date(endDate) : null,
        createdBy: req.user?.id || req.user?._id || null,
        active: true,
      },
    });

    await recordAudit(req, 'CREATE_BROADCAST', 'BroadcastMessage', broadcast.id, { title, type });

    res.status(201).json({ success: true, broadcast: formatDoc(broadcast) });
  } catch (err) {
    next(err);
  }
};

exports.toggleBroadcast = async (req, res, next) => {
  try {
    const { id } = req.params;
    const broadcast = await prisma.broadcastMessage.findUnique({ where: { id } });
    if (!broadcast) {
      return res.status(404).json({ success: false, message: 'Broadcast not found' });
    }

    const updated = await prisma.broadcastMessage.update({
      where: { id },
      data: { active: !broadcast.active },
    });

    await recordAudit(req, 'TOGGLE_BROADCAST', 'BroadcastMessage', id, { active: updated.active });

    res.status(200).json({ success: true, broadcast: formatDoc(updated) });
  } catch (err) {
    next(err);
  }
};

exports.deleteBroadcast = async (req, res, next) => {
  try {
    const { id } = req.params;
    const broadcast = await prisma.broadcastMessage.delete({ where: { id } });

    await recordAudit(req, 'DELETE_BROADCAST', 'BroadcastMessage', id, { title: broadcast.title });

    res.status(200).json({ success: true, message: 'Broadcast deleted' });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 1.4 STORE MANAGER (Section 1.4)
// ─────────────────────────────────────────────────────────────────────────────
exports.getStoreItems = async (req, res, next) => {
  try {
    const items = await prisma.shopItem.findMany({
      orderBy: { coinCost: 'asc' },
    });
    res.status(200).json({ success: true, items: formatDoc(items) });
  } catch (err) {
    next(err);
  }
};

exports.createStoreItem = async (req, res, next) => {
  try {
    const { _id, id, name, description, coinCost, category = 'avatar', imageAsset, emoji } = req.body;
    const itemId = id || _id;
    if (!itemId || !name || coinCost === undefined) {
      return res.status(400).json({ success: false, message: 'Item ID, name, and coinCost are required' });
    }

    const newItem = await prisma.shopItem.create({
      data: {
        id: itemId,
        name,
        description: description || '',
        coinCost: parseInt(coinCost, 10),
        category,
        imageAsset: imageAsset || 'assets/images/kido_character.png',
        emoji: emoji || '🎁',
        isActive: true,
      },
    });

    await recordAudit(req, 'CREATE_STORE_ITEM', 'ShopItem', newItem.id, { name, coinCost, category });

    res.status(201).json({ success: true, item: formatDoc(newItem) });
  } catch (err) {
    next(err);
  }
};

exports.updateStoreItem = async (req, res, next) => {
  try {
    const { id } = req.params;
    const data = { ...req.body };
    delete data.id;
    delete data._id;
    if (data.coinCost !== undefined) data.coinCost = parseInt(data.coinCost, 10);

    const item = await prisma.shopItem.update({
      where: { id },
      data,
    });

    await recordAudit(req, 'UPDATE_STORE_ITEM', 'ShopItem', id, req.body);

    res.status(200).json({ success: true, item: formatDoc(item) });
  } catch (err) {
    next(err);
  }
};

exports.deleteStoreItem = async (req, res, next) => {
  try {
    const { id } = req.params;
    const item = await prisma.shopItem.delete({ where: { id } });

    await recordAudit(req, 'DELETE_STORE_ITEM', 'ShopItem', id, { name: item.name });

    res.status(200).json({ success: true, message: 'Store item deleted' });
  } catch (err) {
    next(err);
  }
};

// ─────────────────────────────────────────────────────────────────────────────
// 1.5 AUDIT LOGS (Section 1.5)
// ─────────────────────────────────────────────────────────────────────────────
exports.getAuditLogs = async (req, res, next) => {
  try {
    const { action, resource, search, page = 1, limit = 30 } = req.query;

    const where = {};
    if (action && action !== 'All') where.action = action;
    if (resource && resource !== 'All') where.resource = resource;
    if (search) {
      where.OR = [
        { adminEmail: { contains: search, mode: 'insensitive' } },
        { action: { contains: search, mode: 'insensitive' } },
        { resourceId: { contains: search, mode: 'insensitive' } },
      ];
    }

    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);
    const skip = (pageNum - 1) * limitNum;

    const [logs, total] = await Promise.all([
      prisma.auditLog.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limitNum,
      }),
      prisma.auditLog.count({ where }),
    ]);

    res.status(200).json({
      success: true,
      logs: formatDoc(logs),
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum) || 1,
      },
    });
  } catch (err) {
    next(err);
  }
};
