
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kiddo_app/core/theme/kiddo_colors.dart';
// import 'package:kiddo_app/features/quiz/quiz_model.dart';
// import 'package:kiddo_app/features/quiz/quiz_complete_page.dart';
// import 'package:kiddo_app/features/quiz/streak_celebration_page.dart';
// import 'package:kiddo_app/core/providers/quiz_provider.dart';
// import 'package:kiddo_app/features/home/widgets/mascot_widget.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // QuizPage — 3-type quiz engine
// // Called with: Navigator.push(QuizPage(subjectName, subjectColor))
// // ─────────────────────────────────────────────────────────────────────────────
// class QuizPage extends ConsumerStatefulWidget {
//   final String subjectName;
//   final Color subjectColor;

//   const QuizPage({
//     super.key,
//     required this.subjectName,
//     required this.subjectColor,
//   });

//   @override
//   ConsumerState<QuizPage> createState() => _QuizPageState();
// }

// class _QuizPageState extends ConsumerState<QuizPage>
//     with SingleTickerProviderStateMixin {
//   // ── Feedback animation controller ─────────────────────────────────
//   late AnimationController _feedbackController;
//   late Animation<double> _feedbackScale;

//   @override
//   void initState() {
//     super.initState();
//     _feedbackController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _feedbackScale = CurvedAnimation(
//       parent: _feedbackController,
//       curve: Curves.elasticOut,
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(quizProvider.notifier).loadQuestions(widget.subjectName);
//     });
//   }

//   @override
//   void dispose() {
//     _feedbackController.dispose();
//     super.dispose();
//   }

//   // ── Mascot state derivation ────────────────────────────────────────
//   MascotState _getMascotState(QuizState quizState) {
//     if (!quizState.isChecked) {
//       // Before answering — idle if no streak, excited if on a hot streak
//       if (quizState.consecutiveCorrect >= 5) return MascotState.excited;
//       return MascotState.idle;
//     }
//     // After checking
//     if (quizState.isCorrect) {
//       if (quizState.consecutiveCorrect >= 5) return MascotState.excited;
//       return MascotState.happy;
//     }
//     return MascotState.sad;
//   }

//   // ── Helpers ────────────────────────────────────────────────────────
//   void _onOptionTap(int index) {
//     ref.read(quizProvider.notifier).selectOption(index);
//   }

//   Future<void> _onCheck() async {
//     final notifier = ref.read(quizProvider.notifier);
//     final state = ref.read(quizProvider);
    
//     if (state.selectedOption == null || state.isChecked) return;

//     final isCorrect = notifier.checkAnswer();
//     final newState = ref.read(quizProvider);

//     // Streak milestone celebration
//     if (isCorrect && (newState.consecutiveCorrect == 5 ||
//         newState.consecutiveCorrect == 10 ||
//         newState.consecutiveCorrect == 15)) {
//       await _showStreakCelebration(newState.consecutiveCorrect);
//     }

//     _feedbackController.forward(from: 0);
//     await Future.delayed(const Duration(milliseconds: 1200));

//     if (newState.currentIndex < newState.questions.length - 1) {
//       notifier.nextQuestion();
//       _feedbackController.reset();
//     } else {
//       // Quiz over
//       _goToComplete(newState);
//     }
//   }

//   Future<void> _showStreakCelebration(int count) async {
//     await Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => StreakCelebrationPage(count: count),
//         transitionsBuilder: (_, anim, __, child) =>
//             FadeTransition(opacity: anim, child: child),
//         transitionDuration: const Duration(milliseconds: 300),
//       ),
//     );
//   }

//   void _goToComplete(QuizState finalState) {
//     final accuracy =
//         (finalState.correctCount / finalState.questions.length * 100).round();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuizCompletePage(
//           subjectName: widget.subjectName,
//           subjectColor: widget.subjectColor,
//           totalPoints: finalState.totalPoints,
//           totalIQ: finalState.totalPoints * 2,
//           accuracy: accuracy,
//         ),
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final quizState = ref.watch(quizProvider);

//     if (quizState.questions.isEmpty) {
//       return Scaffold(
//         backgroundColor: kPurpleLight,
//         body: Center(
//           child: CircularProgressIndicator(color: widget.subjectColor),
//         ),
//       );
//     }

//     final currentQuestion = quizState.currentQuestion;

