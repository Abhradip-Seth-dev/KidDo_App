/**
 * seed.js — Populates PostgreSQL with:
 *   - 25 quiz questions (ported from quiz_model.dart)
 *   - 7 shop items (ported from shop_item_model.dart)
 *
 * Run: node src/scripts/seed.js
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { prisma } = require('../prisma');

// ── Quiz Questions ─────────────────────────────────────────────────────────────
const quizQuestions = [
  // ── Math ──────────────────────────────────────────────────────────────────
  {
    subject: 'Math',
    question: 'What is 2 + 3?',
    type: 'textOnly',
    options: [{ text: '4' }, { text: '5' }, { text: '6' }, { text: '7' }],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Math',
    question: 'What is 10 - 4?',
    type: 'textOnly',
    options: [{ text: '5' }, { text: '6' }, { text: '7' }, { text: '8' }],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Math',
    question: 'What is 3 × 3?',
    type: 'textOnly',
    options: [{ text: '6' }, { text: '8' }, { text: '9' }, { text: '12' }],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'Math',
    question: 'Which is the largest number?',
    type: 'textOnly',
    options: [{ text: '45' }, { text: '54' }, { text: '39' }, { text: '42' }],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Math',
    question: 'What is 20 ÷ 4?',
    type: 'textOnly',
    options: [{ text: '4' }, { text: '5' }, { text: '6' }, { text: '8' }],
    correctIndex: 1,
    difficulty: 'easy',
  },

  // ── GK ────────────────────────────────────────────────────────────────────
  {
    subject: 'GK',
    question: 'What is the capital of India?',
    type: 'textOnly',
    options: [
      { text: 'Mumbai' },
      { text: 'New Delhi' },
      { text: 'Chennai' },
      { text: 'Kolkata' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'GK',
    question: 'How many days are in a week?',
    type: 'textOnly',
    options: [{ text: '5' }, { text: '6' }, { text: '7' }, { text: '8' }],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'GK',
    question: 'Which animal is known as the King of the Jungle?',
    type: 'textOnly',
    options: [
      { text: 'Tiger' },
      { text: 'Elephant' },
      { text: 'Lion' },
      { text: 'Bear' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'GK',
    question: 'Which planet is closest to the Sun?',
    type: 'textOnly',
    options: [
      { text: 'Earth' },
      { text: 'Venus' },
      { text: 'Mars' },
      { text: 'Mercury' },
    ],
    correctIndex: 3,
    difficulty: 'easy',
  },
  {
    subject: 'GK',
    question: 'What is the national bird of India?',
    type: 'textOnly',
    options: [
      { text: 'Sparrow' },
      { text: 'Parrot' },
      { text: 'Peacock' },
      { text: 'Eagle' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },

  // ── Science ───────────────────────────────────────────────────────────────
  {
    subject: 'Science',
    question: 'What do plants need to make food?',
    type: 'textOnly',
    options: [
      { text: 'Milk' },
      { text: 'Sunlight' },
      { text: 'Sand' },
      { text: 'Ice' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Science',
    question: 'How many legs does an insect have?',
    type: 'textOnly',
    options: [{ text: '4' }, { text: '6' }, { text: '8' }, { text: '10' }],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Science',
    question: 'What is the boiling point of water?',
    type: 'textOnly',
    options: [
      { text: '90°C' },
      { text: '100°C' },
      { text: '110°C' },
      { text: '80°C' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Science',
    question: 'Which gas do plants absorb from the air?',
    type: 'textOnly',
    options: [
      { text: 'Oxygen' },
      { text: 'Nitrogen' },
      { text: 'Carbon Dioxide' },
      { text: 'Hydrogen' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'Science',
    question: 'What is the largest organ in the human body?',
    type: 'textOnly',
    options: [
      { text: 'Heart' },
      { text: 'Liver' },
      { text: 'Brain' },
      { text: 'Skin' },
    ],
    correctIndex: 3,
    difficulty: 'easy',
  },

  // ── English ───────────────────────────────────────────────────────────────
  {
    subject: 'English',
    question: 'Which of these is a vowel?',
    type: 'textOnly',
    options: [{ text: 'B' }, { text: 'C' }, { text: 'E' }, { text: 'D' }],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'English',
    question: 'What is the plural of "child"?',
    type: 'textOnly',
    options: [
      { text: 'Childs' },
      { text: 'Childes' },
      { text: 'Children' },
      { text: 'Childrens' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'English',
    question: 'Which word means "happy"?',
    type: 'textOnly',
    options: [
      { text: 'Sad' },
      { text: 'Angry' },
      { text: 'Joyful' },
      { text: 'Tired' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'English',
    question: 'Which sentence is correct?',
    type: 'textOnly',
    options: [
      { text: 'He go to school' },
      { text: 'He goes to school' },
      { text: 'He going school' },
      { text: 'He goed school' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'English',
    question: 'What is an antonym of "hot"?',
    type: 'textOnly',
    options: [
      { text: 'Warm' },
      { text: 'Cold' },
      { text: 'Boiling' },
      { text: 'Sunny' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },

  // ── Computer ──────────────────────────────────────────────────────────────
  {
    subject: 'Computer',
    question: 'What does CPU stand for?',
    type: 'textOnly',
    options: [
      { text: 'Central Power Unit' },
      { text: 'Computer Personal Unit' },
      { text: 'Central Processing Unit' },
      { text: 'Control Processing Unit' },
    ],
    correctIndex: 2,
    difficulty: 'easy',
  },
  {
    subject: 'Computer',
    question: 'Which device is used for input?',
    type: 'textOnly',
    options: [
      { text: 'Monitor' },
      { text: 'Printer' },
      { text: 'Speaker' },
      { text: 'Keyboard' },
    ],
    correctIndex: 3,
    difficulty: 'easy',
  },
  {
    subject: 'Computer',
    question: 'What does "www" stand for?',
    type: 'textOnly',
    options: [
      { text: 'World Wide Web' },
      { text: 'World Web Wide' },
      { text: 'Wide World Web' },
      { text: 'Web World Wide' },
    ],
    correctIndex: 0,
    difficulty: 'easy',
  },
  {
    subject: 'Computer',
    question: 'Which of these is a storage device?',
    type: 'textOnly',
    options: [
      { text: 'Mouse' },
      { text: 'Pen Drive' },
      { text: 'Monitor' },
      { text: 'Keyboard' },
    ],
    correctIndex: 1,
    difficulty: 'easy',
  },
  {
    subject: 'Computer',
    question: 'What is the full form of RAM?',
    type: 'textOnly',
    options: [
      { text: 'Random Access Memory' },
      { text: 'Read Access Memory' },
      { text: 'Run Access Memory' },
      { text: 'Rapid Access Memory' },
    ],
    correctIndex: 0,
    difficulty: 'easy',
  },
];

// ── Shop Items ─────────────────────────────────────────────────────────────────
const shopItems = [
  {
    _id: 'avatar_star',
    name: 'Star Hero',
    description: 'Shine bright with this golden star avatar!',
    imageAsset: 'assets/images/avatar_star.png',
    coinCost: 200,
    category: 'avatar',
    emoji: '⭐',
  },
  {
    _id: 'avatar_fire',
    name: 'Flame Champ',
    description: 'Show off your hot streak with this fire avatar!',
    imageAsset: 'assets/images/avatar_fire.png',
    coinCost: 350,
    category: 'avatar',
    emoji: '🔥',
  },
  {
    _id: 'avatar_robot',
    name: 'Robo Brain',
    description: 'A super-smart robot for the tech genius in you!',
    imageAsset: 'assets/images/avatar_robot.png',
    coinCost: 500,
    category: 'avatar',
    emoji: '🤖',
  },
  {
    _id: 'theme_dark',
    name: 'Dark Mode',
    description: 'Easy on the eyes — switch to dark theme!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 500,
    category: 'theme',
    emoji: '🌙',
  },
  {
    _id: 'theme_ocean',
    name: 'Ocean Theme',
    description: 'Dive deep with this cool ocean colour palette.',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 400,
    category: 'theme',
    emoji: '🌊',
  },
  {
    _id: 'powerup_xp2',
    name: 'XP Booster',
    description: '2× IQ points for your next quiz session!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 100,
    category: 'powerUp',
    emoji: '⚡',
  },
  {
    _id: 'powerup_hint',
    name: 'Hint Token',
    description: 'Skip one tricky question in any quiz!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 75,
    category: 'powerUp',
    emoji: '💡',
  },
];

// ── Seed Function ──────────────────────────────────────────────────────────────
const seed = async () => {
  try {
    console.log('🌱 Connecting to PostgreSQL via Prisma...');
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL');

    // Clear existing data
    console.log('\n🗑️  Clearing existing quiz questions and shop items...');
    await prisma.quizQuestion.deleteMany({});
    await prisma.shopItem.deleteMany({});

    // Insert quiz questions
    console.log('📝 Seeding quiz questions...');
    const formattedQuestions = quizQuestions.map((q, idx) => {
      const opts = q.options.map((o) => (typeof o === 'string' ? o : o.text));
      const correctIdx = q.correctIndex !== undefined ? q.correctIndex : 0;
      return {
        subject: q.subject,
        gradeClass: 'Class 3',
        chapter: 'Chapter 1',
        unitNumber: Math.floor(idx / 3) + 1,
        unitName: `Unit ${Math.floor(idx / 3) + 1}: Foundations`,
        quizName: `Quiz ${(idx % 3) + 1}: Practice Challenge`,
        question: q.question,
        type: 'MCQ',
        options: opts,
        correctAnswer: opts[correctIdx] || opts[0],
        correctIndex: correctIdx,
        difficulty: q.difficulty || 'easy',
      };
    });
    for (const q of formattedQuestions) {
      await prisma.quizQuestion.create({ data: q });
    }
    console.log(`   ✅ Inserted ${formattedQuestions.length} quiz questions`);

    // Insert shop items
    console.log('🛒 Seeding 7 shop items...');
    for (const item of shopItems) {
      const { _id, ...rest } = item;
      await prisma.shopItem.create({
        data: {
          id: _id,
          ...rest,
        },
      });
    }
    console.log(`   ✅ Inserted ${shopItems.length} shop items`);

    // Seed Admin & Content Creator Users
    console.log('👤 Seeding Administrator and Content Creator accounts...');
    const bcrypt = require('bcryptjs');

    const adminSalt = await bcrypt.genSalt(12);
    const adminPassHash = await bcrypt.hash('Admin@123', adminSalt);
    const creatorPassHash = await bcrypt.hash('Creator@123', adminSalt);

    await prisma.user.upsert({
      where: { email: 'admin@kiddo.app' },
      update: {
        name: 'Chief Administrator',
        passwordHash: adminPassHash,
        role: 'admin',
        gradeClass: 'All',
        hasCompletedOnboarding: true,
      },
      create: {
        name: 'Chief Administrator',
        email: 'admin@kiddo.app',
        passwordHash: adminPassHash,
        role: 'admin',
        gradeClass: 'All',
        hasCompletedOnboarding: true,
      },
    });

    await prisma.user.upsert({
      where: { email: 'creator@kiddo.app' },
      update: {
        name: 'Curriculum Creator',
        passwordHash: creatorPassHash,
        role: 'content_creator',
        gradeClass: 'All',
        hasCompletedOnboarding: true,
      },
      create: {
        name: 'Curriculum Creator',
        email: 'creator@kiddo.app',
        passwordHash: creatorPassHash,
        role: 'content_creator',
        gradeClass: 'All',
        hasCompletedOnboarding: true,
      },
    });
    console.log('   ✅ Admin account: admin@kiddo.app / Admin@123');
    console.log('   ✅ Creator account: creator@kiddo.app / Creator@123');

    // Seed System Config
    await prisma.systemConfig.upsert({
      where: { key: 'global_settings' },
      update: {
        doubleXpEnabled: false,
        baseXpMultiplier: 1.0,
        bossBattleXpMultiplier: 1.5,
        streakReminderEnabled: true,
        streakReminderHour: 20,
      },
      create: {
        key: 'global_settings',
        doubleXpEnabled: false,
        baseXpMultiplier: 1.0,
        bossBattleXpMultiplier: 1.5,
        streakReminderEnabled: true,
        streakReminderHour: 20,
      },
    });

    // Seed Sample Broadcast
    await prisma.broadcastMessage.create({
      data: {
        title: '🌟 Welcome to KidDO!',
        message: 'New interactive lessons and math puzzle levels are now available. Keep up your daily streak!',
        type: 'event',
        targetClass: 'All',
        active: true,
      },
    });

    // Seed Games
    const seedGames = require('./seed_games');
    await seedGames();

    console.log('\n🎉 Database seeding complete!');
    console.log('   You can now start the server: npm run dev\n');
  } catch (err) {
    console.error('❌ Seeding failed:', err.message);
  } finally {
    await prisma.$disconnect();
    process.exit(0);
  }
};;

seed();
