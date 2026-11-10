const jwt = require('jsonwebtoken');
const { prisma, formatDoc } = require('../prisma');

/**
 * Protect route middleware.
 * Reads the JWT from the Authorization header (Bearer token),
 * verifies it, loads the user from DB and attaches to req.user.
 */
const protect = async (req, res, next) => {
  try {
    let token;

    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer ')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorised — no token provided',
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user to request (excluding passwordHash)
    const rawUser = await prisma.user.findUnique({
      where: { id: decoded.id },
    });
    if (!rawUser) {
      return res.status(401).json({
        success: false,
        message: 'The user belonging to this token no longer exists',
      });
    }

    // Check if user is banned
    if (rawUser.isBanned) {
      return res.status(403).json({
        success: false,
        message: 'Your account has been suspended. Please contact support.',
      });
    }

    // Check if user was forced to logout after token creation
    if (rawUser.forceLogoutBefore && decoded.iat) {
      const tokenIat = decoded.iat * 1000;
      if (new Date(rawUser.forceLogoutBefore).getTime() > tokenIat) {
        return res.status(401).json({
          success: false,
          message: 'Session invalidated by administrator. Please log in again.',
        });
      }
    }

    req.user = formatDoc(rawUser);
    next();
  } catch (err) {
    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({ success: false, message: 'Invalid token' });
    }
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expired' });
    }
    next(err);
  }
};

/**
 * Role-Based Access Control (RBAC) middleware.
 * Example: restrictTo('admin') or restrictTo('admin', 'content_creator')
 */
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Forbidden: requires one of the following roles: [${roles.join(', ')}]`,
      });
    }
    next();
  };
};

/**
 * Optional auth middleware.
 * If Authorization header is provided, verifies and attaches req.user.
 * If not provided, continues without error.
 */
const optionalAuth = async (req, res, next) => {
  try {
    let token;
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer ')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({ where: { id: decoded.id } });
      if (user && !user.isBanned) req.user = formatDoc(user);
    }
    next();
  } catch (err) {
    // If token invalid/expired, still continue as guest
    next();
  }
};

module.exports = { protect, restrictTo, optionalAuth };
