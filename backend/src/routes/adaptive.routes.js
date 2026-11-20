const express = require('express');
const { protect } = require('../middleware/auth.middleware');
const {
  getTopics,
  startSession,
  getNextSessionQuestion,
  submitAttempt,
  getProgressDashboard,
} = require('../controllers/adaptive.controller');

const router = express.Router();

// Require student authentication for all adaptive engine endpoints
router.use(protect);

// 0. Topics catalog
router.get('/topics', getTopics);

// 1. Session management & question flow
router.post('/sessions', startSession);
router.get('/sessions/:sessionId/next-question', getNextSessionQuestion);

// 2. Answer submission (with idempotency & atomic scoring)
router.post('/attempts', submitAttempt);

// 3. Overall student progress & recommendation dashboard
router.get('/progress', getProgressDashboard);

module.exports = router;

