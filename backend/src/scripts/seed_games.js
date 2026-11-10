/**
 * seed_games.js — Seeds PostgreSQL with:
 *  - 3 Master Game documents (Math Puzzle, Word Scramble, Memory Match)
 *  - 10 Levels of Math Puzzle (30 questions with formula lines, hints & explanations)
 *  - 10 Levels of Word Scramble (30 words with emojis & hints)
 *  - 10 Levels of Memory Match (grid configs, star limits, timers & emoji sets)
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { prisma } = require('../prisma');

const gamesData = [
  {
    gameKey: 'math_puzzle',
    title: 'Math Puzzle',
    description: '10 stages of logic algebra, patterns & riddles.',
    emoji: '🧮',
    category: '10 Levels',
    color: '#38bdf8',
    gradientColors: ['#6C63FF', '#9B59B6'],
    totalLevels: 10,
    order: 1,
  },
  {
    gameKey: 'word_scramble',
    title: 'Word Scramble',
    description: 'Unscramble mixed letters with smart hints.',
    emoji: '🔤',
    category: '10 Levels',
    color: '#fbbf24',
    gradientColors: ['#F39C12', '#E74C3C'],
    totalLevels: 10,
    order: 2,
  },
  {
    gameKey: 'memory_match',
    title: 'Memory Match',
    description: 'Flip, match pairs and train visual recall.',
    emoji: '🃏',
    category: '10 Levels',
    color: '#22c55e',
    gradientColors: ['#2ECC71', '#1ABC9C'],
    totalLevels: 10,
    order: 3,
  },
];

const mathLevelsData = [
  {
    levelNumber: 1,
    title: 'Apple Algebra',
    description: 'Single symbol logic',
    icon: '🍎',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Apple Addition 🍎',
        subtitle: 'Find the hidden value',
        visualLines: ['🍎 + 🍎 = 10', '🍎 + 🍎 + 🍎 = ?'],
        question: 'What is the sum?',
        options: ['15', '20', '12', '18'],
        correctIndex: 0,
        explanation: '🍎 = 5 (10 ÷ 2). So 5 + 5 + 5 = 15!',
        hint: 'Each apple has the same number value.',
      },
      {
        type: 'numberPattern',
        title: 'Counting by Twos ✌️',
        subtitle: 'Complete the pattern',
        visualLines: ['2 ,  4 ,  6 ,  8 ,  ?'],
        question: 'What is the next number?',
        options: ['9', '10', '12', '14'],
        correctIndex: 1,
        explanation: 'Add 2 each step: 8 + 2 = 10!',
        hint: 'Skip count by 2!',
      },
      {
        type: 'mathRiddle',
        title: 'Apple Basket 🧺',
        subtitle: 'Think about what you have',
        visualLines: ['You have 6 apples.', 'You take away 2 apples.'],
        question: 'How many apples do YOU have?',
        options: ['4 apples', '2 apples', '6 apples', '0 apples'],
        correctIndex: 1,
        explanation: 'You took 2 apples, so YOU have 2 apples! (4 are left in the basket)',
        hint: 'The question asks how many you took!',
      },
    ],
  },
  {
    levelNumber: 2,
    title: 'Fives Parade',
    description: '2-symbol deduction',
    icon: '🍌',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Fruit Duo 🍎🍌',
        subtitle: 'Two different fruits',
        visualLines: ['🍎 + 🍎 = 8', '🍎 + 🍌 = 7', '🍌 + 🍌 = ?'],
        question: 'Calculate the total of two bananas:',
        options: ['6', '8', '5', '7'],
        correctIndex: 0,
        explanation: '🍎 = 4 (8 ÷ 2). 🍌 = 3 (7 - 4). So 3 + 3 = 6!',
        hint: 'Find 🍎 first, then find 🍌.',
      },
      {
        type: 'numberPattern',
        title: 'Fives Parade 🖐️',
        subtitle: 'Spot the pattern',
        visualLines: ['5 ,  10 ,  15 ,  20 ,  25 ,  ?'],
        question: 'What comes next?',
        options: ['35', '30', '40', '28'],
        correctIndex: 1,
        explanation: 'Add 5 each time: 25 + 5 = 30!',
        hint: 'Count in 5s.',
      },
      {
        type: 'mathRiddle',
        title: 'The Cat Riddle 🐱',
        subtitle: 'Logical rate challenge',
        visualLines: ['3 cats catch 3 mice in 3 minutes.'],
        question: 'How many cats catch 100 mice in 100 minutes?',
        options: ['100 cats', '3 cats', '33 cats', '1 cat'],
        correctIndex: 1,
        explanation: '1 cat catches 1 mouse every 3 minutes. So 3 cats catch 100 mice in 100 minutes!',
        hint: 'How many mice does 1 cat catch in 3 minutes?',
      },
    ],
  },
  {
    levelNumber: 3,
    title: 'Space Velocity',
    description: 'Doubling & order of ops',
    icon: '🚀',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Space Rocket Value 🚀',
        subtitle: 'Discover the missing star',
        visualLines: ['🚀 + 🚀 = 12', '🚀 + 🌟 = 10', '🌟 × 🌟 = ?'],
        question: 'What is 🌟 × 🌟?',
        options: ['16', '20', '12', '24'],
        correctIndex: 0,
        explanation: '🚀 = 6. 🌟 = 4 (10 - 6). So 4 × 4 = 16!',
        hint: 'Subtract rocket value from 10.',
      },
      {
        type: 'numberPattern',
        title: 'Doubling Jump 🦘',
        subtitle: 'Exponential sequence',
        visualLines: ['2 → 4 → 8 → 16 → 32 → ?'],
        question: 'What is the next number?',
        options: ['48', '64', '54', '60'],
        correctIndex: 1,
        explanation: 'Multiply by 2 each step: 32 × 2 = 64!',
        hint: 'Each number is doubled!',
      },
      {
        type: 'mathRiddle',
        title: 'Division Trick ⚡',
        subtitle: 'Listen closely',
        visualLines: ['Divide 30 by half (1/2)', 'and then add 10.'],
        question: 'What is the answer?',
        options: ['25', '40', '70', '15'],
        correctIndex: 2,
        explanation: 'Dividing by half (1/2 or 0.5) is multiplying by 2!\n30 ÷ 0.5 = 60, + 10 = 70!',
        hint: 'Dividing by 1/2 doubles the number!',
      },
    ],
  },
  {
    levelNumber: 4,
    title: 'Fruit Salad',
    description: '3-variable logic',
    icon: '🥗',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Trio Fruit Salad 🥗',
        subtitle: 'Three items to solve',
        visualLines: ['🍎 + 🍎 = 10', '🍎 + 🍌 = 8', '🍌 + 🍇 = 6', '🍎 + 🍌 + 🍇 = ?'],
        question: 'What is the grand total?',
        options: ['11', '12', '14', '10'],
        correctIndex: 0,
        explanation: '🍎 = 5, 🍌 = 3, 🍇 = 3.\n5 + 3 + 3 = 11!',
        hint: 'Solve top to bottom line by line.',
      },
      {
        type: 'numberPattern',
        title: 'Step by Step 📈',
        subtitle: 'Growing gaps',
        visualLines: ['3  (+3)  6  (+5)  11  (+7)  18  (+9)  ?'],
        question: 'What is the missing number?',
        options: ['25', '27', '29', '26'],
        correctIndex: 1,
        explanation: 'The difference increases by 2 each time (+3, +5, +7, +9).\n18 + 9 = 27!',
        hint: 'The jump increases by 2 (+3, +5, +7, +9...)',
      },
      {
        type: 'mathRiddle',
        title: 'Odd to Even 🔤',
        subtitle: 'Wordplay math riddle',
        visualLines: ['I am an odd number.', 'Take away ONE letter and I become EVEN.'],
        question: 'What number am I?',
        options: ['SEVEN (7)', 'NINE (9)', 'ELEVEN (11)', 'THREE (3)'],
        correctIndex: 0,
        explanation: 'SEVEN - "S" = EVEN!',
        hint: 'Think about how the number is spelled!',
      },
    ],
  },
  {
    levelNumber: 5,
    title: 'Square Matrix',
    description: 'Powers & Fibonacci',
    icon: '🧩',
    puzzles: [
      {
        type: 'logicGrid',
        title: 'Square Matrix 🧩',
        subtitle: 'Find the relationship',
        visualLines: ['[ 2 ]   [ 4 ]', '[ 3 ]   [ 9 ]', '[ 4 ]   [ 16 ]', '[ 5 ]   [ ? ]'],
        question: 'What is the missing number?',
        options: ['20', '25', '30', '15'],
        correctIndex: 1,
        explanation: 'Each right number is n²: 5² = 25!',
        hint: 'Multiply the left number by itself.',
      },
      {
        type: 'numberPattern',
        title: 'Fibonacci Trail 🌀',
        subtitle: 'Sum of previous two numbers',
        visualLines: ['1 , 1 , 2 , 3 , 5 , 8 , 13 , ?'],
        question: 'What comes next?',
        options: ['18', '21', '20', '24'],
        correctIndex: 1,
        explanation: '8 + 13 = 21!',
        hint: 'Add the last two numbers together.',
      },
      {
        type: 'symbolAlgebra',
        title: 'PEMDAS Order ⚠️',
        subtitle: 'Multiplication first!',
        visualLines: ['🛸 = 3', '🌟 = 4', '🚀 = 6', '🚀 + 🛸 × 🌟 = ?'],
        question: 'Calculate the expression:',
        options: ['36', '18', '24', '42'],
        correctIndex: 1,
        explanation: 'Multiply first: 3 × 4 = 12, then 6 + 12 = 18!',
        hint: 'Multiplication happens before addition.',
      },
    ],
  },
  {
    levelNumber: 6,
    title: 'Crowns & Gems',
    description: 'Alternating chains',
    icon: '👑',
    puzzles: [
      {
        type: 'numberPattern',
        title: 'Alternating Series ⚡',
        subtitle: '+4 then -1',
        visualLines: ['2 (+4) 6 (-1) 5 (+4) 9 (-1) 8 (+4) ?'],
        question: 'What is the next number in the chain?',
        options: ['12', '10', '11', '14'],
        correctIndex: 0,
        explanation: 'Pattern is +4, -1, +4, -1, +4. 8 + 4 = 12!',
        hint: 'Look at the two alternating operations.',
      },
      {
        type: 'symbolAlgebra',
        title: 'Crowns and Gems 👑',
        subtitle: 'Deduce the gem value',
        visualLines: ['👑 + 👑 + 👑 = 30', '👑 + 💎 = 15', '💎 × 💎 = ?'],
        question: 'Calculate 💎 × 💎:',
        options: ['20', '25', '10', '30'],
        correctIndex: 1,
        explanation: '👑 = 10. 💎 = 5 (15 - 10). So 5 × 5 = 25!',
        hint: '👑 = 30 ÷ 3.',
      },
      {
        type: 'mathRiddle',
        title: 'The Heavy Feather 🪶',
        subtitle: 'Weight perception',
        visualLines: ['1 kg of Feathers  vs  1 kg of Iron'],
        question: 'Which one weighs more?',
        options: ['Iron', 'Feathers', 'Both weigh the same', 'Depends on volume'],
        correctIndex: 2,
        explanation: 'Both weigh exactly 1 kg, so they are equal in weight!',
        hint: 'Check the units: 1 kg is 1 kg!',
      },
    ],
  },
  {
    levelNumber: 7,
    title: 'Cube Matrix',
    description: 'Powers of 3 & primes',
    icon: '🧊',
    puzzles: [
      {
        type: 'logicGrid',
        title: 'Cube Matrix 🧊',
        subtitle: 'Powers of 3',
        visualLines: ['[ 2 ]  [ 4 ]  [ 8 ]', '[ 3 ]  [ 9 ]  [ 27 ]', '[ 4 ]  [ 16 ] [ ? ]'],
        question: 'Find the missing power in the 3rd row:',
        options: ['32', '48', '64', '54'],
        correctIndex: 2,
        explanation: 'Row 3: 4¹, 4²=16, 4³=64!',
        hint: 'Multiply 16 by 4.',
      },
      {
        type: 'numberPattern',
        title: 'Prime Numbers 🌟',
        subtitle: 'Numbers with only 2 factors',
        visualLines: ['2 ,  3 ,  5 ,  7 ,  11 ,  13 ,  ?'],
        question: 'What is the next prime number?',
        options: ['15', '17', '19', '14'],
        correctIndex: 1,
        explanation: '17 is the next prime number (cannot be divided evenly by anything except 1 and 17).',
        hint: '15 is 3×5, so it is not prime. What about 17?',
      },
      {
        type: 'symbolAlgebra',
        title: 'Pizza Math 🍕',
        subtitle: 'Find the missing slice',
        visualLines: ['🍕 + 🍕 = 16', '🍕 - 🍟 = 3', '🍟 × 🍕 = ?'],
        question: 'What is 🍟 × 🍕?',
        options: ['35', '40', '45', '30'],
        correctIndex: 1,
        explanation: '🍕 = 8. 🍟 = 5 (8 - 3). So 5 × 8 = 40!',
        hint: 'Find 🍕 = 16 ÷ 2.',
      },
    ],
  },
  {
    levelNumber: 8,
    title: 'Hero Power',
    description: 'Tricky word problems',
    icon: '🦸',
    puzzles: [
      {
        type: 'numberPattern',
        title: 'Descending Steps 📉',
        subtitle: 'Subtractions grow',
        visualLines: ['100 (-10) 90 (-9) 81 (-8) 73 (-7) ?'],
        question: 'What comes next?',
        options: ['65', '66', '67', '64'],
        correctIndex: 1,
        explanation: 'Subtract 7: 73 - 7 = 66!',
        hint: 'The subtraction amount decreases by 1 each time.',
      },
      {
        type: 'symbolAlgebra',
        title: 'Hero Power 🦸',
        subtitle: 'Combined variables',
        visualLines: ['🦸 + 🦸 = 20', '🦸 + ⚡ = 16', '⚡ + 🛡️ = 10', '🦸 + ⚡ + 🛡️ = ?'],
        question: 'Calculate total hero power:',
        options: ['20', '18', '22', '24'],
        correctIndex: 0,
        explanation: '🦸 = 10. ⚡ = 6. 🛡️ = 4. 10 + 6 + 4 = 20!',
        hint: 'Find ⚡ from line 2, then 🛡️ from line 3.',
      },
      {
        type: 'mathRiddle',
        title: 'The Bat & Ball ⚾',
        subtitle: 'Classic tricky question',
        visualLines: ['A bat and ball cost $1.10 together.', 'The bat costs $1.00 MORE than the ball.'],
        question: 'How much does the ball cost?',
        options: ['$0.10', '$0.05', '$0.01', '$0.15'],
        correctIndex: 1,
        explanation: 'If ball = $0.05, bat = $1.05 ($1.00 more). Total = $1.10!',
        hint: 'If the ball was 10¢, the bat ($1.10) would make the total $1.20!',
      },
    ],
  },
  {
    levelNumber: 9,
    title: 'Power of Fives',
    description: 'Exponential logic',
    icon: '💎',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Mega Algebra 💎',
        subtitle: 'Multiplication & Subtraction',
        visualLines: ['💎 × 💎 = 36', '💎 + 🔮 = 15', '🔮 - 🪄 = 4', '💎 × 🪄 = ?'],
        question: 'Calculate 💎 × 🪄:',
        options: ['30', '35', '25', '20'],
        correctIndex: 0,
        explanation: '💎 = 6. 🔮 = 9 (15-6). 🪄 = 5 (9-4). So 6 × 5 = 30!',
        hint: '💎 is the square root of 36.',
      },
      {
        type: 'numberPattern',
        title: 'Power of Fives 🖐️',
        subtitle: 'Exponential power',
        visualLines: ['5¹=5 ,  5²=25 ,  5³=125 ,  5⁴=?'],
        question: 'What is 5 to the power of 4?',
        options: ['500', '625', '550', '600'],
        correctIndex: 1,
        explanation: '125 × 5 = 625!',
        hint: 'Multiply 125 by 5.',
      },
      {
        type: 'mathRiddle',
        title: 'Family Brothers 👨‍👩‍👧‍👦',
        subtitle: 'Count the siblings',
        visualLines: ['A man has 6 sons.', 'Each son has 1 sister.'],
        question: 'How many children does the man have in total?',
        options: ['12 children', '7 children', '6 children', '8 children'],
        correctIndex: 1,
        explanation: 'All 6 brothers share the SAME 1 sister! So 6 sons + 1 daughter = 7 children!',
        hint: 'All sons share the same sister.',
      },
    ],
  },
  {
    levelNumber: 10,
    title: 'Grand Master',
    description: 'Magic squares & clock riddles',
    icon: '🏆',
    puzzles: [
      {
        type: 'symbolAlgebra',
        title: 'Master Grand Challenge 👑',
        subtitle: 'Ultimate algebra showdown',
        visualLines: ['👑 × 👑 = 64', '👑 + 🛡️ = 15', '🛡️ × 🗡️ = 21', '👑 + 🛡️ × 🗡️ = ?'],
        question: 'Find the final master value:',
        options: ['29', '45', '35', '56'],
        correctIndex: 0,
        explanation: '👑 = 8, 🛡️ = 7, 🗡️ = 3.\nMultiply first: 7 × 3 = 21. Then 8 + 21 = 29!',
        hint: 'Remember PEMDAS order of operations!',
      },
      {
        type: 'logicGrid',
        title: 'Magic Logic Square 🔲',
        subtitle: 'Row sums equal 15',
        visualLines: ['[ 8 ]  [ 1 ]  [ 6 ]  = 15', '[ 3 ]  [ 5 ]  [ 7 ]  = 15', '[ 4 ]  [ 9 ]  [ ? ]  = 15'],
        question: 'What number completes the 3rd row?',
        options: ['2', '3', '1', '5'],
        correctIndex: 0,
        explanation: '4 + 9 = 13. To make 15, we need 2! (15 - 13 = 2)',
        hint: 'Add 4 + 9, then subtract from 15.',
      },
      {
        type: 'mathRiddle',
        title: 'The Lightning Clock ⏰',
        subtitle: 'Clock math puzzle',
        visualLines: ["A clock takes 3 seconds to strike 3 o'clock."],
        question: "How many seconds will it take to strike 6 o'clock?",
        options: ['6 seconds', '7.5 seconds', '9 seconds', '5 seconds'],
        correctIndex: 1,
        explanation: 'Between 3 strikes there are 2 intervals (1.5s each). For 6 strikes there are 5 intervals = 5 × 1.5 = 7.5 seconds!',
        hint: 'Count the time between the strikes (the intervals)!',
      },
    ],
  },
];

const wordLevelsData = [
  {
    levelNumber: 1,
    title: 'Baby Animals',
    description: '3-letter words',
    icon: '🐱',
    puzzles: [
      { word: 'CAT', hint: 'Playful pet that purrs', emoji: '🐱', category: 'Animals' },
      { word: 'SUN', hint: 'Shines bright in daytime', emoji: '☀️', category: 'Nature' },
      { word: 'DOG', hint: "Man's best furry friend", emoji: '🐶', category: 'Animals' },
    ],
  },
  {
    levelNumber: 2,
    title: 'Night Sky',
    description: '4-letter words',
    icon: '⭐',
    puzzles: [
      { word: 'STAR', hint: 'Twinkles in the night sky', emoji: '⭐', category: 'Space' },
      { word: 'BIRD', hint: 'Has wings and can fly high', emoji: '🐦', category: 'Animals' },
      { word: 'MOON', hint: 'Glows softly in the night', emoji: '🌙', category: 'Space' },
    ],
  },
  {
    levelNumber: 3,
    title: 'Sweet Orchard',
    description: '5-letter fruits',
    icon: '🍎',
    puzzles: [
      { word: 'APPLE', hint: 'Sweet red or green fruit', emoji: '🍎', category: 'Fruits' },
      { word: 'MANGO', hint: 'Delicious tropical yellow fruit', emoji: '🥭', category: 'Fruits' },
      { word: 'LEMON', hint: 'Sour citrus yellow fruit', emoji: '🍋', category: 'Fruits' },
    ],
  },
  {
    levelNumber: 4,
    title: 'Cosmic Voyage',
    description: 'Space & planets',
    icon: '🚀',
    puzzles: [
      { word: 'EARTH', hint: 'The planet we all live on', emoji: '🌍', category: 'Space' },
      { word: 'ROCKET', hint: 'Flies fast into outer space', emoji: '🚀', category: 'Space' },
      { word: 'COMET', hint: 'Icy space rock with a tail', emoji: '☄️', category: 'Space' },
    ],
  },
  {
    levelNumber: 5,
    title: 'Wild Habitats',
    description: 'Nature & islands',
    icon: '🌴',
    puzzles: [
      { word: 'OCEAN', hint: 'Huge body of deep blue water', emoji: '🌊', category: 'Nature' },
      { word: 'FOREST', hint: 'Full of tall green trees', emoji: '🌲', category: 'Nature' },
      { word: 'ISLAND', hint: 'Land surrounded by water', emoji: '🏝️', category: 'Geography' },
    ],
  },
  {
    levelNumber: 6,
    title: 'School Desk',
    description: 'Pencils & puzzles',
    icon: '✏️',
    puzzles: [
      { word: 'PENCIL', hint: 'Used for writing and drawing', emoji: '✏️', category: 'School' },
      { word: 'PUZZLE', hint: 'Game of brain and logic pieces', emoji: '🧩', category: 'Games' },
      { word: 'ERASER', hint: 'Cleans pencil marks away', emoji: '🧼', category: 'School' },
    ],
  },
  {
    levelNumber: 7,
    title: 'Cyber Zone',
    description: 'Robots & laptops',
    icon: '💻',
    puzzles: [
      { word: 'ROBOT', hint: 'Smart machine that helps us', emoji: '🤖', category: 'Technology' },
      { word: 'LAPTOP', hint: 'Portable personal computer', emoji: '💻', category: 'Technology' },
      { word: 'CAMERA', hint: 'Takes photos and videos', emoji: '📷', category: 'Technology' },
    ],
  },
  {
    levelNumber: 8,
    title: 'Melody Hall',
    description: 'Guitars & pianos',
    icon: '🎸',
    puzzles: [
      { word: 'GUITAR', hint: 'Musical instrument with strings', emoji: '🎸', category: 'Music' },
      { word: 'VIOLIN', hint: 'Played with a wooden bow', emoji: '🎻', category: 'Music' },
      { word: 'PIANOS', hint: 'Keyboard with black and white keys', emoji: '🎹', category: 'Music' },
    ],
  },
  {
    levelNumber: 9,
    title: 'Mythic Realm',
    description: 'Dragons & wizards',
    icon: '🐉',
    puzzles: [
      { word: 'DRAGON', hint: 'Mythical fire-breathing creature', emoji: '🐉', category: 'Fantasy' },
      { word: 'WIZARD', hint: 'Casts magical spells with a wand', emoji: '🧙‍♂️', category: 'Fantasy' },
      { word: 'KNIGHT', hint: 'Wears armor and holds a shield', emoji: '🛡️', category: 'History' },
    ],
  },
  {
    levelNumber: 10,
    title: 'Word Champion',
    description: '8-letter master vocabulary',
    icon: '🏆',
    puzzles: [
      { word: 'CHAMPION', hint: 'Winner of the grand trophy', emoji: '🏆', category: 'Victory' },
      { word: 'EXPLORER', hint: 'Travels to discover new places', emoji: '🧭', category: 'Adventure' },
      { word: 'TREASURE', hint: 'Hidden chest of gold and jewels', emoji: '💎', category: 'Discovery' },
    ],
  },
];

const memoryLevelsData = [
  {
    levelNumber: 1,
    title: 'Starter Zoo',
    description: '2x2 grid (2 pairs)',
    icon: '🦁',
    config: {
      pairsCount: 2,
      crossAxisCount: 2,
      themeEmojis: ['🦁', '🐼'],
      maxMovesFor3Stars: 3,
      maxMovesFor2Stars: 5,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 2,
    title: 'Starlight Trio',
    description: '2x3 grid (3 pairs)',
    icon: '🚀',
    config: {
      pairsCount: 3,
      crossAxisCount: 3,
      themeEmojis: ['🦁', '🚀', '🌟'],
      maxMovesFor3Stars: 4,
      maxMovesFor2Stars: 6,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 3,
    title: 'Forest Friends',
    description: '2x4 grid (4 pairs)',
    icon: '🐰',
    config: {
      pairsCount: 4,
      crossAxisCount: 4,
      themeEmojis: ['🐱', '🐶', '🐰', '🦊'],
      maxMovesFor3Stars: 6,
      maxMovesFor2Stars: 9,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 4,
    title: 'Fruit Blitz',
    description: '2x4 grid · 25s timer',
    icon: '🍓',
    config: {
      pairsCount: 4,
      crossAxisCount: 4,
      themeEmojis: ['🍎', '🍌', '🍇', '🍓'],
      maxMovesFor3Stars: 5,
      maxMovesFor2Stars: 8,
      timeLimitSeconds: 25,
    },
  },
  {
    levelNumber: 5,
    title: 'Orbit Galaxy',
    description: '3x4 grid (6 pairs)',
    icon: '🛸',
    config: {
      pairsCount: 6,
      crossAxisCount: 3,
      themeEmojis: ['🚀', '🛸', '🌍', '🌙', '⭐', '☄️'],
      maxMovesFor3Stars: 8,
      maxMovesFor2Stars: 12,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 6,
    title: 'Yummy Snacks',
    description: '3x4 grid (6 pairs)',
    icon: '🍕',
    config: {
      pairsCount: 6,
      crossAxisCount: 3,
      themeEmojis: ['🍕', '🍔', '🍟', '🍦', '🍩', '🍫'],
      maxMovesFor3Stars: 8,
      maxMovesFor2Stars: 12,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 7,
    title: 'Arcade Mania',
    description: '3x4 grid · 35s timer',
    icon: '🎮',
    config: {
      pairsCount: 6,
      crossAxisCount: 3,
      themeEmojis: ['🎨', '🎭', '🎪', '🎯', '🎳', '🎮'],
      maxMovesFor3Stars: 9,
      maxMovesFor2Stars: 13,
      timeLimitSeconds: 35,
    },
  },
  {
    levelNumber: 8,
    title: 'Silicon City',
    description: '4x4 grid (8 pairs)',
    icon: '🤖',
    config: {
      pairsCount: 8,
      crossAxisCount: 4,
      themeEmojis: ['💻', '🤖', '🕹️', '📷', '📱', '🔋', '⌚', '📺'],
      maxMovesFor3Stars: 12,
      maxMovesFor2Stars: 16,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 9,
    title: 'Stadium League',
    description: '4x4 grid (8 pairs)',
    icon: '⚽',
    config: {
      pairsCount: 8,
      crossAxisCount: 4,
      themeEmojis: ['⚽', '🏀', '🏈', '🎾', '🏐', '🎱', '🏓', '🥊'],
      maxMovesFor3Stars: 12,
      maxMovesFor2Stars: 16,
      timeLimitSeconds: null,
    },
  },
  {
    levelNumber: 10,
    title: 'Crown Jewels',
    description: '4x4 grid · 45s speedrun',
    icon: '👑',
    config: {
      pairsCount: 8,
      crossAxisCount: 4,
      themeEmojis: ['👑', '💎', '🏆', '🥇', '🔮', '🪄', '🛡️', '⚔️'],
      maxMovesFor3Stars: 11,
      maxMovesFor2Stars: 15,
      timeLimitSeconds: 45,
    },
  },
];

async function seedGames() {
  const isStandalone = require.main === module;

  console.log('🎮 Seeding Games...');
  await prisma.game.deleteMany({});
  for (const g of gamesData) {
    await prisma.game.create({ data: g });
  }
  console.log(`   Added ${gamesData.length} games to PostgreSQL.`);

  console.log('🧮 Seeding Math Puzzle Levels...');
  await prisma.mathPuzzleLevel.deleteMany({});
  for (const m of mathLevelsData) {
    await prisma.mathPuzzleLevel.create({ data: m });
  }
  console.log(`   Added ${mathLevelsData.length} levels to PostgreSQL.`);

  console.log('🔤 Seeding Word Scramble Levels...');
  await prisma.wordScrambleLevel.deleteMany({});
  for (const w of wordLevelsData) {
    await prisma.wordScrambleLevel.create({ data: w });
  }
  console.log(`   Added ${wordLevelsData.length} levels to PostgreSQL.`);

  console.log('🃏 Seeding Memory Match Levels...');
  await prisma.memoryMatchLevel.deleteMany({});
  for (const mem of memoryLevelsData) {
    await prisma.memoryMatchLevel.create({ data: mem });
  }
  console.log(`   Added ${memoryLevelsData.length} levels to PostgreSQL.`);

  if (isStandalone) {
    await prisma.$disconnect();
    console.log('👋 Seeding complete. Disconnected.');
  }
}

if (require.main === module) {
  seedGames().catch((err) => {
    console.error('❌ Seeding failed:', err);
    process.exit(1);
  });
}

module.exports = seedGames;
