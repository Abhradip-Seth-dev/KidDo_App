import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/services/api_service.dart';
import 'package:kiddo_app/features/quiz/quiz_page.dart';

// ── Models ────────────────────────────────────────────────────────────────────
class QuizRoadmapNode {
  final String quizName;
  final int unitNumber;
  final String unitName;
  final int questionCount;
  final int stars;
  final bool completed;
  final String status; // 'completed' | 'current' | 'locked'
  final bool isFirstInUnit; // True if this quiz is the start of a unit

  QuizRoadmapNode({
    required this.quizName,
    required this.unitNumber,
    required this.unitName,
    required this.questionCount,
    required this.stars,
    required this.completed,
    required this.status,
    required this.isFirstInUnit,
  });
}

// ── API provider for complete quiz roadmap ────────────────────────────────────
final quizRoadmapProvider =
    FutureProvider.family<List<QuizRoadmapNode>, String>((ref, subject) async {
  final api = ApiService();
  final response =
      await api.get('/quiz/units', queryParams: {'subject': subject});
  final data = response.data as Map<String, dynamic>;
  final rawUnits = data['units'] as List<dynamic>;

  final List<QuizRoadmapNode> roadmap = [];

  for (final u in rawUnits) {
    final unitNumber = (u['unitNumber'] as num).toInt();
    final unitName = u['unitName'] as String;
    final rawQuizzes = (u['quizzes'] as List<dynamic>);

    for (int i = 0; i < rawQuizzes.length; i++) {
      final q = rawQuizzes[i];
      roadmap.add(
        QuizRoadmapNode(
          quizName: q['quizName'] as String,
          unitNumber: unitNumber,
          unitName: unitName,
          questionCount: (q['questionCount'] as num).toInt(),
          stars: (q['stars'] as num?)?.toInt() ?? 0,
          completed: (q['completed'] as bool?) ?? false,
          status: (q['status'] as String?) ?? 'locked',
          isFirstInUnit: i == 0,
        ),
      );
    }
  }

  return roadmap;
});

// ── Lesson Details Page (Full Duolingo Roadmap) ───────────────────────────────
class LessonDetailsPage extends ConsumerStatefulWidget {
  final String subjectName;
  final List<Color> gradientColors;
  final String emoji;

  const LessonDetailsPage({
    super.key,
    required this.subjectName,
    required this.gradientColors,
    required this.emoji,
  });

  @override
  ConsumerState<LessonDetailsPage> createState() => _LessonDetailsPageState();
}

class _LessonDetailsPageState extends ConsumerState<LessonDetailsPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roadmapAsync = ref.watch(quizRoadmapProvider(widget.subjectName));
    final primaryColor = widget.gradientColors[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // ── Header Background ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Top Bar with Back Arrow ────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.emoji} ${widget.subjectName} Roadmap',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Continuous Roadmap ────────────────────────────────────────────
          Positioned.fill(
            top: 140,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                color: const Color(0xFFF8F9FF),
                child: roadmapAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('Failed to load roadmap.\n$e',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.refresh(quizRoadmapProvider(widget.subjectName)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (nodes) => _RoadmapListView(
                    nodes: nodes,
                    gradientColors: widget.gradientColors,
                    subjectName: widget.subjectName,
                    scrollController: _scrollController,
                    ref: ref,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Roadmap List View ─────────────────────────────────────────────────────────
class _RoadmapListView extends StatelessWidget {
  final List<QuizRoadmapNode> nodes;
  final List<Color> gradientColors;
  final String subjectName;
  final ScrollController scrollController;
  final WidgetRef ref;

  const _RoadmapListView({
    required this.nodes,
    required this.gradientColors,
    required this.subjectName,
    required this.scrollController,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 100),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final alignment = _getAlignment(index);

        return Column(
          children: [
            // Unit Header Banner if this is the start of a unit
            if (node.isFirstInUnit)
              _UnitBanner(
                unitNumber: node.unitNumber,
                unitName: node.unitName,
                gradientColors: gradientColors,
              ),

            // Quiz Roadmap Node
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: () async {
                      if (node.status != 'locked') {
                        await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => QuizPage(
                              subjectName: subjectName,
                              subjectColor: gradientColors[0],
                              unitNumber: node.unitNumber,
                              quizName: node.quizName,
                            ),
                          ),
                        );
                        // Refresh roadmap after returning from quiz
                        ref.invalidate(quizRoadmapProvider(subjectName));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔒 Complete previous quizzes to unlock!'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: _QuizNodeWidget(
                      node: node,
                      gradientColors: gradientColors,
                    ),
                  ),
                ),
              ),
            ),

            // Connecting vertical path line
            if (index < nodes.length - 1)
              Align(
                alignment: alignment,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: alignment == Alignment.centerRight ? 0 : 40,
                    right: alignment == Alignment.centerLeft ? 0 : 40,
                  ),
                  child: Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: node.completed
                          ? gradientColors[0].withOpacity(0.6)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Alignment _getAlignment(int index) {
    const alignments = [
      Alignment.center,
      Alignment.centerRight,
      Alignment.center,
      Alignment.centerLeft,
      Alignment.center,
    ];
    return alignments[index % alignments.length];
  }
}

// ── Unit Section Header Banner ────────────────────────────────────────────────
class _UnitBanner extends StatelessWidget {
  final int unitNumber;
  final String unitName;
  final List<Color> gradientColors;

  const _UnitBanner({
    required this.unitNumber,
    required this.unitName,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UNIT $unitNumber',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unitName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single Quiz Node Widget ───────────────────────────────────────────────────
class _QuizNodeWidget extends StatelessWidget {
  final QuizRoadmapNode node;
  final List<Color> gradientColors;

  const _QuizNodeWidget({
    required this.node,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = node.status == 'locked';
    final isCurrent = node.status == 'current';
    final isCompleted = node.status == 'completed';
    final primaryColor = gradientColors[0];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Node button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 84 : 72,
          height: isCurrent ? 84 : 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isLocked
                ? null
                : LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isLocked ? Colors.grey[300] : null,
            boxShadow: isLocked
                ? []
                : [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: isCurrent ? 16 : 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLocked)
                const Icon(Icons.lock, color: Colors.white, size: 26)
              else if (isCompleted)
                const Icon(Icons.check_rounded, color: Colors.white, size: 34)
              else
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: isCurrent ? 40 : 34,
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Stars badge for completed quizzes (⭐ 1-3 stars)
        if (isCompleted)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Icon(
                Icons.star_rounded,
                size: 16,
                color: i < node.stars ? Colors.amber : Colors.grey[300],
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Quiz title label below node
        Container(
          constraints: const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrent
                ? primaryColor.withOpacity(0.12)
                : (isCompleted ? Colors.amber.withOpacity(0.12) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            node.quizName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? primaryColor
                  : (isCompleted ? Colors.deepOrange : Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }
}
