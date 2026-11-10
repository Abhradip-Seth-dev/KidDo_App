const express = require('express');
const { body } = require('express-validator');
const {
  getGames,
  getGameLevels,
  getLevelData,
  submitGameLevel,
} = require('../controllers/game.controller');
const { protect, optionalAuth } = require('../middleware/auth.middleware');

const router = express.Router();

// GET /api/games — List games with optional user progress
router.get('/', optionalAuth, getGames);

// GET /api/games/:gameKey/levels — List levels metadata for game
router.get('/:gameKey/levels', optionalAuth, getGameLevels);

// GET /api/games/:gameKey/levels/:levelNumber — Get level questions/config
router.get('/:gameKey/levels/:levelNumber', optionalAuth, getLevelData);

// POST /api/games/submit — Submit level completion & rewards
router.post(
  '/submit',
  protect,
  [
    body('gameKey').isIn(['math_puzzle', 'word_scramble', 'memory_match']).withMessage('Invalid gameKey'),
    body('levelNumber').isInt({ min: 1 }).withMessage('levelNumber required'),
    body('stars').isInt({ min: 1, max: 3 }).withMessage('stars must be between 1 and 3'),
  ],
  submitGameLevel
);

module.exports = router;