//     return Scaffold(
//       backgroundColor: kPurpleLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTopBar(quizState),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 child: Column(
//                   children: [
//                     // ── Mascot reaction based on quiz streak ────────────────
//                     Center(
//                       child: MascotWidget(
//                         state: _getMascotState(quizState),
//                         size: 90,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     if (currentQuestion.questionImageAsset != null)
//                       _buildQuestionImageCard(currentQuestion),
//                     const SizedBox(height: 18),
//                     _buildQuestionText(currentQuestion),
//                     const SizedBox(height: 22),
//                     _buildOptionsGrid(quizState, currentQuestion),
//                     const SizedBox(height: 30),
//                     _buildFeedbackBubble(quizState),
//                   ],
//                 ),
//               ),
//             ),
//             _buildCheckButton(quizState),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Top bar ────────────────────────────────────────────────────────
//   Widget _buildTopBar(QuizState quizState) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: [
//           // Back button
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               height: 38,
//               width: 38,
//               decoration: BoxDecoration(
//                 color: widget.subjectColor.withOpacity(0.18),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.chevron_left,
//                   color: widget.subjectColor, size: 26),
//             ),
//           ),
//           const SizedBox(width: 10),

//           // Progress pill
//           Expanded(
//             child: Container(
//               height: 18,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: LinearProgressIndicator(
//                   value: (quizState.currentIndex + 1) / quizState.questions.length,
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation<Color>(widget.subjectColor),
//                   minHeight: 18,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),

