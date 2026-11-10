const express = require('express');
const { protect, restrictTo } = require('../middleware/auth.middleware');
const adminController = require('../controllers/admin.controller');

const router = express.Router();

// All admin routes require authentication
router.use(protect);

// ── 1. Dashboard & Stats ───────────────────────────────────────────────────────
router.get('/stats', restrictTo('admin', 'content_creator'), adminController.getDashboardStats);

// ── 1.1 Content & Question Bank (admin & content_creator can manage, only admin can delete)
router.get('/questions', restrictTo('admin', 'content_creator'), adminController.getQuestions);
router.post('/questions', restrictTo('admin', 'content_creator'), adminController.createQuestion);
router.put('/questions/:id', restrictTo('admin', 'content_creator'), adminController.updateQuestion);
router.delete('/questions/:id', restrictTo('admin'), adminController.deleteQuestion);

// ── 1.2 User & Account Management (Admin only) ────────────────────────────────
router.get('/students', restrictTo('admin'), adminController.searchStudents);
router.get('/students/:id', restrictTo('admin'), adminController.getStudentDetails);
router.patch('/students/:id/ban', restrictTo('admin'), adminController.toggleBanStudent);
router.post('/students/:id/reset-password', restrictTo('admin'), adminController.resetStudentPassword);
router.post('/students/:id/force-logout', restrictTo('admin'), adminController.forceLogoutStudent);
router.post('/students/:id/adjust-currency', restrictTo('admin'), adminController.adjustStudentCurrency);
router.post('/students/:id/restore-streak', restrictTo('admin'), adminController.restoreStudentStreak);

// ── 1.3 Engagement, Multipliers & Broadcasts ──────────────────────────────────
router.get('/config', restrictTo('admin', 'content_creator'), adminController.getSystemConfig);
router.put('/config', restrictTo('admin'), adminController.updateSystemConfig);

router.get('/broadcasts', restrictTo('admin', 'content_creator'), adminController.getBroadcasts);
router.post('/broadcasts', restrictTo('admin'), adminController.createBroadcast);
router.patch('/broadcasts/:id/toggle', restrictTo('admin'), adminController.toggleBroadcast);
router.delete('/broadcasts/:id', restrictTo('admin'), adminController.deleteBroadcast);

// ── 1.4 Store Manager ─────────────────────────────────────────────────────────
router.get('/store', restrictTo('admin', 'content_creator'), adminController.getStoreItems);
router.post('/store', restrictTo('admin'), adminController.createStoreItem);
router.put('/store/:id', restrictTo('admin'), adminController.updateStoreItem);
router.delete('/store/:id', restrictTo('admin'), adminController.deleteStoreItem);

// ── 1.5 Audit Logs ───────────────────────────────────────────────────────────
router.get('/audit-logs', restrictTo('admin'), adminController.getAuditLogs);

module.exports = router;
