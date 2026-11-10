const express = require('express');
const { body } = require('express-validator');
const {
  getItems,
  purchaseItem,
  getOwnedItems,
} = require('../controllers/shop.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All shop routes require authentication
router.use(protect);

// GET /api/shop/items
router.get('/items', getItems);

// GET /api/shop/owned
router.get('/owned', getOwnedItems);

// POST /api/shop/purchase
router.post(
  '/purchase',
  [body('itemId').notEmpty().withMessage('itemId is required')],
  purchaseItem
);

module.exports = router;
