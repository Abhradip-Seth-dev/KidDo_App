const express = require('express');
const { body } = require('express-validator');
const {
  getProfile,
  updateProfile,
  getLeaderboard,
} = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All user routes require authentication
router.use(protect);

// GET /api/users/profile
router.get('/profile', getProfile);

// PATCH /api/users/profile
router.patch(
  '/profile',
  [
    body('name').optional().trim().notEmpty().withMessage('Name cannot be empty'),
    body('avatarUrl').optional().isString(),
  ],
  updateProfile
);

// GET /api/users/leaderboard
router.get('/leaderboard', getLeaderboard);

module.exports = router;
