const express = require('express');
const { body } = require('express-validator');
const { getLevels, completeLevel } = require('../controllers/level.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All level routes require authentication
router.use(protect);

// GET /api/levels
router.get('/', getLevels);

// POST /api/levels/:levelId/complete
router.post(
  '/:levelId/complete',
  [
    body('stars')
      .optional()
      .isInt({ min: 0, max: 3 })
      .withMessage('Stars must be between 0 and 3'),
  ],
  completeLevel
);

module.exports = router;
