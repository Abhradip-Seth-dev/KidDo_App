import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/providers/auth_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

class MasterOnboardingScreen extends ConsumerStatefulWidget {
  final int initialPage;
  final String? initialName;
  final bool isSurveyMode;

  const MasterOnboardingScreen({
    super.key,
    this.initialPage = 0,
    this.initialName,
    this.isSurveyMode = false,
  });

  @override
  ConsumerState<MasterOnboardingScreen> createState() =>
      _MasterOnboardingScreenState();
}

class _MasterOnboardingScreenState
    extends ConsumerState<MasterOnboardingScreen> {
  late PageController _pageController;
  late int _currentPage;

  // Collected User Data
  String _name = '';
  int _age = 8;
  String _gradeClass = 'Class 3';

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _name = widget.initialName!;
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _classController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < 8) {
      _goToPage(_currentPage + 1);
    }
  }

  void _onNameSubmitted() {
    final text = _nameController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _name = text;
      });
      // Move to appreciation slide
      _nextPage();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Controlled step-by-step
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          // 1. Welcome Screen
          _buildWelcomeScreen(),

          // 2. Onboarding Slide 1 (Fun with Games - Coral)
          _buildSlide1(),

          // 3. Onboarding Slide 2 (Turn learning into victory - Green)
          _buildSlide2(),

          // 4. Onboarding Slide 3 (Meet with new friends - Blue)
          _buildSlide3(),

          // 5. Age Taking Page (Yellow)
          _buildAgeScreen(),

          // 6. Name Taking Page (Lavender)
          _buildNameScreen(),

          // 7. Appreciation Page (Lavender)
          _buildAppreciationScreen(),

          // 8. Class Taking Page (Lavender)
          _buildClassScreen(),

          // 9. Final Screen: You are all Set ! (Deep Purple)
          _buildFinishScreen(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Welcome Screen
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'welcome to',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E77ED),
                ),
              ),
              const Text(
                'KidDo',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C3AED),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/kido_character.png',
                height: 240,
                fit: BoxFit.contain,
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _goToPage(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => context.go('/auth'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFF7C3AED), width: 1.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'I ALREADY HAVE AN ACCOUNT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Onboarding Slide 1 (Coral Pink - Fun with Games)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSlide1() {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7A70), // Coral salmon pink
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learning is a\nFun with\nGames !',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      'assets/images/Math.png',
                      height: 190,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Spacer(),
              _buildSlideFooter(
                activeDot: 0,
                buttonColor: const Color(0xFFFF5252),
                onNext: () => _goToPage(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Onboarding Slide 2 (Green - Victory)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSlide2() {
    return Scaffold(
      backgroundColor: const Color(0xFF22C55E), // Vibrant green
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Turn\nlearning into\nvictory.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      'assets/images/leaderboard.png',
                      height: 190,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Spacer(),
              _buildSlideFooter(
                activeDot: 1,
                buttonColor: const Color(0xFF16A34A),
                onNext: () => _goToPage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Onboarding Slide 3 (Sky Blue - Friends & Compete)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSlide3() {
    return Scaffold(
      backgroundColor: const Color(0xFF60A5FA), // Sky blue
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meet with\nNew Friends\nand compete\nwith them',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      'assets/images/Science.png',
                      height: 190,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Spacer(),
              _buildSlideFooter(
                activeDot: 2,
                buttonColor: const Color(0xFF2563EB),
                onNext: () => _goToPage(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideFooter({
    required int activeDot,
    required Color buttonColor,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 3 Dots indicator
        Row(
          children: List.generate(3, (index) {
            final isActive = index == activeDot;
            return Container(
              margin: const EdgeInsets.only(right: 6),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.white : Colors.white54,
              ),
            );
          }),
        ),
        // NEXT button
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'NEXT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. Age Taking Screen (Yellow)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAgeScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC727), // Sunny bright yellow
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              // Avatar at top
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 54)),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 12),
              const Text(
                'Hey Buddy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                'How old are you ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E2C),
                ),
              ),

              const Spacer(),

              // White Card for Age Display & Slider
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_age',
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFC727),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'years',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFFC727),
                        inactiveTrackColor: Colors.grey[200],
                        thumbColor: const Color(0xFFFFC727),
                        overlayColor: const Color(0xFFFFC727).withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                        ),
                        trackHeight: 8,
                      ),
                      child: Slider(
                        value: _age.toDouble(),
                        min: 4,
                        max: 15,
                        divisions: 11,
                        onChanged: (val) {
                          setState(() {
                            _age = val.round();
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '4',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '8',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '12',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '15',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "We'll personalize the lessons based on age",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const Spacer(),

              // Next button
              ElevatedButton(
                onPressed: () => _goToPage(5),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2C),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. Name Taking Screen (Lavender)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNameScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF), // Soft lavender
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Speech Bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Hey buddy I am KidDO ,\nwhat should I call you ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E2C),
                    height: 1.3,
                  ),
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

              const Spacer(),

              // Mascot holding pencil/notepad
              Image.asset(
                'assets/images/kido_character_Question.png',
                height: 200,
                fit: BoxFit.contain,
              ).animate().fadeIn().slideY(begin: 0.1),

              const Spacer(),

              // Pill input + Send button
              Container(
                padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Type here',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onSubmitted: (_) => _onNameSubmitted(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onNameSubmitted,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. Appreciation Screen (Lavender)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAppreciationScreen() {
    final displayName = _name.isNotEmpty ? _name : 'Friend';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Speech Bubble acknowledging name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Hi , $displayName ! 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.elasticOut),

              const Spacer(),

              Image.asset(
                'assets/images/kido_character.png',
                height: 210,
                fit: BoxFit.contain,
              ).animate().shake(duration: 400.ms),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: () => _goToPage(7),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nice to meet you!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 8. Class Taking Screen (Lavender)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildClassScreen() {
    final List<String> classOptions = [
      'Class 1',
      'Class 2',
      'Class 3',
      'Class 4',
      'Class 5',
      'Class 6',
      'Class 7',
      'Class 8',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Speech bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'In which Class currently\nyou are in ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E2C),
                    height: 1.3,
                  ),
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 20),

              // Class selection chips grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: classOptions.map((cls) {
                  final isSelected = _gradeClass == cls;
                  return ChoiceChip(
                    label: Text(cls),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _gradeClass = cls;
                      });
                    },
                    selectedColor: const Color(0xFF7C3AED),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E1E2C),
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF7C3AED)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 200.ms),

              const Spacer(),

              Image.asset(
                'assets/images/kido_character.png',
                height: 160,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Next Button
              ElevatedButton(
                onPressed: () => _goToPage(8),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Confirm $_gradeClass ➔',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 9. Final Screen: "You are all Set !" -> Direct to Login Page
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFinishScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Dark Purple Curved Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 28,
                24,
                32,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF5B21B6), // Deep rich purple
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You are all Set !',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Stay one step ahead & master new skills.\nYour learning adventure is ready!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Profile summary card (Name, Age, Class)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF7C3AED).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '🎓',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name.isNotEmpty ? _name : 'Kiddo Explorer',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E1E2C),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_age Years Old · $_gradeClass',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7C3AED),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 26,
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 350.ms),

                    const SizedBox(height: 24),

                    // Mascot Illustration
                    Image.asset(
                      'assets/images/kido_character.png',
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(height: 120),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),

                    const SizedBox(height: 24),

                    // Feature Highlight Badges
                    _buildFeatureItem(
                      icon: Icons.sports_esports_rounded,
                      color: const Color(0xFFFF9F43),
                      title: 'Fun Interactive Games & Quizzes',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureItem(
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFFF5252),
                      title: 'Build Daily Learning Streaks',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureItem(
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Win Rewards & Badges',
                    ),
                  ],
                ),
              ),
            ),

            // Action Button (Continue to Sign Up)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.isSurveyMode &&
                      ref.read(authProvider).status ==
                          AuthStatus.authenticated) {
                    try {
                      await ref
                          .read(authProvider.notifier)
                          .completeOnboarding(
                            name: _name.isNotEmpty ? _name : 'KidDo Explorer',
                            age: _age,
                            gradeClass: _gradeClass,
                          );
                      ref.invalidate(userProvider);
                      ref.invalidate(leaderboardProvider);
                    } catch (_) {}
                    if (!mounted) return;
                    context.go('/home');
                  } else {
                    // Always navigate to Sign Up page after onboarding
                    context.go(
                      '/login?mode=signup',
                      extra: {
                        'isSignUp': true,
                        'name': _name,
                        'age': _age,
                        'gradeClass': _gradeClass,
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSurveyMode
                          ? "LET'S START LEARNING"
                          : 'CONTINUE TO SIGN UP',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
