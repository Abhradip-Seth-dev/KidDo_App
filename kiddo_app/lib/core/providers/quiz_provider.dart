import 'package:flutter_riverpod/legacy.dart';
import 'package:kiddo_app/features/quiz/quiz_model.dart';
import 'package:kiddo_app/core/services/api_service.dart';
import 'dart:math';

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOption;
  final bool isChecked;
  final int correctCount;
  final int consecutiveCorrect;
  final int totalPoints;
  final int coinsEarned;
  final bool isFinished;
  final bool isLoading;
  final String? error;

  const QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedOption,
    this.isChecked = false,
    this.correctCount = 0,
    this.consecutiveCorrect = 0,
    this.totalPoints = 0,
    this.coinsEarned = 0,
    this.isFinished = false,
    this.isLoading = false,
    this.error,
  });

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedOption,
    bool? isChecked,
    int? correctCount,
    int? consecutiveCorrect,
    int? totalPoints,
    int? coinsEarned,
    bool? isFinished,
    bool? isLoading,
    String? error,
    bool clearSelectedOption = false,
    bool clearError = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption:
          clearSelectedOption ? null : (selectedOption ?? this.selectedOption),
      isChecked: isChecked ?? this.isChecked,
      correctCount: correctCount ?? this.correctCount,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      totalPoints: totalPoints ?? this.totalPoints,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  QuizQuestion get currentQuestion => questions[currentIndex];
  bool get isCorrect => selectedOption == currentQuestion.correctIndex;
}

class QuizNotifier extends StateNotifier<QuizState> {
  final ApiService _api = ApiService();
  final Random _random = Random();

  QuizNotifier() : super(const QuizState(questions: []));

  /// Loads questions from MongoDB via Node.js API and shuffles options randomly
  Future<void> loadQuestionsFromApi({
    required String subjectName,
    int? unitNumber,
    String? quizName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final query = <String, dynamic>{'subject': subjectName};
      if (unitNumber != null) query['unit'] = unitNumber.toString();
      if (quizName != null) query['quiz'] = quizName;

      final response = await _api.get('/quiz/questions', queryParams: query);
      final rawList = response.data['questions'] as List<dynamic>;

      final loadedQuestions = rawList.map((q) {
        final rawOptions = (q['options'] as List<dynamic>)
            .map((opt) => opt.toString())
            .toList();

        final correctAnswerText = q['correctAnswer']?.toString() ??
            (rawOptions.isNotEmpty ? rawOptions[0] : '');

        // Shuffle options so Option A is NOT always correct!
        final List<String> shuffledOptions = List<String>.from(rawOptions);
        shuffledOptions.shuffle(_random);

        // Dynamic correct index recalculation
        int newCorrectIndex = shuffledOptions.indexWhere((opt) =>
            opt.trim().toLowerCase() == correctAnswerText.trim().toLowerCase());
        if (newCorrectIndex == -1) newCorrectIndex = 0;

        final optionsList = shuffledOptions
            .map((opt) => QuizOption(text: opt))
            .toList();

        final rawType = (q['type'] as String?)?.toUpperCase() ?? 'MCQ';
        QuestionType type = QuestionType.textOnly;
        if (rawType == 'IMG_MCQ' && q['imageAsset'] != null) {
          type = QuestionType.imageThenText;
        } else if (rawType == 'TRUE_FALSE') {
          type = QuestionType.trueFalse;
        }

        return QuizQuestion(
          question: q['question'] as String,
          type: type,
          options: optionsList,
          correctIndex: newCorrectIndex,
          questionImageAsset: q['imageAsset'] as String?,
        );
      }).toList();

      state = QuizState(
        questions: loadedQuestions,
        isLoading: false,
      );
    } catch (e) {
      // Fallback to sample questions offline
      final pool = List<QuizQuestion>.from(
        kSampleQuestions[subjectName] ?? kSampleQuestions['GK']!,
      );
      pool.shuffle(_random);
      state = QuizState(
        questions: pool.take(5).toList(),
        isLoading: false,
        error: 'Loaded offline sample questions (${e.toString()})',
      );
    }
  }

  void loadQuestions(String subjectName) {
    loadQuestionsFromApi(subjectName: subjectName);
  }

  void selectOption(int index) {
    if (state.isChecked) return;
    state = state.copyWith(selectedOption: index);
  }

  bool checkAnswer() {
    if (state.selectedOption == null) return false;

    int newCorrect = state.correctCount;
    int newConsecutive = state.consecutiveCorrect;
    int newPoints = state.totalPoints;
    int newCoins = state.coinsEarned;

    if (state.isCorrect) {
      newCorrect++;
      newConsecutive++;
      newPoints += 10;
      newCoins += 2;
    } else {
      newConsecutive = 0;
    }

    state = state.copyWith(
      isChecked: true,
      correctCount: newCorrect,
      consecutiveCorrect: newConsecutive,
      totalPoints: newPoints,
      coinsEarned: newCoins,
    );

    return state.isCorrect;
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedOption: true,
        isChecked: false,
      );
    } else {
      state = state.copyWith(isFinished: true);
    }
  }

  /// Submits the completed quiz attempt to MongoDB API
  Future<Map<String, dynamic>?> submitQuizAttempt({
    required String subjectName,
    required int unitNumber,
    required String quizName,
  }) async {
    try {
      final response = await _api.post('/quiz/submit', data: {
        'subject': subjectName,
        'unitNumber': unitNumber,
        'quizName': quizName,
        'correctCount': state.correctCount,
        'totalQuestions': state.questions.length,
      });
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

final quizProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
