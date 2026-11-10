import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/features_service.dart';
import 'package:kiddo_app/features/user/profilepage.dart';
import 'package:kiddo_app/features/lessons/lesson_details_page.dart';
import 'package:kiddo_app/features/home/widgets/mascot_suggestion_banner.dart';
import 'package:kiddo_app/features/parent/parent_spectator_page.dart';
import 'package:kiddo_app/features/social/feed_page.dart';
import 'package:kiddo_app/features/social/friends_and_contests_page.dart';
import 'package:kiddo_app/features/boss_fight/boss_fight_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController _subjectPageController;
  List<Map<String, dynamic>> _challenges = [];
  bool _isLoadingChallenges = true;

  static const List<_SubjectInfo> _subjects = [
    _SubjectInfo(
      'Math',
      'Chapter 1 : Counting Number',
      Color(0xFF0284C7),
      Color(0xFFE0F2FE),
      Color(0xFF38BDF8),
      'assets/images/Math.png',
      0.45,
    ),
    _SubjectInfo(
      'GK',
      'Chapter 1 : Our Environment',
      Color(0xFF16A34A),
      Color(0xFFDCFCE7),
      Color(0xFF22C55E),
      'assets/images/GK.png',
      0.30,
    ),
    _SubjectInfo(
      'Science',
      'Chapter 1 : Basics of Science',
      Color(0xFFE11D48),
      Color(0xFFFFE4E6),
      Color(0xFFF43F5E),
      'assets/images/Science.png',
      0.20,
    ),
    _SubjectInfo(
      'English',
      'Chapter 1 : Alphabet',
      Color(0xFF9333EA),
      Color(0xFFF3E8FF),
      Color(0xFFA855F7),
      'assets/images/English.png',
      0.60,
    ),
    _SubjectInfo(
      'Computer',
      'Chapter 1 : Basics of Computer',
      Color(0xFFCA8A04),
      Color(0xFFFEF9C3),
      Color(0xFFEAB308),
      'assets/images/Computer.png',
      0.10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _subjectPageController = PageController(viewportFraction: 0.88);
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final list = await FeaturesService().getDailyChallenges();
    if (mounted) {
      setState(() {
        _challenges = list;
        _isLoadingChallenges = false;
      });
    }
  }

  Future<void> _claimChallenge(Map<String, dynamic> challenge) async {
    try {
      final res = await FeaturesService().claimChallenge(challenge['_id']);
      if (res != null) {
        ref.invalidate(userProvider);
        _loadChallenges();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Claimed +${res['earnedIq']} IQ & +${res['earnedCoins']} Coins! 🎉'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectPageController.dispose();
    super.dispose();
  }

  void _openProfile() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Profilepage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // Slide in from LEFT
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    final streakCount = user?.streak ?? 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar (Matching Image 1) ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: _openProfile,
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile_pic.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const CircleAvatar(
                              backgroundColor: Color(0xFFE2E8F0),
                              child: Icon(Icons.person, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Parent Mode Quick Action
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const ParentSpectatorPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        ),
                        child: Row(
                          children: const [
                            Text('🛡️', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(
                              'Parents',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Coins Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/coin.png',
                            height: 18,
                            width: 18,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${user?.coins ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // IQ Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/IQ.png',
                            height: 18,
                            width: 18,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${user?.iq ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Adaptive Mascot Suggestion Banner (Section 2.1) ───────
              const MascotSuggestionBanner(),

              // ── Quick Feature Action Hub ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionHubButton(
                        title: 'Arena & Friends',
                        icon: '⚔️',
                        bgColor: const Color(0xFFFAF5FF),
                        borderColor: const Color(0xFFDDD6FE),
                        textColor: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => const FriendsAndContestsPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionHubButton(
                        title: 'Boss Battle',
                        icon: '🐉',
                        bgColor: const Color(0xFFFFF1F2),
                        borderColor: const Color(0xFFFECDD3),
                        textColor: const Color(0xFFE11D48),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => const BossFightPage()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionHubButton(
                        title: 'Social Feed',
                        icon: '🌟',
                        bgColor: const Color(0xFFF0FDF4),
                        borderColor: const Color(0xFFBBF7D0),
                        textColor: const Color(0xFF16A34A),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => const SocialFeedPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Daily Streak Banner ("5 Days!") ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF97316),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/fire.png',
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('🔥', style: TextStyle(fontSize: 26))),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streakCount Days!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "You're on fire!",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                          const Text(
                            "Keep the streak going !",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Subject Cards (PageView Carousel) ────────────────────
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _subjectPageController,
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildSubjectCard(context, subject),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Rewards For Active Section ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rewards For Active',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildRewardCard(
                          iconEmoji: '🎁',
                          bgColor: const Color(0xFFFFF7ED),
                          borderColor: const Color(0xFFFED7AA),
                          timerText: '23:59:54',
                        ),
                        const SizedBox(width: 14),
                        _buildRewardCard(
                          iconEmoji: '🃏',
                          bgColor: const Color(0xFFFEFCE8),
                          borderColor: const Color(0xFFFEF08A),
                          timerText: '23:59:54',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Daily Challenges Section (Section 2.3 Live Data) ──────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Challenges',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingChallenges)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_challenges.isEmpty)
                      const Text('No daily challenges today.', style: TextStyle(color: Color(0xFF64748B)))
                    else
                      ...List.generate(_challenges.length, (index) {
                        final challenge = _challenges[index];
                        final current = challenge['currentCount'] ?? 0;
                        final target = challenge['targetCount'] ?? 3;
                        final fraction = (current / target).clamp(0.0, 1.0);
                        final isClaimed = challenge['isClaimed'] == true;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildChallengeCard(
                            taskTitle: challenge['taskTitle'] ?? 'Task ${index + 1}',
                            description: challenge['description'] ?? '',
                            fractionText: '$current/$target',
                            fractionValue: fraction.toDouble(),
                            bgColor: index == 0
                                ? const Color(0xFFE0F2FE)
                                : index == 1
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF9C3),
                            accentColor: index == 0
                                ? const Color(0xFF0284C7)
                                : index == 1
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFCA8A04),
                            mascotEmoji: challenge['mascotEmoji'] ?? '🐘',
                            isClaimed: isClaimed,
                            canClaim: fraction >= 0.3 && !isClaimed,
                            onClaim: () => _claimChallenge(challenge),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionHubButton({
    required String title,
    required String icon,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject Card Builder (Matching Image 1) ───────────────────────────
  Widget _buildSubjectCard(BuildContext context, _SubjectInfo subject) {
    return Container(
      decoration: BoxDecoration(
        color: subject.bgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: subject.borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: subject.primaryColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Illustration
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                color: Colors.white.withOpacity(0.6),
                child: Image.asset(
                  subject.assetImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      subject.name == 'Math'
                          ? '📐'
                          : subject.name == 'GK'
                              ? '🌍'
                              : subject.name == 'Science'
                                  ? '🔬'
                                  : subject.name == 'English'
                                      ? '📖'
                                      : '💻',
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            subject.name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: subject.primaryColor,
              letterSpacing: 0.3,
            ),
          ),

          // Subtitle
          Text(
            subject.chapter,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: subject.progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(subject.primaryColor),
            ),
          ),

          const SizedBox(height: 14),

          // 3D Continue Button
          GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => LessonDetailsPage(
                    subjectName: subject.name,
                    gradientColors: [subject.primaryColor, subject.primaryColor.withOpacity(0.8)],
                    emoji: subject.name == 'Math'
                        ? '📐'
                        : subject.name == 'GK'
                            ? '🌍'
                            : subject.name == 'Science'
                                ? '🔬'
                                : subject.name == 'English'
                                    ? '📖'
                                    : '💻',
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                // 3D Bevel bottom shadow
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.lerp(subject.primaryColor, Colors.black, 0.25),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                // Button face
                Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: subject.primaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
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

  // ── Reward Card Builder (Matching Image 1) ────────────────────────────
  Widget _buildRewardCard({
    required String iconEmoji,
    required Color bgColor,
    required Color borderColor,
    required String timerText,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                timerText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard({
    required String taskTitle,
    required String description,
    required String fractionText,
    required double fractionValue,
    required Color bgColor,
    required Color accentColor,
    required String mascotEmoji,
    bool isClaimed = false,
    bool canClaim = false,
    VoidCallback? onClaim,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(mascotEmoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      taskTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      fractionText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fractionValue,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ],
            ),
          ),
          if (canClaim) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClaim,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ] else if (isClaimed) ...[
            const SizedBox(width: 8),
            const Text(
              '✅ Claimed',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubjectInfo {
  final String name;
  final String chapter;
  final Color primaryColor;
  final Color bgColor;
  final Color borderColor;
  final String assetImage;
  final double progress;

  const _SubjectInfo(
    this.name,
    this.chapter,
    this.primaryColor,
    this.bgColor,
    this.borderColor,
    this.assetImage,
    this.progress,
  );
}
