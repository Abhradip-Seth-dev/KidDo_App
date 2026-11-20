const { prisma } = require('../prisma');

async function seedRichQuizQuestions() {
  console.log('📝 Seeding rich classic QuizQuestions for each unit and quiz...');

  const unitQuizzes = [
    // Math Unit 1: Foundations
    {
      subject: 'Math',
      unitNumber: 1,
      unitName: 'Unit 1: Foundations',
      chapter: 'Chapter 1: Numbers & Counting',
      quizzes: [
        {
          quizName: 'Quiz 1: Practice Challenge',
          questions: [
            { q: 'What is 2 + 3?', opts: ['4', '5', '6', '7'], ans: 1, diff: 'easy' },
            { q: 'Which number comes right after 19?', opts: ['18', '20', '21', '22'], ans: 1, diff: 'easy' },
            { q: 'How many sides does a triangle have?', opts: ['2', '3', '4', '5'], ans: 1, diff: 'easy' },
            { q: 'What is 7 + 4?', opts: ['10', '11', '12', '13'], ans: 1, diff: 'easy' },
          ],
        },
        {
          quizName: 'Quiz 2: Practice Challenge',
          questions: [
            { q: 'What is 10 - 4?', opts: ['5', '6', '7', '8'], ans: 1, diff: 'easy' },
            { q: 'What is 15 - 8?', opts: ['6', '7', '8', '9'], ans: 1, diff: 'easy' },
            { q: 'Subtract 5 from 12:', opts: ['6', '7', '8', '9'], ans: 1, diff: 'easy' },
            { q: 'What is 20 - 11?', opts: ['8', '9', '10', '11'], ans: 1, diff: 'easy' },
          ],
        },
        {
          quizName: 'Quiz 3: Practice Challenge',
          questions: [
            { q: 'What is 3 × 3?', opts: ['6', '8', '9', '12'], ans: 2, diff: 'medium' },
            { q: 'What is 4 × 2?', opts: ['6', '8', '10', '12'], ans: 1, diff: 'medium' },
            { q: 'What is 5 × 3?', opts: ['12', '15', '18', '20'], ans: 1, diff: 'medium' },
            { q: 'Count by 5s: 5, 10, 15, __?', opts: ['18', '20', '25', '30'], ans: 1, diff: 'medium' },
          ],
        },
      ],
    },
    // Math Unit 2: Foundations
    {
      subject: 'Math',
      unitNumber: 2,
      unitName: 'Unit 2: Foundations',
      chapter: 'Chapter 2: Multiplication & Division',
      quizzes: [
        {
          quizName: 'Quiz 1: Practice Challenge',
          questions: [
            { q: 'Which is the largest number?', opts: ['45', '54', '39', '42'], ans: 1, diff: 'medium' },
            { q: 'What is 6 × 4?', opts: ['20', '24', '28', '30'], ans: 1, diff: 'medium' },
            { q: 'What is 7 × 3?', opts: ['18', '21', '24', '27'], ans: 1, diff: 'medium' },
            { q: 'What is 8 × 2?', opts: ['14', '16', '18', '20'], ans: 1, diff: 'medium' },
          ],
        },
        {
          quizName: 'Quiz 2: Practice Challenge',
          questions: [
            { q: 'What is 20 ÷ 4?', opts: ['4', '5', '6', '8'], ans: 1, diff: 'medium' },
            { q: 'What is 18 ÷ 3?', opts: ['5', '6', '7', '8'], ans: 1, diff: 'medium' },
            { q: 'Divide 24 by 6:', opts: ['3', '4', '5', '6'], ans: 1, diff: 'medium' },
            { q: 'What is 30 ÷ 5?', opts: ['5', '6', '7', '8'], ans: 1, diff: 'medium' },
          ],
        },
      ],
    },
    // Science Unit 4: Plants & Insects
    {
      subject: 'Science',
      unitNumber: 4,
      unitName: 'Unit 4: Foundations',
      chapter: 'Chapter 1: Plants & Small Creatures',
      quizzes: [
        {
          quizName: 'Quiz 2: Practice Challenge',
          questions: [
            { q: 'What do plants need to make food?', opts: ['Salt', 'Sunlight & water', 'Darkness', 'Milk'], ans: 1, diff: 'easy' },
            { q: 'Which part of a plant grows underground?', opts: ['Leaf', 'Root', 'Flower', 'Fruit'], ans: 1, diff: 'easy' },
            { q: 'What green chemical helps plants trap sunlight?', opts: ['Sugar', 'Chlorophyll', 'Water', 'Iron'], ans: 1, diff: 'easy' },
          ],
        },
        {
          quizName: 'Quiz 3: Practice Challenge',
          questions: [
            { q: 'How many legs does an insect have?', opts: ['4', '6', '8', '10'], ans: 1, diff: 'easy' },
            { q: 'Which of these is a social insect that lives in a colony?', opts: ['Fly', 'Ant', 'Mosquito', 'Moth'], ans: 1, diff: 'easy' },
            { q: 'Butterflies begin life as a:', opts: ['Pupa', 'Caterpillar (Larva)', 'Beetle', 'Egg'], ans: 3, diff: 'easy' },
          ],
        },
      ],
    },
    // English Unit 6: Foundations
    {
      subject: 'English',
      unitNumber: 6,
      unitName: 'Unit 6: Foundations',
      chapter: 'Chapter 1: Vowels & Words',
      quizzes: [
        {
          quizName: 'Quiz 1: Practice Challenge',
          questions: [
            { q: 'Which of these is a vowel?', opts: ['B', 'E', 'K', 'T'], ans: 1, diff: 'easy' },
            { q: 'Which word starts with a vowel sound?', opts: ['Dog', 'Elephant', 'Cat', 'Ball'], ans: 1, diff: 'easy' },
            { q: 'How many vowels are in the word "ORANGE"?', opts: ['1', '2', '3', '4'], ans: 2, diff: 'easy' },
          ],
        },
        {
          quizName: 'Quiz 2: Practice Challenge',
          questions: [
            { q: 'What is the plural of "child"?', opts: ['Childs', 'Children', 'Childrens', 'Childes'], ans: 1, diff: 'easy' },
            { q: 'What is the plural of "box"?', opts: ['Boxs', 'Boxes', 'Boxen', 'Boxies'], ans: 1, diff: 'easy' },
            { q: 'What is the plural of "tooth"?', opts: ['Tooths', 'Teeth', 'Teethes', 'Toothies'], ans: 1, diff: 'easy' },
          ],
        },
        {
          quizName: 'Quiz 3: Practice Challenge',
          questions: [
            { q: 'Which word means "happy"?', opts: ['Sad', 'Joyful', 'Angry', 'Tired'], ans: 1, diff: 'easy' },
            { q: 'What is the opposite of "brave"?', opts: ['Strong', 'Cowardly', 'Bold', 'Quick'], ans: 1, diff: 'easy' },
            { q: 'A word that describes an action is called a:', opts: ['Noun', 'Verb', 'Pronoun', 'Adverb'], ans: 1, diff: 'easy' },
          ],
        },
      ],
    },
    // GK Unit 2 & 3: Foundations
    {
      subject: 'GK',
      unitNumber: 2,
      unitName: 'Unit 2: Foundations',
      chapter: 'Chapter 1: Geography & World',
      quizzes: [
        {
          quizName: 'Quiz 3: Practice Challenge',
          questions: [
            { q: 'What is the capital of India?', opts: ['Mumbai', 'New Delhi', 'Chennai', 'Kolkata'], ans: 1, diff: 'easy' },
            { q: 'Which is the largest ocean in the world?', opts: ['Indian', 'Pacific', 'Atlantic', 'Arctic'], ans: 1, diff: 'easy' },
            { q: 'How many days are in a leap year?', opts: ['364', '365', '366', '367'], ans: 2, diff: 'easy' },
          ],
        },
      ],
    },
  ];

  let added = 0;
  for (const u of unitQuizzes) {
    for (const qz of u.quizzes) {
      for (const q of qz.questions) {
        const existing = await prisma.quizQuestion.findFirst({
          where: {
            subject: u.subject,
            unitNumber: u.unitNumber,
            quizName: qz.quizName,
            question: q.q,
          },
        });

        if (!existing) {
          await prisma.quizQuestion.create({
            data: {
              subject: u.subject,
              gradeClass: 'Class 3',
              chapter: u.chapter,
              unitNumber: u.unitNumber,
              unitName: u.unitName,
              quizName: qz.quizName,
              question: q.q,
              type: 'MCQ',
              options: q.opts,
              correctAnswer: q.opts[q.ans],
              correctIndex: q.ans,
              difficulty: q.diff,
            },
          });
          added++;
        }
      }
    }
  }

  console.log(`✅ Seeded ${added} distinct questions into classic QuizQuestions table!`);
  await prisma.$disconnect();
}

seedRichQuizQuestions().catch((err) => {
  console.error(err);
  process.exit(1);
});

