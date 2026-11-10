import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiddo_app/bottom_nav_bar.dart';
import 'package:kiddo_app/features/games/game_page.dart';
import 'package:kiddo_app/features/home/home_page.dart';
import 'package:kiddo_app/features/leaderboard/leaderboard_page.dart';
import 'package:kiddo_app/features/lessons/lesson_page.dart';
import 'package:kiddo_app/features/shop/shop_page.dart';
import 'package:kiddo_app/features/splash/splash_page.dart';
import 'package:kiddo_app/features/onboarding_Screen/onboarding_screen.dart';
import 'package:kiddo_app/features/Auth/Login_page.dart';
import 'package:kiddo_app/features/user/profilepage.dart';

import 'package:kiddo_app/features/boss_fight/boss_fight_page.dart';
import 'package:kiddo_app/features/parent/parent_spectator_page.dart';
import 'package:kiddo_app/features/social/feed_page.dart';
import 'package:kiddo_app/features/social/friends_and_contests_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _lessonsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'lessons');
final GlobalKey<NavigatorState> _gamesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'games');
final GlobalKey<NavigatorState> _leaderboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'leaderboard');
final GlobalKey<NavigatorState> _shopNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shop');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isSurvey = state.uri.queryParameters['survey'] == 'true' ||
            (extra?['isSurvey'] == true);
        final initialPage = isSurvey ? 4 : 0; // Starts from Age Screen for survey
        final name = extra?['name'] as String? ?? state.uri.queryParameters['name'];
        return MasterOnboardingScreen(
          initialPage: initialPage,
          initialName: name,
          isSurveyMode: isSurvey,
        );
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isSignUp = state.uri.queryParameters['signup'] == 'true' ||
            state.uri.queryParameters['mode'] == 'signup' ||
            (extra?['isSignUp'] == true);
        final name = extra?['name'] as String? ?? state.uri.queryParameters['name'];
        final age = extra?['age'] as int? ?? int.tryParse(state.uri.queryParameters['age'] ?? '');
        final gradeClass = extra?['gradeClass'] as String? ?? state.uri.queryParameters['gradeClass'];
        return LoginPage(
          initialSignUp: isSignUp,
          defaultName: name,
          defaultAge: age,
          defaultGradeClass: gradeClass,
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isSignUp = state.uri.queryParameters['signup'] == 'true' ||
            state.uri.queryParameters['mode'] == 'signup' ||
            (extra?['isSignUp'] == true);
        final name = extra?['name'] as String? ?? state.uri.queryParameters['name'];
        final age = extra?['age'] as int? ?? int.tryParse(state.uri.queryParameters['age'] ?? '');
        final gradeClass = extra?['gradeClass'] as String? ?? state.uri.queryParameters['gradeClass'];
        return LoginPage(
          initialSignUp: isSignUp,
          defaultName: name,
          defaultAge: age,
          defaultGradeClass: gradeClass,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const Profilepage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
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
    ),
    GoRoute(
      path: '/boss-fight',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subject = extra?['subject'] as String? ?? 'Math';
        final chapter = extra?['chapter'] as String? ?? 'Chapter 1: Boss Battle';
        return BossFightPage(subject: subject, chapter: chapter);
      },
    ),
    GoRoute(
      path: '/parent-dashboard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ParentSpectatorPage(),
    ),
    GoRoute(
      path: '/social-feed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SocialFeedPage(),
    ),
    GoRoute(
      path: '/contests',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FriendsAndContestsPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Branch 0: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomePage(),
            ),
          ],
        ),
        // Branch 1: Lessons
        StatefulShellBranch(
          navigatorKey: _lessonsNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/lessons',
              builder: (BuildContext context, GoRouterState state) =>
                  const LessonPage(),
            ),
          ],
        ),
        // Branch 2: Games
        StatefulShellBranch(
          navigatorKey: _gamesNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/games',
              builder: (BuildContext context, GoRouterState state) =>
                  const GamePage(),
            ),
          ],
        ),
        // Branch 3: Leaderboard (Later to be Profile)
        StatefulShellBranch(
          navigatorKey: _leaderboardNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/leaderboard',
              builder: (BuildContext context, GoRouterState state) =>
                  const LeaderboardPage(),
            ),
          ],
        ),
        // Branch 4: Shop
        StatefulShellBranch(
          navigatorKey: _shopNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/shop',
              builder: (BuildContext context, GoRouterState state) =>
                  const ShopPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
