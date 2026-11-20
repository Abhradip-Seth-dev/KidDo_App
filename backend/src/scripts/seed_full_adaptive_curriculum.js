const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seedFullCurriculum() {
  console.log('🚀 Seeding comprehensive multi-subject adaptive curriculum...');

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

  // 2. Subjects
  const subjectsData = [
    { code: 'MATHEMATICS', name: 'Mathematics' },
    { code: 'SCIENCE', name: 'Science' },
    { code: 'ENGLISH', name: 'English' },
    { code: 'GK', name: 'General Knowledge' },
    { code: 'COMPUTER', name: 'Computer' },
  ];

  const subjects = {};
  for (const s of subjectsData) {
    subjects[s.code] = await prisma.adaptiveSubject.upsert({
      where: { code: s.code },
      update: { name: s.name, isActive: true },
      create: { code: s.code, name: s.name, isActive: true },
    });
  }

  // 3. Define Topics & Questions for each Subject
  const curriculum = [
    // ══════════════════════════════════════════════════════════════════════════
    // MATHEMATICS
    // ══════════════════════════════════════════════════════════════════════════
    {
      subjectCode: 'MATHEMATICS',
      topicCode: 'MULTIPLICATION',
      topicName: 'Multiplication & Arrays',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'What is 4 × 3?',
          opts: [{ id: 'A', t: '10' }, { id: 'B', t: '12' }, { id: 'C', t: '14' }, { id: 'D', t: '16' }],
          ans: 'B',
          exp: '4 groups of 3 equals 12 (3 + 3 + 3 + 3 = 12).',
          hints: ['Add 3 four times.'],
        },
        {
          diff: 'beginner',
          q: 'What is 5 × 2?',
          opts: [{ id: 'A', t: '10' }, { id: 'B', t: '12' }, { id: 'C', t: '7' }, { id: 'D', t: '15' }],
          ans: 'A',
          exp: '5 doubled is 10 (5 + 5 = 10).',
          hints: ['Double 5.'],
        },
        {
          diff: 'beginner',
          q: 'Which number sentence shows 3 groups of 2 cookies?',
          opts: [{ id: 'A', t: '3 + 2 = 5' }, { id: 'B', t: '3 × 2 = 6' }, { id: 'C', t: '3 - 2 = 1' }, { id: 'D', t: '2 × 2 = 4' }],
          ans: 'B',
          exp: '3 groups of 2 cookies is 3 × 2 = 6.',
          hints: ['Count 2 + 2 + 2.'],
        },
        {
          diff: 'beginner',
          q: 'What is 6 × 2?',
          opts: [{ id: 'A', t: '8' }, { id: 'B', t: '12' }, { id: 'C', t: '14' }, { id: 'D', t: '10' }],
          ans: 'B',
          exp: '6 × 2 = 12.',
          hints: ['Double 6.'],
        },
        {
          diff: 'beginner',
          q: 'There are 4 bicycles. Each bicycle has 2 wheels. How many wheels in total?',
          opts: [{ id: 'A', t: '6' }, { id: 'B', t: '8' }, { id: 'C', t: '10' }, { id: 'D', t: '4' }],
          ans: 'B',
          exp: '4 bicycles × 2 wheels = 8 wheels.',
          hints: ['4 × 2 = 8.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'What is 7 × 6?',
          opts: [{ id: 'A', t: '40' }, { id: 'B', t: '42' }, { id: 'C', t: '48' }, { id: 'D', t: '44' }],
          ans: 'B',
          exp: '7 × 6 = 42.',
          hints: ['7 × 5 = 35, add 7 more.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 8 × 4?',
          opts: [{ id: 'A', t: '32' }, { id: 'B', t: '36' }, { id: 'C', t: '28' }, { id: 'D', t: '24' }],
          ans: 'A',
          exp: '8 × 4 = 32.',
          hints: ['Double 8 twice: 8 -> 16 -> 32.'],
        },
        {
          diff: 'intermediate',
          q: 'A box holds 6 packs of pencils. Each pack has 5 pencils. How many pencils are in the box?',
          opts: [{ id: 'A', t: '25' }, { id: 'B', t: '30' }, { id: 'C', t: '35' }, { id: 'D', t: '20' }],
          ans: 'B',
          exp: '6 × 5 = 30 pencils.',
          hints: ['Count by 5s six times.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 9 × 3?',
          opts: [{ id: 'A', t: '24' }, { id: 'B', t: '27' }, { id: 'C', t: '21' }, { id: 'D', t: '30' }],
          ans: 'B',
          exp: '9 × 3 = 27.',
          hints: ['10 × 3 = 30, minus 3.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 11 × 9?',
          opts: [{ id: 'A', t: '90' }, { id: 'B', t: '99' }, { id: 'C', t: '109' }, { id: 'D', t: '89' }],
          ans: 'B',
          exp: '11 × 9 = 99.',
          hints: ['10 × 9 = 90, add 9.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'What is 14 × 5?',
          opts: [{ id: 'A', t: '60' }, { id: 'B', t: '70' }, { id: 'C', t: '75' }, { id: 'D', t: '65' }],
          ans: 'B',
          exp: '14 × 5 = (10 × 5) + (4 × 5) = 50 + 20 = 70.',
          hints: ['Break 14 into 10 and 4.'],
        },
        {
          diff: 'expert',
          q: 'What is 15 × 6?',
          opts: [{ id: 'A', t: '80' }, { id: 'B', t: '90' }, { id: 'C', t: '85' }, { id: 'D', t: '95' }],
          ans: 'B',
          exp: '15 × 6 = (10 × 6) + (5 × 6) = 60 + 30 = 90.',
          hints: ['Half of 15 is tricky, do 10 × 6 + 5 × 6.'],
        },
        {
          diff: 'expert',
          q: 'A cinema hall has 12 rows of 8 seats each. How many people can sit in the hall?',
          opts: [{ id: 'A', t: '96' }, { id: 'B', t: '86' }, { id: 'C', t: '108' }, { id: 'D', t: '92' }],
          ans: 'A',
          exp: '12 × 8 = 96 seats.',
          hints: ['10 × 8 = 80, 2 × 8 = 16, 80 + 16 = 96.'],
        },
        {
          diff: 'expert',
          q: 'What is 16 × 4?',
          opts: [{ id: 'A', t: '60' }, { id: 'B', t: '64' }, { id: 'C', t: '68' }, { id: 'D', t: '58' }],
          ans: 'B',
          exp: '16 × 4 = 64.',
          hints: ['Double 16 twice: 16 -> 32 -> 64.'],
        },
        {
          diff: 'expert',
          q: 'What is 25 × 4?',
          opts: [{ id: 'A', t: '75' }, { id: 'B', t: '100' }, { id: 'C', t: '125' }, { id: 'D', t: '150' }],
          ans: 'B',
          exp: '25 × 4 = 100. 4 quarters make a dollar!',
          hints: ['Think of four 25-cent coins.'],
        },
      ],
    },
    {
      subjectCode: 'MATHEMATICS',
      topicCode: 'DIVISION',
      topicName: 'Equal Sharing & Division',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'Share 6 apples equally between 2 children. How many does each child get?',
          opts: [{ id: 'A', t: '2' }, { id: 'B', t: '3' }, { id: 'C', t: '4' }, { id: 'D', t: '1' }],
          ans: 'B',
          exp: '6 ÷ 2 = 3 apples each.',
          hints: ['Split 6 in half.'],
        },
        {
          diff: 'beginner',
          q: 'What is 10 ÷ 2?',
          opts: [{ id: 'A', t: '4' }, { id: 'B', t: '5' }, { id: 'C', t: '6' }, { id: 'D', t: '8' }],
          ans: 'B',
          exp: '10 ÷ 2 = 5.',
          hints: ['What number doubled makes 10?'],
        },
        {
          diff: 'beginner',
          q: 'What is 8 ÷ 4?',
          opts: [{ id: 'A', t: '1' }, { id: 'B', t: '2' }, { id: 'C', t: '3' }, { id: 'D', t: '4' }],
          ans: 'B',
          exp: '8 ÷ 4 = 2.',
          hints: ['How many 4s make 8?'],
        },
        {
          diff: 'beginner',
          q: 'Divide 12 candies equally among 3 bags. How many candies per bag?',
          opts: [{ id: 'A', t: '3' }, { id: 'B', t: '4' }, { id: 'C', t: '5' }, { id: 'D', t: '6' }],
          ans: 'B',
          exp: '12 ÷ 3 = 4 candies.',
          hints: ['3 × ? = 12.'],
        },
        {
          diff: 'beginner',
          q: 'What is 15 ÷ 3?',
          opts: [{ id: 'A', t: '4' }, { id: 'B', t: '5' }, { id: 'C', t: '6' }, { id: 'D', t: '3' }],
          ans: 'B',
          exp: '15 ÷ 3 = 5.',
          hints: ['Count by 3s up to 15.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'What is 24 ÷ 6?',
          opts: [{ id: 'A', t: '3' }, { id: 'B', t: '4' }, { id: 'C', t: '5' }, { id: 'D', t: '6' }],
          ans: 'B',
          exp: '24 ÷ 6 = 4.',
          hints: ['6 × 4 = 24.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 36 ÷ 9?',
          opts: [{ id: 'A', t: '3' }, { id: 'B', t: '4' }, { id: 'C', t: '5' }, { id: 'D', t: '6' }],
          ans: 'B',
          exp: '36 ÷ 9 = 4.',
          hints: ['9 × 4 = 36.'],
        },
        {
          diff: 'intermediate',
          q: 'A teacher has 40 stickers and shares them equally among 8 students. How many stickers does each student get?',
          opts: [{ id: 'A', t: '4' }, { id: 'B', t: '5' }, { id: 'C', t: '6' }, { id: 'D', t: '7' }],
          ans: 'B',
          exp: '40 ÷ 8 = 5 stickers.',
          hints: ['8 × 5 = 40.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 48 ÷ 6?',
          opts: [{ id: 'A', t: '7' }, { id: 'B', t: '8' }, { id: 'C', t: '9' }, { id: 'D', t: '6' }],
          ans: 'B',
          exp: '48 ÷ 6 = 8.',
          hints: ['6 × 8 = 48.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 45 ÷ 5?',
          opts: [{ id: 'A', t: '8' }, { id: 'B', t: '9' }, { id: 'C', t: '7' }, { id: 'D', t: '10' }],
          ans: 'B',
          exp: '45 ÷ 5 = 9.',
          hints: ['5 × 9 = 45.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'What is 84 ÷ 4?',
          opts: [{ id: 'A', t: '19' }, { id: 'B', t: '21' }, { id: 'C', t: '22' }, { id: 'D', t: '24' }],
          ans: 'B',
          exp: '84 ÷ 4 = (80 ÷ 4) + (4 ÷ 4) = 20 + 1 = 21.',
          hints: ['Divide 80 and 4 separately.'],
        },
        {
          diff: 'expert',
          q: 'What is 96 ÷ 8?',
          opts: [{ id: 'A', t: '11' }, { id: 'B', t: '12' }, { id: 'C', t: '14' }, { id: 'D', t: '13' }],
          ans: 'B',
          exp: '96 ÷ 8 = 12.',
          hints: ['8 × 10 = 80, 8 × 2 = 16.'],
        },
        {
          diff: 'expert',
          q: 'What is 108 ÷ 9?',
          opts: [{ id: 'A', t: '11' }, { id: 'B', t: '12' }, { id: 'C', t: '13' }, { id: 'D', t: '14' }],
          ans: 'B',
          exp: '108 ÷ 9 = 12.',
          hints: ['9 × 12 = 108.'],
        },
        {
          diff: 'expert',
          q: 'If 120 books are packed into 5 equal boxes, how many books are in each box?',
          opts: [{ id: 'A', t: '22' }, { id: 'B', t: '24' }, { id: 'C', t: '26' }, { id: 'D', t: '28' }],
          ans: 'B',
          exp: '120 ÷ 5 = 24 books.',
          hints: ['100 ÷ 5 = 20, 20 ÷ 5 = 4.'],
        },
        {
          diff: 'expert',
          q: 'What is 144 ÷ 12?',
          opts: [{ id: 'A', t: '11' }, { id: 'B', t: '12' }, { id: 'C', t: '13' }, { id: 'D', t: '14' }],
          ans: 'B',
          exp: '144 ÷ 12 = 12.',
          hints: ['12 × 12 = 144.'],
        },
      ],
    },
    {
      subjectCode: 'MATHEMATICS',
      topicCode: 'FRACTIONS',
      topicName: 'Visual Fractions & Parts',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'A pizza is cut into 2 equal slices. What fraction is 1 slice?',
          opts: [{ id: 'A', t: '1/3' }, { id: 'B', t: '1/2' }, { id: 'C', t: '2/1' }, { id: 'D', t: '1/4' }],
          ans: 'B',
          exp: '1 out of 2 equal parts is 1/2.',
          hints: ['Half is 1 over 2.'],
        },
        {
          diff: 'beginner',
          q: 'If a chocolate bar has 4 equal pieces and you eat 1 piece, what fraction did you eat?',
          opts: [{ id: 'A', t: '1/2' }, { id: 'B', t: '1/4' }, { id: 'C', t: '3/4' }, { id: 'D', t: '1/3' }],
          ans: 'B',
          exp: '1 out of 4 parts is 1/4.',
          hints: ['One quarter is 1/4.'],
        },
        {
          diff: 'beginner',
          q: 'In the fraction 3/4, what number is the numerator?',
          opts: [{ id: 'A', t: '4' }, { id: 'B', t: '3' }, { id: 'C', t: '7' }, { id: 'D', t: '1' }],
          ans: 'B',
          exp: 'The top number is the numerator, which is 3.',
          hints: ['Numerator is on top.'],
        },
        {
          diff: 'beginner',
          q: 'In the fraction 2/5, what number is the denominator?',
          opts: [{ id: 'A', t: '2' }, { id: 'B', t: '5' }, { id: 'C', t: '3' }, { id: 'D', t: '7' }],
          ans: 'B',
          exp: 'The bottom number is the denominator (down = denominator), which is 5.',
          hints: ['Denominator is down below.'],
        },
        {
          diff: 'beginner',
          q: 'Which fraction equals one whole?',
          opts: [{ id: 'A', t: '1/2' }, { id: 'B', t: '4/4' }, { id: 'C', t: '3/4' }, { id: 'D', t: '2/3' }],
          ans: 'B',
          exp: 'When numerator and denominator are equal (4/4), it equals 1 whole.',
          hints: ['All 4 pieces of 4.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'Which fraction is greater: 1/2 or 1/4?',
          opts: [{ id: 'A', t: '1/4' }, { id: 'B', t: '1/2' }, { id: 'C', t: 'They are equal' }, { id: 'D', t: 'Cannot tell' }],
          ans: 'B',
          exp: '1/2 is half of a whole, which is larger than 1/4 (a quarter).',
          hints: ['Half a cake is bigger than a quarter cake.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 1/4 + 2/4?',
          opts: [{ id: 'A', t: '2/8' }, { id: 'B', t: '3/4' }, { id: 'C', t: '3/8' }, { id: 'D', t: '1/2' }],
          ans: 'B',
          exp: 'With the same denominator, add numerators: 1 + 2 = 3, so 3/4.',
          hints: ['Add 1 and 2, keep denominator 4.'],
        },
        {
          diff: 'intermediate',
          q: 'What fraction is equivalent to 2/4?',
          opts: [{ id: 'A', t: '1/3' }, { id: 'B', t: '1/2' }, { id: 'C', t: '3/4' }, { id: 'D', t: '2/3' }],
          ans: 'B',
          exp: '2/4 simplifies to 1/2 by dividing numerator and denominator by 2.',
          hints: ['2 out of 4 is the same as 1 out of 2.'],
        },
        {
          diff: 'intermediate',
          q: 'What is 5/6 - 2/6?',
          opts: [{ id: 'A', t: '3/0' }, { id: 'B', t: '3/6' }, { id: 'C', t: '3/12' }, { id: 'D', t: '7/6' }],
          ans: 'B',
          exp: '5/6 - 2/6 = 3/6 (which is 1/2).',
          hints: ['Subtract 5 - 2.'],
        },
        {
          diff: 'intermediate',
          q: 'If a cake has 8 slices and 5 are eaten, what fraction of the cake is left?',
          opts: [{ id: 'A', t: '5/8' }, { id: 'B', t: '3/8' }, { id: 'C', t: '3/5' }, { id: 'D', t: '8/3' }],
          ans: 'B',
          exp: '8 - 5 = 3 slices left, so 3/8.',
          hints: ['8 total minus 5 eaten.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'Which fraction is equivalent to 3/5?',
          opts: [{ id: 'A', t: '5/3' }, { id: 'B', t: '6/10' }, { id: 'C', t: '6/5' }, { id: 'D', t: '9/10' }],
          ans: 'B',
          exp: 'Multiply numerator and denominator by 2: (3×2)/(5×2) = 6/10.',
          hints: ['Double both top and bottom.'],
        },
        {
          diff: 'expert',
          q: 'What is 2/3 + 1/6?',
          opts: [{ id: 'A', t: '3/9' }, { id: 'B', t: '5/6' }, { id: 'C', t: '3/6' }, { id: 'D', t: '4/6' }],
          ans: 'B',
          exp: '2/3 = 4/6. 4/6 + 1/6 = 5/6.',
          hints: ['Convert 2/3 to sixths: 4/6.'],
        },
        {
          diff: 'expert',
          q: 'Which fraction is the largest?',
          opts: [{ id: 'A', t: '2/5' }, { id: 'B', t: '3/4' }, { id: 'C', t: '1/2' }, { id: 'D', t: '3/8' }],
          ans: 'B',
          exp: '3/4 = 0.75, which is larger than 1/2 (0.50) and 2/5 (0.40).',
          hints: ['3/4 is 75%.'],
        },
        {
          diff: 'expert',
          q: 'What is 1 - 3/7?',
          opts: [{ id: 'A', t: '2/7' }, { id: 'B', t: '4/7' }, { id: 'C', t: '3/7' }, { id: 'D', t: '5/7' }],
          ans: 'B',
          exp: '1 whole = 7/7. 7/7 - 3/7 = 4/7.',
          hints: ['1 is 7/7.'],
        },
        {
          diff: 'expert',
          q: 'What fraction of 1 hour is 45 minutes?',
          opts: [{ id: 'A', t: '1/2' }, { id: 'B', t: '3/4' }, { id: 'C', t: '2/3' }, { id: 'D', t: '4/5' }],
          ans: 'B',
          exp: '45/60 simplifies to 3/4.',
          hints: ['60 minutes in an hour. 45/60 = ?'],
        },
      ],
    },

    // ══════════════════════════════════════════════════════════════════════════
    // SCIENCE
    // ══════════════════════════════════════════════════════════════════════════
    {
      subjectCode: 'SCIENCE',
      topicCode: 'PLANTS',
      topicName: 'Plants & Photosynthesis',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'What part of the plant absorbs water and minerals from the soil?',
          opts: [{ id: 'A', t: 'Leaves' }, { id: 'B', t: 'Roots' }, { id: 'C', t: 'Flowers' }, { id: 'D', t: 'Stem' }],
          ans: 'B',
          exp: 'Roots anchor the plant and drink water and nutrients from the soil.',
          hints: ['It is underground.'],
        },
        {
          diff: 'beginner',
          q: 'What green pigment helps plants absorb sunlight?',
          opts: [{ id: 'A', t: 'Carotene' }, { id: 'B', t: 'Chlorophyll' }, { id: 'C', t: 'Melanin' }, { id: 'D', t: 'Hemoglobin' }],
          ans: 'B',
          exp: 'Chlorophyll gives leaves their green color and traps light energy.',
          hints: ['Starts with Chloro-.'],
        },
        {
          diff: 'beginner',
          q: 'What do green plants need to make their food?',
          opts: [{ id: 'A', t: 'Milk and sugar' }, { id: 'B', t: 'Sunlight, water, and air' }, { id: 'C', t: 'Soil only' }, { id: 'D', t: 'Darkness and heat' }],
          ans: 'B',
          exp: 'Plants need sunlight, water, and carbon dioxide to make food.',
          hints: ['Sun and rain!'],
        },
        {
          diff: 'beginner',
          q: 'Which part of the plant makes seeds?',
          opts: [{ id: 'A', t: 'Stem' }, { id: 'B', t: 'Flower' }, { id: 'C', t: 'Root' }, { id: 'D', t: 'Bark' }],
          ans: 'B',
          exp: 'Flowers produce seeds and fruits for reproduction.',
          hints: ['The colorful bloom.'],
        },
        {
          diff: 'beginner',
          q: 'What gas do plants release into the air during photosynthesis?',
          opts: [{ id: 'A', t: 'Carbon dioxide' }, { id: 'B', t: 'Oxygen' }, { id: 'C', t: 'Nitrogen' }, { id: 'D', t: 'Helium' }],
          ans: 'B',
          exp: 'Plants release oxygen, which humans and animals breathe!',
          hints: ['The gas we breathe in.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'Tiny pores on leaves through which gases enter and leave are called:',
          opts: [{ id: 'A', t: 'Veins' }, { id: 'B', t: 'Stomata' }, { id: 'C', t: 'Roots' }, { id: 'D', t: 'Petals' }],
          ans: 'B',
          exp: 'Stomata are tiny openings on the underside of leaves for gas exchange.',
          hints: ['Starts with S.'],
        },
        {
          diff: 'intermediate',
          q: 'What gas do plants absorb from the air to perform photosynthesis?',
          opts: [{ id: 'A', t: 'Oxygen' }, { id: 'B', t: 'Carbon Dioxide' }, { id: 'C', t: 'Hydrogen' }, { id: 'D', t: 'Argon' }],
          ans: 'B',
          exp: 'Plants take in carbon dioxide (CO2) from the atmosphere.',
          hints: ['CO2.'],
        },
        {
          diff: 'intermediate',
          q: 'Which plant part transports water up from the roots to the leaves?',
          opts: [{ id: 'A', t: 'Petals' }, { id: 'B', t: 'Stem' }, { id: 'C', t: 'Fruit' }, { id: 'D', t: 'Seeds' }],
          ans: 'B',
          exp: 'The stem acts like a straw carrying water via xylem vessels.',
          hints: ['The central trunk/stalk.'],
        },
        {
          diff: 'intermediate',
          q: 'What sugar is produced by plants during photosynthesis for energy?',
          opts: [{ id: 'A', t: 'Lactose' }, { id: 'B', t: 'Glucose' }, { id: 'C', t: 'Salt' }, { id: 'D', t: 'Fructose' }],
          ans: 'B',
          exp: 'Plants produce glucose (simple sugar) as food.',
          hints: ['Starts with Glu-.'],
        },
        {
          diff: 'intermediate',
          q: 'Which of these is a carnivorous plant that catches insects for nutrients?',
          opts: [{ id: 'A', t: 'Rose' }, { id: 'B', t: 'Venus Flytrap' }, { id: 'C', t: 'Sunflower' }, { id: 'D', t: 'Oak' }],
          ans: 'B',
          exp: 'The Venus flytrap catches insects to supplement poor soil nutrients.',
          hints: ['Has "Flytrap" in its name.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'The vascular tissue in plants that carries food made in leaves to other parts is:',
          opts: [{ id: 'A', t: 'Xylem' }, { id: 'B', t: 'Phloem' }, { id: 'C', t: 'Cortex' }, { id: 'D', t: 'Epidermis' }],
          ans: 'B',
          exp: 'Phloem carries food (glucose), while Xylem carries water.',
          hints: ['Phloem sounds like "food".'],
        },
        {
          diff: 'expert',
          q: 'What is the process called when excess water evaporates from plant leaves?',
          opts: [{ id: 'A', t: 'Respiration' }, { id: 'B', t: 'Transpiration' }, { id: 'C', t: 'Germination' }, { id: 'D', t: 'Pollination' }],
          ans: 'B',
          exp: 'Transpiration is the evaporation of water vapor through leaf stomata.',
          hints: ['Trans-piration.'],
        },
        {
          diff: 'expert',
          q: 'During the night, in the absence of sunlight, plants mostly carry out:',
          opts: [{ id: 'A', t: 'Photosynthesis' }, { id: 'B', t: 'Respiration (taking in oxygen)' }, { id: 'C', t: 'Sprouting' }, { id: 'D', t: 'Chlorosis' }],
          ans: 'B',
          exp: 'Without sunlight, plants cannot photosynthesize, so they only respire.',
          hints: ['They take in oxygen just like us at night.'],
        },
        {
          diff: 'expert',
          q: 'Which chemical equation best represents photosynthesis?',
          opts: [{ id: 'A', t: 'Glucose + O2 -> CO2' }, { id: 'B', t: 'CO2 + Water + Light -> Glucose + O2' }, { id: 'C', t: 'O2 + Water -> Acid' }, { id: 'D', t: 'Water + Salt -> Sugar' }],
          ans: 'B',
          exp: 'Carbon Dioxide + Water + Sunlight -> Glucose + Oxygen.',
          hints: ['Sunlight and water make glucose and oxygen.'],
        },
        {
          diff: 'expert',
          q: 'Which plant adaptation helps desert cacti survive dry conditions?',
          opts: [{ id: 'A', t: 'Huge flat leaves' }, { id: 'B', t: 'Spines and thick water-storing stems' }, { id: 'C', t: 'Open stomata all day' }, { id: 'D', t: 'Soft thin bark' }],
          ans: 'B',
          exp: 'Spines prevent water loss and deter animals; fleshy stems store water.',
          hints: ['Cactus spikes and succulent stem.'],
        },
      ],
    },
    {
      subjectCode: 'SCIENCE',
      topicCode: 'ANIMALS',
      topicName: 'Animals & Habitats',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'How many legs does an insect have?',
          opts: [{ id: 'A', t: '4' }, { id: 'B', t: '6' }, { id: 'C', t: '8' }, { id: 'D', t: '10' }],
          ans: 'B',
          exp: 'All adult insects have 6 legs (3 pairs).',
          hints: ['Spiders have 8, insects have 2 fewer.'],
        },
        {
          diff: 'beginner',
          q: 'Which animal breathes through gills and swims with fins?',
          opts: [{ id: 'A', t: 'Frog' }, { id: 'B', t: 'Fish' }, { id: 'C', t: 'Duck' }, { id: 'D', t: 'Seal' }],
          ans: 'B',
          exp: 'Fish live in water, have fins, and use gills to extract oxygen.',
          hints: ['Lives underwater.'],
        },
        {
          diff: 'beginner',
          q: 'Animals that eat only plants are called:',
          opts: [{ id: 'A', t: 'Carnivores' }, { id: 'B', t: 'Herbivores' }, { id: 'C', t: 'Omnivores' }, { id: 'D', t: 'Decomposers' }],
          ans: 'B',
          exp: 'Herbivores eat herbs and plants (e.g., deer, cows, rabbits).',
          hints: ['Herb = plant.'],
        },
        {
          diff: 'beginner',
          q: 'Which animal is a mammal that can fly?',
          opts: [{ id: 'A', t: 'Eagle' }, { id: 'B', t: 'Bat' }, { id: 'C', t: 'Penguin' }, { id: 'D', t: 'Ostrich' }],
          ans: 'B',
          exp: 'Bats are true mammals that have wings and can fly.',
          hints: ['Hangs upside down in caves.'],
        },
        {
          diff: 'beginner',
          q: 'What is the natural home or environment of an animal called?',
          opts: [{ id: 'A', t: 'Zoo' }, { id: 'B', t: 'Habitat' }, { id: 'C', t: 'Cage' }, { id: 'D', t: 'Nest' }],
          ans: 'B',
          exp: 'A habitat provides the animal with food, water, and shelter.',
          hints: ['Sounds like habit.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'Which animal group is cold-blooded and lays soft jelly eggs in water?',
          opts: [{ id: 'A', t: 'Birds' }, { id: 'B', t: 'Amphibians' }, { id: 'C', t: 'Mammals' }, { id: 'D', t: 'Reptiles' }],
          ans: 'B',
          exp: 'Amphibians (like frogs) live both in water and on land.',
          hints: ['Frogs and salamanders.'],
        },
        {
          diff: 'intermediate',
          q: 'Polar bears have thick white fur and a layer of blubber to survive in the:',
          opts: [{ id: 'A', t: 'Desert' }, { id: 'B', t: 'Arctic tundra' }, { id: 'C', t: 'Rainforest' }, { id: 'D', t: 'Grassland' }],
          ans: 'B',
          exp: 'Polar bears are adapted to extreme freezing cold in the Arctic.',
          hints: ['Snow and ice.'],
        },
        {
          diff: 'intermediate',
          q: 'Camels store what in their humps to survive long desert journeys without food?',
          opts: [{ id: 'A', t: 'Water' }, { id: 'B', t: 'Fat' }, { id: 'C', t: 'Bone' }, { id: 'D', t: 'Blood' }],
          ans: 'B',
          exp: 'Camels store energy-rich fat in their humps, which converts to water and energy.',
          hints: ['It is not liquid water, but stored energy.'],
        },
        {
          diff: 'intermediate',
          q: 'Which of the following animals is an omnivore (eats both plants and meat)?',
          opts: [{ id: 'A', t: 'Lion' }, { id: 'B', t: 'Bear' }, { id: 'C', t: 'Deer' }, { id: 'D', t: 'Giraffe' }],
          ans: 'B',
          exp: 'Bears eat berries, roots, fish, and small mammals.',
          hints: ['Eats berries and salmon.'],
        },
        {
          diff: 'intermediate',
          q: 'What is it called when an animal blends in with its surroundings to hide?',
          opts: [{ id: 'A', t: 'Migration' }, { id: 'B', t: 'Camouflage' }, { id: 'C', t: 'Hibernation' }, { id: 'D', t: 'Molting' }],
          ans: 'B',
          exp: 'Camouflage helps animals hide from predators or prey.',
          hints: ['Chameleons do this.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'Which characteristic is unique to all mammals?',
          opts: [{ id: 'A', t: 'Laying hard eggs' }, { id: 'B', t: 'Mammary glands producing milk for young' }, { id: 'C', t: 'Having cold blood' }, { id: 'D', t: 'Gills for breathing' }],
          ans: 'B',
          exp: 'All mammals nurse their young with milk and possess hair/fur.',
          hints: ['Mothers produce milk.'],
        },
        {
          diff: 'expert',
          q: 'What is the deep winter sleep during which an animal slows its heart rate called?',
          opts: [{ id: 'A', t: 'Estivation' }, { id: 'B', t: 'Hibernation' }, { id: 'C', t: 'Metamorphosis' }, { id: 'D', t: 'Regeneration' }],
          ans: 'B',
          exp: 'Hibernation allows animals to conserve energy during food-scarce winters.',
          hints: ['Winter sleep.'],
        },
        {
          diff: 'expert',
          q: 'Which invertebrate group has jointed legs, an exoskeleton, and segmented bodies?',
          opts: [{ id: 'A', t: 'Mollusks' }, { id: 'B', t: 'Arthropods' }, { id: 'C', t: 'Annelids' }, { id: 'D', t: 'Cnidarians' }],
          ans: 'B',
          exp: 'Arthropods include insects, arachnids, and crustaceans.',
          hints: ['Arthro = joint, pod = foot.'],
        },
        {
          diff: 'expert',
          q: 'The complete change from a caterpillar to a butterfly is known as:',
          opts: [{ id: 'A', t: 'Mutation' }, { id: 'B', t: 'Metamorphosis' }, { id: 'C', t: 'Photosynthesis' }, { id: 'D', t: 'Evolution' }],
          ans: 'B',
          exp: 'Complete metamorphosis has 4 stages: egg, larva, pupa, adult.',
          hints: ['Meta-morphosis.'],
        },
        {
          diff: 'expert',
          q: 'Which organ helps birds grind up tough seeds and food without teeth?',
          opts: [{ id: 'A', t: 'Crop' }, { id: 'B', t: 'Gizzard' }, { id: 'C', t: 'Liver' }, { id: 'D', t: 'Pancreas' }],
          ans: 'B',
          exp: 'The muscular gizzard uses swallowed pebbles to grind food.',
          hints: ['Starts with G.'],
        },
      ],
    },

    // ══════════════════════════════════════════════════════════════════════════
    // ENGLISH
    // ══════════════════════════════════════════════════════════════════════════
    {
      subjectCode: 'ENGLISH',
      topicCode: 'GRAMMAR',
      topicName: 'Vowels, Nouns & Grammar',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'Which of the following is a vowel?',
          opts: [{ id: 'A', t: 'B' }, { id: 'B', t: 'E' }, { id: 'C', t: 'K' }, { id: 'D', t: 'T' }],
          ans: 'B',
          exp: 'The vowels are A, E, I, O, U.',
          hints: ['Think of A, E, I, O, U.'],
        },
        {
          diff: 'beginner',
          q: 'What type of word is "table"?',
          opts: [{ id: 'A', t: 'Verb' }, { id: 'B', t: 'Noun (Thing)' }, { id: 'C', t: 'Adjective' }, { id: 'D', t: 'Adverb' }],
          ans: 'B',
          exp: 'A table is an object, so it is a naming word (noun).',
          hints: ['It is an object/thing.'],
        },
        {
          diff: 'beginner',
          q: 'What is the plural of "cat"?',
          opts: [{ id: 'A', t: 'Caties' }, { id: 'B', t: 'Cats' }, { id: 'C', t: 'Cates' }, { id: 'D', t: 'Cat' }],
          ans: 'B',
          exp: 'One cat, two cats (add -s).',
          hints: ['Add s.'],
        },
        {
          diff: 'beginner',
          q: 'Which article goes before the word "apple"?',
          opts: [{ id: 'A', t: 'A' }, { id: 'B', t: 'An' }, { id: 'C', t: 'Them' }, { id: 'D', t: 'Some' }],
          ans: 'B',
          exp: 'We use "an" before vowel sounds (An apple).',
          hints: ['Starts with vowel A.'],
        },
        {
          diff: 'beginner',
          q: 'What is the plural of "child"?',
          opts: [{ id: 'A', t: 'Childs' }, { id: 'B', t: 'Children' }, { id: 'C', t: 'Childrens' }, { id: 'D', t: 'Childes' }],
          ans: 'B',
          exp: '"Child" has an irregular plural form: "children".',
          hints: ['Irregular plural.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'Identify the verb in: "The dog barked loudly at night."',
          opts: [{ id: 'A', t: 'Dog' }, { id: 'B', t: 'Barked' }, { id: 'C', t: 'Loudly' }, { id: 'D', t: 'Night' }],
          ans: 'B',
          exp: 'A verb is an action word; "barked" is the action.',
          hints: ['The action word.'],
        },
        {
          diff: 'intermediate',
          q: 'Identify the adjective in: "She wore a shiny gold necklace."',
          opts: [{ id: 'A', t: 'She' }, { id: 'B', t: 'Shiny' }, { id: 'C', t: 'Wore' }, { id: 'D', t: 'Necklace' }],
          ans: 'B',
          exp: 'Adjectives describe nouns; "shiny" describes the necklace.',
          hints: ['Describes the noun.'],
        },
        {
          diff: 'intermediate',
          q: 'Which word is a proper noun and should always be capitalized?',
          opts: [{ id: 'A', t: 'City' }, { id: 'B', t: 'London' }, { id: 'C', t: 'River' }, { id: 'D', t: 'Country' }],
          ans: 'B',
          exp: '"London" is a specific city name, making it a proper noun.',
          hints: ['Specific name of a city.'],
        },
        {
          diff: 'intermediate',
          q: 'What is the past tense of "run"?',
          opts: [{ id: 'A', t: 'Runned' }, { id: 'B', t: 'Ran' }, { id: 'C', t: 'Running' }, { id: 'D', t: 'Runs' }],
          ans: 'B',
          exp: 'The irregular past tense of run is ran.',
          hints: ['Yesterday I ... in the park.'],
        },
        {
          diff: 'intermediate',
          q: 'Choose the correct pronoun: "Maya and Priya said _____ would study together."',
          opts: [{ id: 'A', t: 'She' }, { id: 'B', t: 'They' }, { id: 'C', t: 'We' }, { id: 'D', t: 'Her' }],
          ans: 'B',
          exp: 'Maya and Priya are two other people, so the third-person plural pronoun is "they".',
          hints: ['Plural third person.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'Identify the adverb in: "The turtle walked very slowly."',
          opts: [{ id: 'A', t: 'Turtle' }, { id: 'B', t: 'Slowly' }, { id: 'C', t: 'Walked' }, { id: 'D', t: 'The' }],
          ans: 'B',
          exp: '"Slowly" tells HOW the turtle walked, so it is an adverb of manner.',
          hints: ['Ends in -ly and describes the action.'],
        },
        {
          diff: 'expert',
          q: 'Which sentence has correct subject-verb agreement?',
          opts: [{ id: 'A', t: 'The birds flies south in winter.' }, { id: 'B', t: 'The birds fly south in winter.' }, { id: 'C', t: 'The birds is flying south.' }, { id: 'D', t: 'The bird fly south.' }],
          ans: 'B',
          exp: 'Plural subject "birds" takes the plural verb form "fly".',
          hints: ['Plural noun needs plural verb without -s.'],
        },
        {
          diff: 'expert',
          q: 'What type of conjunction is "because" in: "I wore a coat because it was chilly"?',
          opts: [{ id: 'A', t: 'Coordinating' }, { id: 'B', t: 'Subordinating' }, { id: 'C', t: 'Correlative' }, { id: 'D', t: 'Interjection' }],
          ans: 'B',
          exp: '"Because" introduces a dependent clause of reason (subordinating conjunction).',
          hints: ['Connects a main clause to a reason.'],
        },
        {
          diff: 'expert',
          q: 'What is the comparative form of the adjective "good"?',
          opts: [{ id: 'A', t: 'Gooder' }, { id: 'B', t: 'Better' }, { id: 'C', t: 'Best' }, { id: 'D', t: 'More good' }],
          ans: 'B',
          exp: 'Good -> Better (comparative) -> Best (superlative).',
          hints: ['Good -> ... -> Best.'],
        },
        {
          diff: 'expert',
          q: 'Which sentence uses a possessive apostrophe correctly?',
          opts: [{ id: 'A', t: 'The boy\'s bicycle was red.' }, { id: 'B', t: 'The boys\' bicycle were red.' }, { id: 'C', t: 'The boys bicycle\'s was red.' }, { id: 'D', t: 'The boy bicycle was red.' }],
          ans: 'A',
          exp: 'One boy owns the bicycle: boy\'s bicycle.',
          hints: ['Apostrophe before s for singular owner.'],
        },
      ],
    },

    // ══════════════════════════════════════════════════════════════════════════
    // GENERAL KNOWLEDGE (GK)
    // ══════════════════════════════════════════════════════════════════════════
    {
      subjectCode: 'GK',
      topicCode: 'GEOGRAPHY',
      topicName: 'World Geography & Capitals',
      questions: [
        // Beginner
        {
          diff: 'beginner',
          q: 'What is the capital city of India?',
          opts: [{ id: 'A', t: 'Mumbai' }, { id: 'B', t: 'New Delhi' }, { id: 'C', t: 'Chennai' }, { id: 'D', t: 'Kolkata' }],
          ans: 'B',
          exp: 'New Delhi is the official capital of India.',
          hints: ['Has Delhi in its name.'],
        },
        {
          diff: 'beginner',
          q: 'How many continents are there on Earth?',
          opts: [{ id: 'A', t: '5' }, { id: 'B', t: '7' }, { id: 'C', t: '6' }, { id: 'D', t: '8' }],
          ans: 'B',
          exp: 'There are 7 continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
          hints: ['Lucky number 7.'],
        },
        {
          diff: 'beginner',
          q: 'Which is the largest ocean in the world?',
          opts: [{ id: 'A', t: 'Atlantic Ocean' }, { id: 'B', t: 'Pacific Ocean' }, { id: 'C', t: 'Indian Ocean' }, { id: 'D', t: 'Arctic Ocean' }],
          ans: 'B',
          exp: 'The Pacific Ocean covers more than 30% of the Earth\'s surface.',
          hints: ['Starts with P.'],
        },
        {
          diff: 'beginner',
          q: 'Which continent has the most countries and is home to the Sahara Desert?',
          opts: [{ id: 'A', t: 'Europe' }, { id: 'B', t: 'Africa' }, { id: 'C', t: 'Asia' }, { id: 'D', t: 'South America' }],
          ans: 'B',
          exp: 'Africa contains 54 recognized countries and the great Sahara.',
          hints: ['Safari continent.'],
        },
        {
          diff: 'beginner',
          q: 'What is the capital city of France, known for the Eiffel Tower?',
          opts: [{ id: 'A', t: 'Rome' }, { id: 'B', t: 'Paris' }, { id: 'C', t: 'Berlin' }, { id: 'D', t: 'Madrid' }],
          ans: 'B',
          exp: 'Paris is the capital of France.',
          hints: ['City of Lights.'],
        },
        // Intermediate
        {
          diff: 'intermediate',
          q: 'Which is the highest mountain peak in the world?',
          opts: [{ id: 'A', t: 'K2' }, { id: 'B', t: 'Mount Everest' }, { id: 'C', t: 'Kangchenjunga' }, { id: 'D', t: 'Mount Kilimanjaro' }],
          ans: 'B',
          exp: 'Mount Everest stands at 8,848 meters in the Himalayas.',
          hints: ['Everest.'],
        },
        {
          diff: 'intermediate',
          q: 'Which river is the longest river in the world?',
          opts: [{ id: 'A', t: 'Amazon River' }, { id: 'B', t: 'Nile River' }, { id: 'C', t: 'Yangtze River' }, { id: 'D', t: 'Mississippi River' }],
          ans: 'B',
          exp: 'The Nile in Africa is traditionally recognized as the longest river (~6,650 km).',
          hints: ['Flows through Egypt.'],
        },
        {
          diff: 'intermediate',
          q: 'What is the capital of Japan?',
          opts: [{ id: 'A', t: 'Kyoto' }, { id: 'B', t: 'Tokyo' }, { id: 'C', t: 'Osaka' }, { id: 'D', t: 'Seoul' }],
          ans: 'B',
          exp: 'Tokyo is the bustling capital of Japan.',
          hints: ['Anagram of Kyoto.'],
        },
        {
          diff: 'intermediate',
          q: 'Which is the largest country in the world by land area?',
          opts: [{ id: 'A', t: 'Canada' }, { id: 'B', t: 'Russia' }, { id: 'C', t: 'China' }, { id: 'D', t: 'United States' }],
          ans: 'B',
          exp: 'Russia spans over 17 million square kilometers across Europe and Asia.',
          hints: ['Spans 11 time zones.'],
        },
        {
          diff: 'intermediate',
          q: 'The imaginary line dividing Earth into the Northern and Southern Hemispheres is:',
          opts: [{ id: 'A', t: 'Tropic of Cancer' }, { id: 'B', t: 'Equator' }, { id: 'C', t: 'Prime Meridian' }, { id: 'D', t: 'Arctic Circle' }],
          ans: 'B',
          exp: 'The Equator is at 0 degrees latitude.',
          hints: ['Equal halves = Equator.'],
        },
        // Expert
        {
          diff: 'expert',
          q: 'Which country is known as the "Land of the Midnight Sun"?',
          opts: [{ id: 'A', t: 'Sweden' }, { id: 'B', t: 'Norway' }, { id: 'C', t: 'Finland' }, { id: 'D', t: 'Iceland' }],
          ans: 'B',
          exp: 'Norway\'s northern territories experience daylight 24 hours during summer.',
          hints: ['Fjords and Vikings.'],
        },
        {
          diff: 'expert',
          q: 'What is the capital of Australia?',
          opts: [{ id: 'A', t: 'Sydney' }, { id: 'B', t: 'Canberra' }, { id: 'C', t: 'Melbourne' }, { id: 'D', t: 'Brisbane' }],
          ans: 'B',
          exp: 'Canberra is Australia\'s purpose-built capital city (not Sydney!).',
          hints: ['Often confused with Sydney, starts with C.'],
        },
        {
          diff: 'expert',
          q: 'Which is the smallest country in the world by land area?',
          opts: [{ id: 'A', t: 'Monaco' }, { id: 'B', t: 'Vatican City' }, { id: 'C', t: 'San Marino' }, { id: 'D', t: 'Liechtenstein' }],
          ans: 'B',
          exp: 'Vatican City is an independent city-state enclave within Rome, under 0.5 sq km.',
          hints: ['Home to the Pope.'],
        },
        {
          diff: 'expert',
          q: 'Which desert is the largest hot desert on Earth?',
          opts: [{ id: 'A', t: 'Gobi Desert' }, { id: 'B', t: 'Sahara Desert' }, { id: 'C', t: 'Kalahari Desert' }, { id: 'D', t: 'Thar Desert' }],
          ans: 'B',
          exp: 'The Sahara spans North Africa across ~9 million sq km.',
          hints: ['Sahara.'],
        },
        {
          diff: 'expert',
          q: 'The Great Barrier Reef, the world\'s largest coral reef system, is off the coast of:',
          opts: [{ id: 'A', t: 'Brazil' }, { id: 'B', t: 'Australia' }, { id: 'C', t: 'South Africa' }, { id: 'D', t: 'Indonesia' }],
          ans: 'B',
          exp: 'The Great Barrier Reef is located in the Coral Sea off Queensland, Australia.',
          hints: ['Down under.'],
        },
      ],
    },
  ];

  // 4. Upsert topics and seed questions
  let totalQuestions = 0;
  for (const item of curriculum) {
    const subject = subjects[item.subjectCode];
    if (!subject) continue;

    const topic = await prisma.adaptiveTopic.upsert({
      where: {
        subjectId_code: {
          subjectId: subject.id,
          code: item.topicCode,
        },
      },
      update: { name: item.topicName, grade: 3 },
      create: {
        subjectId: subject.id,
        code: item.topicCode,
        name: item.topicName,
        grade: 3,
      },
    });

    console.log(`📚 Topic: [${item.subjectCode}] ${item.topicName} (ID: ${topic.id})`);

    for (const q of item.questions) {
      const existing = await prisma.adaptiveQuestion.findFirst({
        where: {
          topicId: topic.id,
          difficulty: q.diff,
          grade: 3,
          content: {
            path: ['question'],
            equals: q.q,
          },
        },
      });

      if (!existing) {
        await prisma.adaptiveQuestion.create({
          data: {
            topicId: topic.id,
            grade: 3,
            difficulty: q.diff,
            questionType: 'multiple_choice',
            content: {
              question: q.q,
              options: q.opts.map((o) => ({ option_id: o.id, text: o.t })),
            },
            answerKey: {
              correct_option_id: q.ans,
              explanation: q.exp,
              hints: q.hints,
            },
            metadata: { tags: [item.topicCode.toLowerCase(), q.diff] },
            status: 'published',
          },
        });
        totalQuestions++;
      }
    }
  }

  console.log(`\n🎉 Successfully verified and inserted ${totalQuestions} fresh questions across all subjects!`);
  await prisma.$disconnect();
}

seedFullCurriculum().catch((err) => {
  console.error('❌ Seeding error:', err);
  process.exit(1);
});

