/**
 * import_questions.js
 * Reads all 40 JSON files from the Flutter assets folder and imports them
 * into PostgreSQL QuizQuestion table via Prisma.
 *
 * Run: node src/scripts/import_questions.js
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const fs = require('fs');
const path = require('path');
const { prisma } = require('../prisma');

// ── Path to the Flutter JSON assets ──────────────────────────────────────────
const JSON_BASE = path.join(
  __dirname,
  '../../../kiddo_app/assets/data/json_files'
);

// ── Subject configuration ─────────────────────────────────────────────────────
const SUBJECTS = [
  { name: 'Math',     folder: 'math',     prefix: 'math_unit_' },
  { name: 'GK',       folder: 'gk',       prefix: 'gk_unit_' },
  { name: 'English',  folder: 'english',  prefix: 'english_unit_' },
  { name: 'Computer', folder: 'computer', prefix: 'computer_unit_' },
];

// ── Transform a raw JSON question to our DB schema ────────────────────────────
const transformQuestion = (raw, subject, unitNumber) => {
  const options = [
    raw.option_1 ?? '',
    raw.option_2 ?? '',
    raw.option_3 ?? '',
    raw.option_4 ?? '',
  ];

  const correctAnswer = raw.correct_ans ?? raw.option_1;
  let correctIndex = options.findIndex(
    (o) => o.trim().toLowerCase() === String(correctAnswer).trim().toLowerCase()
  );
  if (correctIndex === -1) correctIndex = 0;

  const rawType = (raw.Question_type || 'MCQ').toUpperCase();
  let type = 'MCQ';
  if (rawType === 'IMG_MCQ') type = 'IMG_MCQ';
  else if (rawType === 'IMAGE_TAP') type = 'MCQ';
  else if (rawType === 'TRUE_FALSE') type = 'TRUE_FALSE';

  return {
    subject,
    gradeClass: raw.Grade_class || 'Class 3',
    chapter: raw.chapter || `Chapter ${unitNumber}`,
    unitNumber,
    unitName: raw.unit_name || `Unit ${unitNumber}`,
    quizName: raw.quiz_name || `Quiz 1`,
    question: raw.question_text || raw.question || '',
    type,
    options,
    correctAnswer: String(correctAnswer).trim(),
    correctIndex,
    imageAsset: raw.image_asset || raw.image || null,
    explanation: raw.explanation || null,
    difficulty: (raw.difficulty || 'easy').toLowerCase(),
  };
};

// ── Main import runner ────────────────────────────────────────────────────────
const importQuestions = async () => {
  try {
    console.log('🌱 Connecting to PostgreSQL via Prisma...');
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL');

    console.log('\n🗑️  Clearing existing QuizQuestions in PostgreSQL...');
    await prisma.quizQuestion.deleteMany({});

    let totalInserted = 0;

    for (const subject of SUBJECTS) {
      console.log(`\n📚 Importing ${subject.name}...`);
      const subjectDocs = [];

      for (let unit = 1; unit <= 10; unit++) {
        const filePath = path.join(
          JSON_BASE,
          subject.folder,
          `${subject.prefix}${unit}.json`
        );

        if (!fs.existsSync(filePath)) {
          console.warn(`   ⚠️  File not found: ${subject.prefix}${unit}.json — skipping`);
          continue;
        }

        const raw = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
        const transformed = raw.map((q) =>
          transformQuestion(q, subject.name, unit)
        );
        subjectDocs.push(...transformed);

        const quizNames = [...new Set(transformed.map((q) => q.quizName))];
        console.log(
          `   Unit ${unit}: ${transformed.length} questions across ${quizNames.length} quizzes`
        );
      }

      for (const doc of subjectDocs) {
        await prisma.quizQuestion.create({ data: doc });
      }
      totalInserted += subjectDocs.length;
      console.log(`   ✅ ${subjectDocs.length} ${subject.name} questions imported`);
    }

    console.log(`\n🎉 Import complete! Total: ${totalInserted} questions in PostgreSQL`);
    console.log('   You can now start the server: npm run dev\n');
  } catch (err) {
    console.error('❌ Import failed:', err.message);
  } finally {
    await prisma.$disconnect();
    process.exit(0);
  }
};

importQuestions();
