// ─────────────────────────────────────────────────────────────────────────────
// KidDO Quiz — Data models & hardcoded sample questions
// ─────────────────────────────────────────────────────────────────────────────

/// The three question layouts from the UI mockups.
enum QuestionType {
  /// Image on top → 2×2 text option buttons
  imageThenText,

  /// No image → 2×2 text option buttons
  textOnly,

  /// Title on top → 2×2 image option buttons
  imageGrid,

  /// True / False buttons
  trueFalse,
}

class QuizOption {
  final String? text;         // used for imageThenText / textOnly
  final String? imageAsset;   // used for imageGrid

  const QuizOption({this.text, this.imageAsset});
}

class QuizQuestion {
  final String question;
  final QuestionType type;
  final String? questionImageAsset; // displayed in the top card (optional)
  final List<QuizOption> options;   // exactly 4 options
  final int correctIndex;           // 0-based index of correct option

  const QuizQuestion({
    required this.question,
    required this.type,
    required this.options,
    required this.correctIndex,
    this.questionImageAsset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample question banks per subject (5 questions each for MVP)
// Replace / extend with real data from Firestore later.
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, List<QuizQuestion>> kSampleQuestions = {
  'Math': _mathQuestions,
  'GK': _gkQuestions,
  'Science': _scienceQuestions,
  'English': _englishQuestions,
  'Computer': _computerQuestions,
};

// ── Math ──────────────────────────────────────────────────────────────────────
const List<QuizQuestion> _mathQuestions = [
  QuizQuestion(
    question: 'What is 2 + 3?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '4'),
      QuizOption(text: '5'),
      QuizOption(text: '6'),
      QuizOption(text: '7'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is 10 - 4?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '5'),
      QuizOption(text: '6'),
      QuizOption(text: '7'),
      QuizOption(text: '8'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is 3 × 3?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '6'),
      QuizOption(text: '8'),
      QuizOption(text: '9'),
      QuizOption(text: '12'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which is the largest number?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '45'),
      QuizOption(text: '54'),
      QuizOption(text: '39'),
      QuizOption(text: '42'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is 20 ÷ 4?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '4'),
      QuizOption(text: '5'),
      QuizOption(text: '6'),
      QuizOption(text: '8'),
    ],
    correctIndex: 1,
  ),
];

// ── GK ───────────────────────────────────────────────────────────────────────
const List<QuizQuestion> _gkQuestions = [
  QuizQuestion(
    question: 'What is the capital of India?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Mumbai'),
      QuizOption(text: 'New Delhi'),
      QuizOption(text: 'Chennai'),
      QuizOption(text: 'Kolkata'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'How many days are in a week?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '5'),
      QuizOption(text: '6'),
      QuizOption(text: '7'),
      QuizOption(text: '8'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which animal is known as the King of the Jungle?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Tiger'),
      QuizOption(text: 'Elephant'),
      QuizOption(text: 'Lion'),
      QuizOption(text: 'Bear'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which planet is closest to the Sun?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Earth'),
      QuizOption(text: 'Venus'),
      QuizOption(text: 'Mars'),
      QuizOption(text: 'Mercury'),
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'What is the national bird of India?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Sparrow'),
      QuizOption(text: 'Parrot'),
      QuizOption(text: 'Peacock'),
      QuizOption(text: 'Eagle'),
    ],
    correctIndex: 2,
  ),
];

// ── Science ───────────────────────────────────────────────────────────────────
const List<QuizQuestion> _scienceQuestions = [
  QuizQuestion(
    question: 'What do plants need to make food?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Milk'),
      QuizOption(text: 'Sunlight'),
      QuizOption(text: 'Sand'),
      QuizOption(text: 'Ice'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'How many legs does an insect have?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '4'),
      QuizOption(text: '6'),
      QuizOption(text: '8'),
      QuizOption(text: '10'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is the boiling point of water?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: '90°C'),
      QuizOption(text: '100°C'),
      QuizOption(text: '110°C'),
      QuizOption(text: '80°C'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Which gas do plants absorb from the air?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Oxygen'),
      QuizOption(text: 'Nitrogen'),
      QuizOption(text: 'Carbon Dioxide'),
      QuizOption(text: 'Hydrogen'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'What is the largest organ in the human body?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Heart'),
      QuizOption(text: 'Liver'),
      QuizOption(text: 'Brain'),
      QuizOption(text: 'Skin'),
    ],
    correctIndex: 3,
  ),
];

// ── English ───────────────────────────────────────────────────────────────────
const List<QuizQuestion> _englishQuestions = [
  QuizQuestion(
    question: 'Which of these is a vowel?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'B'),
      QuizOption(text: 'C'),
      QuizOption(text: 'E'),
      QuizOption(text: 'D'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'What is the plural of "child"?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Childs'),
      QuizOption(text: 'Childes'),
      QuizOption(text: 'Children'),
      QuizOption(text: 'Childrens'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which word means "happy"?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Sad'),
      QuizOption(text: 'Angry'),
      QuizOption(text: 'Joyful'),
      QuizOption(text: 'Tired'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which sentence is correct?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'He go to school'),
      QuizOption(text: 'He goes to school'),
      QuizOption(text: 'He going school'),
      QuizOption(text: 'He goed school'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is an antonym of "hot"?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Warm'),
      QuizOption(text: 'Cold'),
      QuizOption(text: 'Boiling'),
      QuizOption(text: 'Sunny'),
    ],
    correctIndex: 1,
  ),
];

// ── Computer ──────────────────────────────────────────────────────────────────
const List<QuizQuestion> _computerQuestions = [
  QuizQuestion(
    question: 'What does CPU stand for?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Central Power Unit'),
      QuizOption(text: 'Computer Personal Unit'),
      QuizOption(text: 'Central Processing Unit'),
      QuizOption(text: 'Control Processing Unit'),
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Which device is used for input?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Monitor'),
      QuizOption(text: 'Printer'),
      QuizOption(text: 'Speaker'),
      QuizOption(text: 'Keyboard'),
    ],
    correctIndex: 3,
  ),
  QuizQuestion(
    question: 'What does "www" stand for?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'World Wide Web'),
      QuizOption(text: 'World Web Wide'),
      QuizOption(text: 'Wide World Web'),
      QuizOption(text: 'Web World Wide'),
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'Which of these is a storage device?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Mouse'),
      QuizOption(text: 'Pen Drive'),
      QuizOption(text: 'Monitor'),
      QuizOption(text: 'Keyboard'),
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'What is the full form of RAM?',
    type: QuestionType.textOnly,
    options: [
      QuizOption(text: 'Random Access Memory'),
      QuizOption(text: 'Read Access Memory'),
      QuizOption(text: 'Run Access Memory'),
      QuizOption(text: 'Rapid Access Memory'),
    ],
    correctIndex: 0,
  ),
];
