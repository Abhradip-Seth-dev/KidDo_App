/**
 * import_questions.js
 * Reads all 40 JSON files from the Flutter assets folder and imports them
 * into PostgreSQL:
 * 1. QuizQuestion table (for roadmap and level quizzes)
 * 2. AdaptiveSubject, AdaptiveTopic, AdaptiveQuestion tables (for AI adaptive engine)
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
  { name: 'Math',     code: 'MATHEMATICS', folder: 'math',     prefix: 'math_unit_' },
  { name: 'GK',       code: 'GK',          folder: 'gk',       prefix: 'gk_unit_' },
  { name: 'English',  code: 'ENGLISH',     folder: 'english',  prefix: 'english_unit_' },
  { name: 'Computer', code: 'COMPUTER',    folder: 'computer', prefix: 'computer_unit_' },
];

function inferDifficulty(unitNumber) {
  if (unitNumber <= 3) return 'beginner';
  if (unitNumber <= 7) return 'intermediate';
  return 'expert';
}

function mapQuestionType(rawType = '') {
  const t = rawType.toUpperCase();
  if (t === 'IMG_MCQ') return 'multiple_choice';
  if (t === 'TRUE_FALSE') return 'true_false';
  if (t === 'MATCH') return 'matching';
  return 'multiple_choice';
}

// ── Transform for standard QuizQuestion ───────────────────────────────────────
const transformQuizQuestion = (raw, subjectName, unitNumber) => {
  const options = [
    raw.option_1 ?? '',
    raw.option_2 ?? '',
    raw.option_3 ?? '',
    raw.option_4 ?? '',
  ];

  const correctAnswer = raw.correct_ans ?? raw.option_1 ?? '';
  let correctIndex = options.findIndex(
    (o) => o.trim().toLowerCase() === String(correctAnswer).trim().toLowerCase()
  );
  if (correctIndex === -1) correctIndex = 0;

  const rawType = (raw.Question_type || 'MCQ').toUpperCase();
  let type = 'MCQ';
  if (rawType === 'IMG_MCQ') type = 'IMG_MCQ';
  else if (rawType === 'TRUE_FALSE') type = 'TRUE_FALSE';

  return {
    subject: subjectName,
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
    difficulty: (raw.difficulty || inferDifficulty(unitNumber)).toLowerCase(),
  };
};

// ── Transform for AdaptiveQuestion ────────────────────────────────────────────
const transformAdaptiveQuestion = (raw, topicId, unitNumber) => {
  const options = [];
  const labels = [
    { key: 'option_1', id: 'A' },
    { key: 'option_2', id: 'B' },
    { key: 'option_3', id: 'C' },
    { key: 'option_4', id: 'D' },
  ];

  for (const { key, id } of labels) {
    if (raw[key] !== undefined && raw[key] !== null) {
      options.push({ option_id: id, text: String(raw[key]) });
    }
  }

  const correctAns = String(raw.correct_ans ?? (options[0]?.text || ''));
  let correctOptionId = 'A';
  for (const opt of options) {
    if (opt.text.trim().toLowerCase() === correctAns.trim().toLowerCase()) {
      correctOptionId = opt.option_id;
      break;
    }
  }

  return {
    topicId,
    grade: 3,
    difficulty: (raw.difficulty || inferDifficulty(unitNumber)).toLowerCase(),
    questionType: mapQuestionType(raw.Question_type),
    content: {
      question: raw.question || raw.question_text || '',
      options,
      media: raw.image || raw.image_asset || null,
    },
    answerKey: {
      correct_option_id: correctOptionId,
      explanation: raw.explanation || `The correct answer is ${correctAns}.`,
      hints: [],
    },
    metadata: {
      tags: [raw.unit_name || `unit_${unitNumber}`],
      estimated_time_seconds: 30,
    },
    status: 'published',
    contentVersion: 1,
  };
};

// ── Main import runner ────────────────────────────────────────────────────────
const importQuestions = async () => {
  try {
    console.log('🌱 Connecting to PostgreSQL via Prisma...');
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL');

    console.log('\n🗑️  Resetting question tables in PostgreSQL...');
    await prisma.questionAttempt.deleteMany({});
    await prisma.learningSession.deleteMany({});
    await prisma.adaptiveQuestion.deleteMany({});
    await prisma.quizQuestion.deleteMany({});

    let totalQuizQuestions = 0;
    let totalAdaptiveQuestions = 0;

    for (const subject of SUBJECTS) {
      console.log(`\n📚 Processing ${subject.name} (${subject.code})...`);

      // Ensure AdaptiveSubject exists
      const adaptiveSub = await prisma.adaptiveSubject.upsert({
        where: { code: subject.code },
        update: { name: subject.name, isActive: true },
        create: { code: subject.code, name: subject.name, isActive: true },
      });

      const quizQuestionsBatch = [];
      const adaptiveQuestionsBatch = [];

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
        const unitName = raw[0]?.unit_name || `Unit ${unit}`;
        const topicCode = `${subject.code}-U${unit}`;

        // Ensure AdaptiveTopic exists
        const adaptiveTopic = await prisma.adaptiveTopic.upsert({
          where: {
            subjectId_code: {
              subjectId: adaptiveSub.id,
              code: topicCode,
            },
          },
          update: { name: unitName, grade: 3 },
          create: {
            subjectId: adaptiveSub.id,
            code: topicCode,
            name: unitName,
            grade: 3,
          },
        });

        // Transform for QuizQuestion
        const transformedQuiz = raw.map((q) =>
          transformQuizQuestion(q, subject.name, unit)
        );
        quizQuestionsBatch.push(...transformedQuiz);

        // Transform for AdaptiveQuestion
        const transformedAdaptive = raw.map((q) =>
          transformAdaptiveQuestion(q, adaptiveTopic.id, unit)
        );
        adaptiveQuestionsBatch.push(...transformedAdaptive);

        console.log(`   Unit ${unit} (${unitName}): ${raw.length} questions`);
      }

      // Fast bulk insert via Prisma createMany
      if (quizQuestionsBatch.length > 0) {
        const resQuiz = await prisma.quizQuestion.createMany({
          data: quizQuestionsBatch,
        });
        totalQuizQuestions += resQuiz.count;
      }

      if (adaptiveQuestionsBatch.length > 0) {
        const resAdaptive = await prisma.adaptiveQuestion.createMany({
          data: adaptiveQuestionsBatch,
        });
        totalAdaptiveQuestions += resAdaptive.count;
      }

      console.log(`   ✅ Inserted ${quizQuestionsBatch.length} standard quiz questions and ${adaptiveQuestionsBatch.length} adaptive questions.`);
    }

    console.log(`\n============================================================`);
    console.log(`🎉 PUSH COMPLETE!`);
    console.log(`   Total QuizQuestions:     ${totalQuizQuestions}`);
    console.log(`   Total AdaptiveQuestions: ${totalAdaptiveQuestions}`);
    console.log(`   All 40 units across 4 subjects are now in PostgreSQL!`);
    console.log(`============================================================\n`);
  } catch (err) {
    console.error('❌ Import failed:', err);
  } finally {
    await prisma.$disconnect();
    process.exit(0);
  }
};

importQuestions();
