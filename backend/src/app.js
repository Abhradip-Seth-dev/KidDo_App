const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const path = require('path');

// Route imports
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/users.routes');
const quizRoutes = require('./routes/quiz.routes');
const levelRoutes = require('./routes/levels.routes');
const shopRoutes = require('./routes/shop.routes');
const gamesRoutes = require('./routes/games.routes');
const adminRoutes = require('./routes/admin.routes');
const featuresRoutes = require('./routes/features.routes');
const { prisma, formatDoc } = require('./prisma');

// Middleware imports
const errorHandler = require('./middleware/errorHandler');

const app = express();

// ── Core Middleware ────────────────────────────────────────────────────────────
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, Postman)
      if (!origin) return callback(null, true);
      // Allow any localhost / 127.0.0.1 origin (Flutter web uses a random port)
      if (origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) {
        return callback(null, true);
      }
      callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// ── Serve Admin Portal Static Files ───────────────────────────────────────────
app.use('/admin', express.static(path.join(__dirname, '../public/admin')));

// ── Health Check ───────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'KidDO API is running 🚀',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

// ── Public Broadcasts Endpoint (for in-app announcements) ───────────────────────
app.get('/api/announcements', async (req, res, next) => {
  try {
    const active = await prisma.broadcastMessage.findMany({
      where: { active: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });
    res.status(200).json({ success: true, announcements: formatDoc(active) });
  } catch (err) {
    next(err);
  }
});

// ── API Routes ─────────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/quiz', quizRoutes);
app.use('/api/levels', levelRoutes);
app.use('/api/shop', shopRoutes);
app.use('/api/games', gamesRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/features', featuresRoutes);

// ── 404 Handler ────────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.originalUrl} not found`,
  });
});

// ── Global Error Handler ───────────────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;
