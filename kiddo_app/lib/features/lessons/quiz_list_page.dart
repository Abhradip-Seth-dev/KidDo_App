import 'package:flutter/material.dart';
import 'package:kiddo_app/features/quiz/quiz_page.dart';

class QuizInfo {
  final String quizName;
  final int questionCount;
  final int stars;
  final bool completed;

  QuizInfo({
    required this.quizName,
    required this.questionCount,
    required this.stars,
    required this.completed,
  });
}

class UnitInfo {
  final int unitNumber;
  final String unitName;
  final String status;
  final List<QuizInfo> quizzes;

  UnitInfo({
    required this.unitNumber,
    required this.unitName,
    required this.status,
    required this.quizzes,
  });
}

class QuizListPage extends StatelessWidget {
  final UnitInfo unit;
  final String subjectName;
  final List<Color> gradientColors;

  const QuizListPage({
    super.key,
    required this.unit,
    required this.subjectName,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = gradientColors[0];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit ${unit.unitNumber}',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unit.unitName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Quiz list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: unit.quizzes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final quiz = unit.quizzes[index];
                return _QuizTile(
                  quiz: quiz,
                  unitNumber: unit.unitNumber,
                  subjectName: subjectName,
                  gradientColors: gradientColors,
                  quizIndex: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizTile extends StatelessWidget {
  final QuizInfo quiz;
  final int unitNumber;
  final String subjectName;
  final List<Color> gradientColors;
  final int quizIndex;

  const _QuizTile({
    required this.quiz,
    required this.unitNumber,
    required this.subjectName,
    required this.gradientColors,
    required this.quizIndex,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = gradientColors[0];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quiz.completed ? primaryColor.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: quiz.completed ? primaryColor : Colors.grey[200],
            child: quiz.completed
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$quizIndex',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${quiz.questionCount} Questions',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          if (quiz.completed)
            Row(
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: i < quiz.stars ? Colors.amber : Colors.grey[300],
                ),
              ),
            ),
          const SizedBox(width: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => QuizPage(
                    subjectName: subjectName,
                    subjectColor: primaryColor,
                    unitNumber: unitNumber,
                    quizName: quiz.quizName,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'Start',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
