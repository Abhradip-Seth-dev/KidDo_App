import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/services/api_service.dart';
import 'package:kiddo_app/features/lessons/lesson_details_page.dart';

// ── Subject config matching Image 2 ───────────────────────────────────────────
const _subjects = [
  _SubjectConfig(
    name: 'Math',
    emoji: '📐',
    badgeText: '2+2\n4',
    gradient: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
    bookColor: Color(0xFFFF9F43),
    spineColor: Color(0xFFEE5253),
    asset: 'assets/images/Math.png',
  ),
  _SubjectConfig(
    name: 'GK',
    emoji: '🌍',
    badgeText: 'GK',
    gradient: [Color(0xFF2ECC71), Color(0xFF10AC84)],
    bookColor: Color(0xFF2ECC71),
    spineColor: Color(0xFF10AC84),
    asset: 'assets/images/GK.png',
  ),
  _SubjectConfig(
    name: 'English',
    emoji: '📖',
    badgeText: 'ABC',
    gradient: [Color(0xFFFF5252), Color(0xFFD63031)],
    bookColor: Color(0xFFFF5252),
    spineColor: Color(0xFFC0392B),
    asset: 'assets/images/English.png',
  ),
  _SubjectConfig(
    name: 'Science',
    emoji: '🔬',
    badgeText: '⚛️',
    gradient: [Color(0xFF4834D4), Color(0xFF686DE0)],
    bookColor: Color(0xFF4834D4),
    spineColor: Color(0xFF30336B),
    asset: 'assets/images/Science.png',
  ),
];

class _SubjectConfig {
  final String name;
  final String emoji;
  final String badgeText;
  final List<Color> gradient;
  final Color bookColor;
  final Color spineColor;
  final String asset;

  const _SubjectConfig({
    required this.name,
    required this.emoji,
    required this.badgeText,
    required this.gradient,
    required this.bookColor,
    required this.spineColor,
    required this.asset,
  });
}

// ── Provider for subject progress ─────────────────────────────────────────────
final subjectProgressProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, subject) async {
    try {
      final api = ApiService();
      final response =
          await api.get('/quiz/units', queryParams: {'subject': subject});
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {'currentUnit': 1, 'units': []};
    }
  },
);

// ── Lesson Page ───────────────────────────────────────────────────────────────
class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key});

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  int _selectedFilter = 0; // 0: ALL, 1: ONGOING, 2: DONE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Matching Image 2) ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Subject',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1E2C),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Filter Chips: ALL | ONGOING | DONE ───────────────────
                  Row(
                    children: [
                      _buildFilterChip('ALL', 0),
                      const SizedBox(width: 8),
                      _buildFilterChip('ONGOING', 1),
                      const SizedBox(width: 8),
                      _buildFilterChip('DONE', 2),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── 2x2 3D Book Subject Cards Grid ─────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.92,
                ),
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  return _SubjectBookCard(subject: subject, ref: ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2E8F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ── 3D Book Subject Card (Matching Image 2) ──────────────────────────────────
class _SubjectBookCard extends StatelessWidget {
  final _SubjectConfig subject;
  final WidgetRef ref;

  const _SubjectBookCard({required this.subject, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => LessonDetailsPage(
              subjectName: subject.name,
              gradientColors: subject.gradient,
              emoji: subject.emoji,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: subject.bookColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: subject.spineColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left spine highlight
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 14,
                decoration: BoxDecoration(
                  color: subject.spineColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(24),
                  ),
                ),
              ),
            ),

            // Top ribbon bookmark
            Positioned(
              top: 0,
              right: 28,
              child: Container(
                width: 16,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(6),
                  ),
                ),
              ),
            ),

            // Center Book Content
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Book Cover Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subject.badgeText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Bottom Title
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
