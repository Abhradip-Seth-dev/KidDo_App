const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
});

/**
 * Ensures backward-compatible output for Flutter and frontend consumers:
 * - Injects `_id: doc.id`
 * - Strips `passwordHash`
 */
const formatDoc = (doc) => {
  if (!doc) return doc;
  if (Array.isArray(doc)) return doc.map(formatDoc);
  if (typeof doc !== 'object' || doc instanceof Date) return doc;

  const res = { ...doc };
  if (res.id !== undefined && res._id === undefined) {
    res._id = res.id;
  }
  if (res.passwordHash !== undefined) {
    delete res.passwordHash;
  }
  return res;
};

module.exports = { prisma, formatDoc };
