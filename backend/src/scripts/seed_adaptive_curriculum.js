const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seedAdaptiveCurriculum() {
  console.log('🌱 Seeding Expanded Adaptive Curriculum & Scoring Rules...');

  // 1. Scoring Rules
  const scoringRules = [
    { difficulty: 'beginner', correctPoints: 5, incorrectPoints: -2, hintPenalty: 1 },
    { difficulty: 'intermediate', correctPoints: 10, incorrectPoints: -5, hintPenalty: 1 },
    { difficulty: 'expert', correctPoints: 15, incorrectPoints: -8, hintPenalty: 2 },
  ];

  for (const rule of scoringRules) {
    await prisma.scoringRule.upsert({
      where: { difficulty: rule.difficulty },
      update: rule,
      create: rule,
    });
  }
  console.log('✅ Scoring rules initialized (Beginner: +5/-2, Intermediate: +10/-5, Expert: +15/-8)');

  // 2. Subjects
  const mathSubject = await prisma.adaptiveSubject.upsert({
    where: { code: 'MATHEMATICS' },
    update: { name: 'Mathematics', isActive: true },
    create: { code: 'MATHEMATICS', name: 'Mathematics', isActive: true },
  });

  const scienceSubject = await prisma.adaptiveSubject.upsert({
    where: { code: 'SCIENCE' },
    update: { name: 'Science', isActive: true },
    create: { code: 'SCIENCE', name: 'Science', isActive: true },
  });

  // 3. Topics for Mathematics
  const multiplicationTopic = await prisma.adaptiveTopic.upsert({
    where: {
      subjectId_code: {
        subjectId: mathSubject.id,
        code: 'MULTIPLICATION',
      },
    },
    update: { name: 'Multiplication & Arrays', grade: 3 },
    create: {
      subjectId: mathSubject.id,
      code: 'MULTIPLICATION',
      name: 'Multiplication & Arrays',
      grade: 3,
    },
  });

  const divisionTopic = await prisma.adaptiveTopic.upsert({
    where: {
      subjectId_code: {
        subjectId: mathSubject.id,
        code: 'DIVISION',
      },
    },
    update: { name: 'Equal Sharing & Division', grade: 3 },
    create: {
      subjectId: mathSubject.id,
      code: 'DIVISION',
      name: 'Equal Sharing & Division',
      grade: 3,
    },
  });

  const fractionsTopic = await prisma.adaptiveTopic.upsert({
    where: {
      subjectId_code: {
        subjectId: mathSubject.id,
        code: 'FRACTIONS',
      },
    },
    update: { name: 'Visual Fractions & Parts', grade: 3 },
    create: {
      subjectId: mathSubject.id,
      code: 'FRACTIONS',
      name: 'Visual Fractions & Parts',
      grade: 3,
    },
  });

  const allQuestions = [
    // ══════════════════════════════════════════════════════════════════════════
    // MULTIPLICATION: BEGINNER (Tier 1)
    // ══════════════════════════════════════════════════════════════════════════
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 4 × 3?',
        options: [
          { option_id: 'A', text: '10' },
          { option_id: 'B', text: '12' },
          { option_id: 'C', text: '14' },
          { option_id: 'D', text: '16' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '4 groups of 3 equals 12 (3 + 3 + 3 + 3 = 12).',
        hints: ['Think of adding 3 four times: 3 + 3 + 3 + 3.', 'Count by 3s: 3, 6, 9, 12!'],
      },
      metadata: { tags: ['basic_multiplication', 'arithmetic'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 5 × 2?',
        options: [
          { option_id: 'A', text: '10' },
          { option_id: 'B', text: '12' },
          { option_id: 'C', text: '7' },
          { option_id: 'D', text: '15' },
        ],
      },
      answerKey: {
        correct_option_id: 'A',
        explanation: '5 doubled is 10 (5 + 5 = 10).',
        hints: ['Double 5: 5 + 5 = ?'],
      },
      metadata: { tags: ['basic_multiplication'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'Which number sentence shows 3 groups of 2 cookies?',
        options: [
          { option_id: 'A', text: '3 + 2 = 5' },
          { option_id: 'B', text: '3 × 2 = 6' },
          { option_id: 'C', text: '3 - 2 = 1' },
          { option_id: 'D', text: '2 × 2 = 4' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '3 groups of 2 cookies is written as 3 × 2 = 6.',
        hints: ['Multiplication is repeated equal groups: 2 + 2 + 2.'],
      },
      metadata: { tags: ['concept_groups'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 6 × 2?',
        options: [
          { option_id: 'A', text: '8' },
          { option_id: 'B', text: '12' },
          { option_id: 'C', text: '14' },
          { option_id: 'D', text: '10' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '6 × 2 = 12 (6 + 6 = 12).',
        hints: ['Think of doubling 6: 6 + 6 = ?'],
      },
      metadata: { tags: ['basic_multiplication'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'There are 4 bicycles. Each bicycle has 2 wheels. How many wheels are there in total?',
        options: [
          { option_id: 'A', text: '6' },
          { option_id: 'B', text: '8' },
          { option_id: 'C', text: '10' },
          { option_id: 'D', text: '12' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '4 bicycles × 2 wheels each = 8 wheels.',
        hints: ['Multiply 4 by 2: 2, 4, 6, 8!'],
      },
      metadata: { tags: ['word_problem', 'beginner'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'beginner',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 7 × 1?',
        options: [
          { option_id: 'A', text: '0' },
          { option_id: 'B', text: '1' },
          { option_id: 'C', text: '7' },
          { option_id: 'D', text: '8' },
        ],
      },
      answerKey: {
        correct_option_id: 'C',
        explanation: 'Any number multiplied by 1 stays the same: 7 × 1 = 7.',
        hints: ['Identity property: 1 group of 7 is just 7!'],
      },
      metadata: { tags: ['identity_property'] },
    },

    // ══════════════════════════════════════════════════════════════════════════
    // MULTIPLICATION: INTERMEDIATE (Tier 2)
    // ══════════════════════════════════════════════════════════════════════════
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'intermediate',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 12 multiplied by 5?',
        options: [
          { option_id: 'A', text: '50' },
          { option_id: 'B', text: '60' },
          { option_id: 'C', text: '65' },
          { option_id: 'D', text: '70' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '12 × 5 = 60. You can break it into (10 × 5) + (2 × 5) = 50 + 10 = 60.',
        hints: ['Break 12 into 10 + 2.', '10 × 5 = 50, and 2 × 5 = 10. Add them together!'],
      },
      metadata: { tags: ['two_digit_multiplication'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'intermediate',
      questionType: 'multiple_choice',
      content: {
        question: 'A farmer plants 6 rows of carrots. Each row has 8 carrots. How many carrots did he plant in total?',
        options: [
          { option_id: 'A', text: '42' },
          { option_id: 'B', text: '46' },
          { option_id: 'C', text: '48' },
          { option_id: 'D', text: '54' },
        ],
      },
      answerKey: {
        correct_option_id: 'C',
        explanation: '6 rows × 8 carrots per row = 48 carrots.',
        hints: ['Multiply the rows by carrots: 6 × 8.', '6 × 8 = 48.'],
      },
      metadata: { tags: ['word_problem', 'intermediate'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'intermediate',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 9 × 7?',
        options: [
          { option_id: 'A', text: '56' },
          { option_id: 'B', text: '63' },
          { option_id: 'C', text: '72' },
          { option_id: 'D', text: '65' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '9 × 7 = 63. (10 × 7 - 7 = 70 - 7 = 63).',
        hints: ['Use the 9s trick: 10 × 7 is 70, then subtract 7!'],
      },
      metadata: { tags: ['times_tables'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'intermediate',
      questionType: 'multiple_choice',
      content: {
        question: 'A box holds 8 packs of crayons, and each pack has 6 crayons. How many crayons are in the box?',
        options: [
          { option_id: 'A', text: '44' },
          { option_id: 'B', text: '46' },
          { option_id: 'C', text: '48' },
          { option_id: 'D', text: '52' },
        ],
      },
      answerKey: {
        correct_option_id: 'C',
        explanation: '8 packs × 6 crayons = 48 crayons.',
        hints: ['8 × 6 is 48.'],
      },
      metadata: { tags: ['word_problem'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'intermediate',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 11 × 9?',
        options: [
          { option_id: 'A', text: '99' },
          { option_id: 'B', text: '90' },
          { option_id: 'C', text: '89' },
          { option_id: 'D', text: '109' },
        ],
      },
      answerKey: {
        correct_option_id: 'A',
        explanation: '11 × 9 = 99.',
        hints: ['10 × 9 = 90, plus one more 9 is 99.'],
      },
      metadata: { tags: ['mental_math'] },
    },

    // ══════════════════════════════════════════════════════════════════════════
    // MULTIPLICATION: EXPERT (Tier 3)
    // ══════════════════════════════════════════════════════════════════════════
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'expert',
      questionType: 'multiple_choice',
      content: {
        question: 'A toy store has 7 boxes of robot kits. Each box has 14 robots. How many robots are there altogether?',
        options: [
          { option_id: 'A', text: '98' },
          { option_id: 'B', text: '91' },
          { option_id: 'C', text: '84' },
          { option_id: 'D', text: '102' },
        ],
      },
      answerKey: {
        correct_option_id: 'A',
        explanation: '7 × 14 = 7 × (10 + 4) = 70 + 28 = 98 robots.',
        hints: ['Break 14 into 10 and 4.', 'Calculate 7 × 10 = 70, then 7 × 4 = 28, then sum them!'],
      },
      metadata: { tags: ['multi_step', 'expert_arithmetic'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'expert',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 15 × 6?',
        options: [
          { option_id: 'A', text: '75' },
          { option_id: 'B', text: '80' },
          { option_id: 'C', text: '90' },
          { option_id: 'D', text: '95' },
        ],
      },
      answerKey: {
        correct_option_id: 'C',
        explanation: '15 × 6 = 90. (15 × 2 = 30, and 30 × 3 = 90).',
        hints: ['Double 15 to get 30, then multiply by 3.'],
      },
      metadata: { tags: ['mental_math', 'expert'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'expert',
      questionType: 'multiple_choice',
      content: {
        question: 'A school orders 18 boxes of markers. Each box has 5 markers. How many markers did the school order?',
        options: [
          { option_id: 'A', text: '80' },
          { option_id: 'B', text: '85' },
          { option_id: 'C', text: '90' },
          { option_id: 'D', text: '95' },
        ],
      },
      answerKey: {
        correct_option_id: 'C',
        explanation: '18 × 5 = (10 × 5) + (8 × 5) = 50 + 40 = 90.',
        hints: ['Half of 18 is 9, add a zero: 90!'],
      },
      metadata: { tags: ['word_problem', 'expert'] },
    },
    {
      topicId: multiplicationTopic.id,
      grade: 3,
      difficulty: 'expert',
      questionType: 'multiple_choice',
      content: {
        question: 'What is 25 × 4?',
        options: [
          { option_id: 'A', text: '75' },
          { option_id: 'B', text: '100' },
          { option_id: 'C', text: '125' },
          { option_id: 'D', text: '150' },
        ],
      },
      answerKey: {
        correct_option_id: 'B',
        explanation: '25 × 4 = 100. (Think of 4 quarters making a dollar: 25, 50, 75, 100!).',
        hints: ['Think of four 25-cent coins.'],
      },
      metadata: { tags: ['mental_math'] },
    },
  ];

  // Insert or update all questions
  let count = 0;
  for (const q of allQuestions) {
    const existing = await prisma.adaptiveQuestion.findFirst({
      where: {
        topicId: q.topicId,
        difficulty: q.difficulty,
        grade: q.grade,
        content: {
          path: ['question'],
          equals: q.content.question,
        },
      },
    });

    if (!existing) {
      await prisma.adaptiveQuestion.create({
        data: {
          topicId: q.topicId,
          grade: q.grade,
          difficulty: q.difficulty,
          questionType: q.questionType,
          content: q.content,
          answerKey: q.answerKey,
          metadata: q.metadata,
          status: 'published',
        },
      });
      count++;
    }
  }

  console.log(`✅ Seeded ${count} new questions. Total adaptive question pool is ready and anti-repetitive!`);
}

if (require.main === module) {
  seedAdaptiveCurriculum()
    .catch((err) => {
      console.error('❌ Seeding error:', err);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}

module.exports = { seedAdaptiveCurriculum };
