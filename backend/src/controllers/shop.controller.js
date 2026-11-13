const { validationResult } = require('express-validator');
const { prisma, formatDoc } = require('../prisma');

// ── GET /api/shop/items ────────────────────────────────────────────────────────
exports.getItems = async (req, res, next) => {
  try {
    const items = await prisma.shopItem.findMany({ where: { isActive: true } });
    res.status(200).json({ success: true, count: items.length, items: formatDoc(items) });
  } catch (err) {
    next(err);
  }
};

// ── POST /api/shop/purchase ────────────────────────────────────────────────────
exports.purchaseItem = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { itemId } = req.body;
    const userId = req.user.id || req.user._id;

    // Check item exists
    const item = await prisma.shopItem.findUnique({ where: { id: itemId } });
    if (!item || !item.isActive) {
      return res.status(404).json({ success: false, message: 'Item not found' });
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    const ownedItemIds = user.ownedItemIds || [];

    // Check not already owned
    if (ownedItemIds.includes(itemId)) {
      return res.status(400).json({ success: false, message: 'You already own this item' });
    }

    // Check sufficient coins
    if (user.coins < item.coinCost) {
      return res.status(400).json({
        success: false,
        message: `Not enough coins! You need ${item.coinCost} coins but have ${user.coins}.`,
      });
    }

    // Deduct coins and add item
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        coins: user.coins - item.coinCost,
        ownedItemIds: [...ownedItemIds, itemId],
      },
    });

    res.status(200).json({
      success: true,
      message: `${item.emoji} ${item.name} purchased!`,
      coins: updatedUser.coins,
      ownedItemIds: updatedUser.ownedItemIds,
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/shop/owned ────────────────────────────────────────────────────────
exports.getOwnedItems = async (req, res, next) => {
  try {
    const userId = req.user.id || req.user._id;
    const user = await prisma.user.findUnique({ where: { id: userId } });
    res.status(200).json({
      success: true,
      ownedItemIds: user ? user.ownedItemIds : [],
    });
  } catch (err) {
    next(err);
  }
};
