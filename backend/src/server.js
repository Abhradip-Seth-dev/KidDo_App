require('dotenv').config();
const { prisma } = require('./prisma');
const app = require('./app');

const PORT = process.env.PORT || 3000;

// ── Database Connection ────────────────────────────────────────────────────────
const connectDB = async () => {
  try {
    await prisma.$connect();
    console.log('✅ PostgreSQL connected via Prisma');
  } catch (err) {
    console.error('❌ PostgreSQL connection failed:', err.message);
    console.error('   Make sure PostgreSQL is running: docker compose up -d');
    process.exit(1);
  }
};

// ── Start Server ───────────────────────────────────────────────────────────────
const startServer = async () => {
  await connectDB();

  const server = app.listen(PORT, () => {
    console.log(`🚀 KidDO Server running on http://localhost:${PORT}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV}`);
    console.log(`\nAvailable endpoints:`);
    console.log(`  GET  http://localhost:${PORT}/api/health`);
    console.log(`  POST http://localhost:${PORT}/api/auth/register`);
    console.log(`  POST http://localhost:${PORT}/api/auth/login`);
    console.log(`  GET  http://localhost:${PORT}/api/users/leaderboard`);
    console.log(`  GET  http://localhost:${PORT}/api/quiz/questions?subject=Math`);
    console.log(`  GET  http://localhost:${PORT}/api/shop/items`);
  });

  // Graceful shutdown
  process.on('SIGTERM', async () => {
    console.log('👋 SIGTERM received. Shutting down gracefully...');
    server.close(async () => {
      await prisma.$disconnect();
      console.log('💤 Server and DB connection closed.');
      process.exit(0);
    });
  });
};

startServer();