//           // Coin counter
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: BoxDecoration(
//               color: kGoldLight,
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('🪙', style: TextStyle(fontSize: 14)),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${quizState.coinsEarned}',
//                   style: const TextStyle(
//                     color: kGold,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Question image card ────────────────────────────────────────────
//   Widget _buildQuestionImageCard(QuizQuestion current) {
//     return Container(
//       width: double.infinity,
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: Image.asset(
//           current.questionImageAsset!,
//           fit: BoxFit.contain,
//         ),
//       ),
//     );
//   }

//   // ── Question text ──────────────────────────────────────────────────
//   Widget _buildQuestionText(QuizQuestion current) {
//     return Text(
//       current.question,
//       textAlign: TextAlign.center,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w700,
//         color: kTextDark,
//         height: 1.3,
//       ),
//     );
//   }

//   // ── Options grid ───────────────────────────────────────────────────
//   Widget _buildOptionsGrid(QuizState quizState, QuizQuestion current) {
//     if (current.type == QuestionType.trueFalse) {
//       return Row(
//         children: [
//           Expanded(child: _buildOptionTile(quizState, current, 0, height: 100)),
//           const SizedBox(width: 14),
//           Expanded(child: _buildOptionTile(quizState, current, 1, height: 100)),
//         ],
//       );
//     }

//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 14,
//         mainAxisSpacing: 14,
//         childAspectRatio: 1.6,
//       ),
//       itemCount: current.options.length,
//       itemBuilder: (_, i) => _buildOptionTile(quizState, current, i),
//     );
//   }

//   Widget _buildOptionTile(QuizState quizState, QuizQuestion current, int index, {double? height}) {
//     final option = current.options[index];
//     final isSelected = quizState.selectedOption == index;
//     final isCorrectOption = index == current.correctIndex;

//     Color bgColor = Colors.white;
//     Color borderColor = Colors.transparent;
//     Color textColor = kTextDark;

//     if (quizState.isChecked) {
//       if (isCorrectOption) {
//         bgColor = kGreenLight;
//         borderColor = kGreen;
//         textColor = kGreen;
//       } else if (isSelected) {
//         bgColor = kRedLight;
//         borderColor = kRed;
//         textColor = kRed;
//       }
//     } else if (isSelected) {
//       bgColor = kPurpleLight;
//       borderColor = kPurple;
//       textColor = kPurple;
//     }

//     return GestureDetector(
//       onTap: () => _onOptionTap(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: height,
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(kRadiusMd),
//           border: Border.all(color: borderColor, width: 2.5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.07),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Center(
//           child: option.text != null
//               ? Text(
//                   option.text!,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     color: textColor,
//                   ),
//                 )
//               : Image.asset(
//                   option.imageAsset!,
//                   fit: BoxFit.contain,
//                   height: 60,
//                 ),
//         ),
//       ),
//     );
//   }

//   // ── Feedback bubble (correct / incorrect image) ────────────────────
//   Widget _buildFeedbackBubble(QuizState quizState) {
//     if (!quizState.isChecked) return const SizedBox(height: 60);
//     return ScaleTransition(
//       scale: _feedbackScale,
//       child: Image.asset(
//         quizState.isCorrect
//             ? 'assets/images/correct-bubble.png'
//             : 'assets/images/incorrect-bubble.png',
//         height: 80,
//       ),
//     );
//   }

//   // ── Check button ───────────────────────────────────────────────────
//   Widget _buildCheckButton(QuizState quizState) {
//     final canCheck = quizState.selectedOption != null && !quizState.isChecked;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GestureDetector(
//         onTap: canCheck ? _onCheck : null,
//         child: AnimatedOpacity(
//           opacity: canCheck ? 1.0 : 0.5,
//           duration: const Duration(milliseconds: 200),
//           child: Stack(
//             children: [
//               // Shadow layer
//               Container(
//                 height: 58 + 6,
//                 decoration: BoxDecoration(
//                   color: kPurpleShadow,
//                   borderRadius: BorderRadius.circular(kRadiusLg),
//                 ),
//               ),
//               // Top layer
//               Container(
//                 height: 58,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [kPurpleMid, kPurple],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: BorderRadius.circular(kRadiusLg),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Text(
//                   'CHECK',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }














































import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';
import 'package:kiddo_app/features/quiz/quiz_model.dart';
import 'package:kiddo_app/features/quiz/quiz_complete_page.dart';
import 'package:kiddo_app/features/quiz/streak_celebration_page.dart';
import 'package:kiddo_app/core/providers/quiz_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/features/home/widgets/mascot_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuizPage — 3-type quiz engine
// Called with: Navigator.push(QuizPage(subjectName, subjectColor))
// ─────────────────────────────────────────────────────────────────────────────
class QuizPage extends ConsumerStatefulWidget {
  final String subjectName;
  final Color subjectColor;
  final int? unitNumber;
  final String? quizName;

  const QuizPage({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    this.unitNumber,
    this.quizName,
  });

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuestionsFromApi(
            subjectName: widget.subjectName,
            unitNumber: widget.unitNumber,
            quizName: widget.quizName,
          );
    });
  }

  // ── Mascot state derivation ────────────────────────────────────────
  MascotState _getMascotState(QuizState quizState) {
    if (!quizState.isChecked) {
      if (quizState.consecutiveCorrect >= 5) return MascotState.excited;
      return MascotState.idle;
    }
    if (quizState.isCorrect) {
      if (quizState.consecutiveCorrect >= 5) return MascotState.excited;
      return MascotState.happy;
    }
    return MascotState.sad;
  }

  // ── Helpers ────────────────────────────────────────────────────────
  void _onOptionTap(int index) {
    ref.read(quizProvider.notifier).selectOption(index);
  }

  Future<void> _onCheck() async {
    final notifier = ref.read(quizProvider.notifier);
    final state = ref.read(quizProvider);

    if (state.selectedOption == null || state.isChecked) return;

    final isCorrect = notifier.checkAnswer();
    final newState = ref.read(quizProvider);

    // Streak milestone celebration
    if (isCorrect &&
        (newState.consecutiveCorrect == 5 ||
            newState.consecutiveCorrect == 10 ||
            newState.consecutiveCorrect == 15)) {
      await _showStreakCelebration(newState.consecutiveCorrect);
    }

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    if (newState.currentIndex < newState.questions.length - 1) {
      notifier.nextQuestion();
    } else {
      // Quiz over
      _goToComplete(newState);
    }
  }

  // ── Inline feedback card ───────────────────────────────────────────
  Widget _buildFeedbackCard(bool isCorrect, QuizQuestion question) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xffc2ffaf) : const Color(0xFFFFAFAF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? const Color(0xff149200) : const Color(0xFFB00020))
                .withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 80),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? 'Great!' : 'Oops!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? const Color(0xff149200)
                              : const Color(0xFFB00020),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCorrect
                            ? 'Correct answer! Keep it up.'
                            : 'Correct: ${question.options[question.correctIndex].text ?? ""}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCorrect
                              ? const Color.fromARGB(255, 60, 140, 70)
                              : const Color.fromARGB(255, 180, 50, 50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -5,
            left: -15,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 110,
                  child: Image.asset(
                    isCorrect
                        ? 'assets/animation/correct.gif'
                        : 'assets/animation/incorrect.gif',
                  ),
                ),
                Positioned(
                  child: SizedBox(
                    height: 80,
                    child: Lottie.asset(
                      'assets/animation/click.json',
                      repeat: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStreakCelebration(int count) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => StreakCelebrationPage(count: count),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _goToComplete(QuizState finalState) async {
    final accuracy =
        (finalState.correctCount / finalState.questions.length * 100).round();

    // Submit attempt to backend if playing a specific unit/quiz
    if (widget.unitNumber != null && widget.quizName != null) {
      await ref.read(quizProvider.notifier).submitQuizAttempt(
            subjectName: widget.subjectName,
            unitNumber: widget.unitNumber!,
            quizName: widget.quizName!,
          );
      ref.invalidate(userProvider);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizCompletePage(
          subjectName: widget.subjectName,
          subjectColor: widget.subjectColor,
          totalPoints: finalState.totalPoints,
          totalIQ: finalState.totalPoints * 2,
          accuracy: accuracy,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState.questions.isEmpty) {
      return Scaffold(
        backgroundColor: kPurpleLight,
        body: Center(
          child: CircularProgressIndicator(color: widget.subjectColor),
        ),
      );
    }

    final currentQuestion = quizState.currentQuestion;

    return Scaffold(
      backgroundColor: kPurpleLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(quizState),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // ── Mascot reaction based on quiz streak ────────────────
                    Center(
                      child: MascotWidget(
                        state: _getMascotState(quizState),
                        size: 90,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (currentQuestion.questionImageAsset != null)
                      _buildQuestionImageCard(currentQuestion),
                    const SizedBox(height: 18),
                    _buildQuestionText(currentQuestion),
                    const SizedBox(height: 22),
                    _buildOptionsGrid(quizState, currentQuestion),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildBottomActionArea(quizState, currentQuestion),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────
  Widget _buildTopBar(QuizState quizState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: widget.subjectColor.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left,
                  color: widget.subjectColor, size: 26),
            ),
          ),
          const SizedBox(width: 10),

          // Progress pill
          Expanded(
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: (quizState.currentIndex + 1) /
                      quizState.questions.length,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.subjectColor),
                  minHeight: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Coin counter
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/coin.png',
                  height: 16,
                  width: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 5),
                Text(
                  '${quizState.coinsEarned}',
                  style: const TextStyle(
                    color: kGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Question image card ────────────────────────────────────────────
  Widget _buildQuestionImageCard(QuizQuestion current) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          current.questionImageAsset!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Question text ──────────────────────────────────────────────────
  Widget _buildQuestionText(QuizQuestion current) {
    return Text(
      current.question,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: kTextDark,
        height: 1.3,
      ),
    );
  }

  // ── Options grid ───────────────────────────────────────────────────
  Widget _buildOptionsGrid(QuizState quizState, QuizQuestion current) {
    if (current.type == QuestionType.trueFalse) {
      return Row(
        children: [
          Expanded(
              child: _buildOptionTile(quizState, current, 0, height: 100)),
          const SizedBox(width: 14),
          Expanded(
              child: _buildOptionTile(quizState, current, 1, height: 100)),
        ],
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.6,
      ),
      itemCount: current.options.length,
      itemBuilder: (_, i) => _buildOptionTile(quizState, current, i),
    );
  }

  Widget _buildOptionTile(
    QuizState quizState,
    QuizQuestion current,
    int index, {
    double? height,
  }) {
    final option = current.options[index];
    final isSelected = quizState.selectedOption == index;
    final isCorrectOption = index == current.correctIndex;

    Color bgColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = kTextDark;

    if (quizState.isChecked) {
      if (isCorrectOption) {
        bgColor = kGreenLight;
        borderColor = kGreen;
        textColor = kGreen;
      } else if (isSelected) {
        bgColor = kRedLight;
        borderColor = kRed;
        textColor = kRed;
      }
    } else if (isSelected) {
      bgColor = kPurpleLight;
      borderColor = kPurple;
      textColor = kPurple;
    }

    return GestureDetector(
      onTap: () => _onOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: option.text != null
              ? Text(
                  option.text!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                )
              : Image.asset(
                  option.imageAsset!,
                  fit: BoxFit.contain,
                  height: 60,
                ),
        ),
      ),
    );
  }

  // ── Bottom action & feedback area ──────────────────────────────────
  Widget _buildBottomActionArea(QuizState quizState, QuizQuestion currentQuestion) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCheckButton(quizState),
          if (quizState.isChecked) ...[
            const SizedBox(height: 12),
            _buildFeedbackCard(quizState.isCorrect, currentQuestion),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Check button ───────────────────────────────────────────────────
  Widget _buildCheckButton(QuizState quizState) {
    final canCheck = quizState.selectedOption != null && !quizState.isChecked;
    final isChecked = quizState.isChecked;

    return GestureDetector(
      onTap: canCheck ? _onCheck : null,
      child: AnimatedOpacity(
        opacity: (canCheck || isChecked) ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            // Shadow layer
            Container(
              height: 54 + 4,
              decoration: BoxDecoration(
                color: isChecked
                    ? (quizState.isCorrect
                            ? const Color(0xff149200)
                            : const Color(0xFFB00020))
                        .withOpacity(0.4)
                    : kPurpleShadow,
                borderRadius: BorderRadius.circular(kRadiusLg),
              ),
            ),
            // Top layer
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isChecked
                      ? (quizState.isCorrect
                          ? [const Color(0xff38EF7D), const Color(0xff11998E)]
                          : [const Color(0xFFFF6B6B), const Color(0xFFB00020)])
                      : [kPurpleMid, kPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(kRadiusLg),
              ),
              alignment: Alignment.center,
              child: Text(
                isChecked ? 'CONTINUE' : 'CHECK',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}