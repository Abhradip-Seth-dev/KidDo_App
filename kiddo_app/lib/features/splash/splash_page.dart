import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/providers/auth_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));

    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.status == AuthStatus.authenticated) {
      try {
        final user = await ref.read(userProvider.future);
        if (!mounted) return;
        if (user != null && !user.hasCompletedOnboarding) {
          context.go('/onboarding?survey=true', extra: {'name': user.name});
          return;
        }
      } catch (_) {}
      if (!mounted) return;
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff7C3AED), // Brand vibrant purple
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glasses icon container matching design
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
                Container(
                  width: 14,
                  height: 4,
                  color: Colors.white,
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ],
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 800.ms),

            const SizedBox(height: 16),

            // Logo Text
            const Text(
              'KidDo',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
