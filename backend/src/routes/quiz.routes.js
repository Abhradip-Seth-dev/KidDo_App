const express = require('express');
const { body, query } = require('express-validator');
const { getUnits, getQuestions, submitAttempt } = require('../controllers/quiz.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();
router.use(protect);

// GET /api/quiz/units?subject=Math
router.get('/units', getUnits);

// GET /api/quiz/questions?subject=Math&unit=1&quiz=Quiz+1%3A+Count+to+5
router.get('/questions', getQuestions);

// POST /api/quiz/submit
router.post(
  '/submit',
  [
    body('subject').isIn(['Math', 'GK', 'English', 'Computer']).withMessage('Invalid subject'),
    body('unitNumber').isInt({ min: 1, max: 10 }).withMessage('unitNumber 1-10 required'),
    body('quizName').notEmpty().withMessage('quizName required'),
    body('correctCount').isInt({ min: 0 }).withMessage('correctCount required'),
    body('totalQuestions').isInt({ min: 1 }).withMessage('totalQuestions required'),
  ],
  submitAttempt
);

module.exports = router;
