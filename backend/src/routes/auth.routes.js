const express = require('express');
const { body } = require('express-validator');
const { register, login, getMe, forgotPassword, googleAuth, completeOnboarding } = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// POST /api/auth/register
router.post(
  '/register',
  [
    body('name').optional().trim(),
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
    body('age').optional().isInt({ min: 3, max: 20 }),
    body('gradeClass').optional().isString(),
  ],
  register
);

// POST /api/auth/login
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  login
);

// POST /api/auth/forgot-password
router.post(
  '/forgot-password',
  [
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
  ],
  forgotPassword
);

// POST /api/auth/google
router.post(
  '/google',
  [
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
  ],
  googleAuth
);

// POST /api/auth/complete-onboarding (protected)
router.post('/complete-onboarding', protect, completeOnboarding);

// GET /api/auth/me  (protected)
router.get('/me', protect, getMe);

module.exports = router;


