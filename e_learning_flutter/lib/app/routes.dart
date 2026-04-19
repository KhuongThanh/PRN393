import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/favorites/screens/favorites_screen.dart';
import '../features/flashcard/screens/flashcard_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/progress/screens/history_screen.dart';
import '../features/quiz/screens/quiz_screen.dart';
import '../features/study/screens/match_screen.dart';
import '../features/study/screens/write_screen.dart';
import '../features/topics/screens/topic_detail_screen.dart';
import '../features/topics/screens/topics_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const topics = '/topics';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const history = '/history';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    topics: (_) => const TopicsScreen(),
    favorites: (_) => const FavoritesScreen(),
    profile: (_) => const ProfileScreen(),
    history: (_) => const HistoryScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) {
      return null;
    }

    final uri = Uri.parse(name);
    final segments = uri.pathSegments;

    if (segments.length == 2 && segments[0] == 'topics') {
      return MaterialPageRoute(
        builder: (_) => TopicDetailScreen(setId: segments[1]),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments[0] == 'flashcard') {
      return MaterialPageRoute(
        builder: (_) => FlashcardScreen(setId: segments[1]),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments[0] == 'quiz') {
      return MaterialPageRoute(
        builder: (_) => QuizScreen(setId: segments[1]),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments[0] == 'match') {
      return MaterialPageRoute(
        builder: (_) => MatchScreen(setId: segments[1]),
        settings: settings,
      );
    }

    if (segments.length == 2 && segments[0] == 'write') {
      return MaterialPageRoute(
        builder: (_) => WriteScreen(setId: segments[1]),
        settings: settings,
      );
    }

    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => _UnknownRouteScreen(routeName: settings.name ?? ''),
      settings: settings,
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2FF),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    size: 38,
                    color: Color(0xFF4255FF),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Route not found',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E3856),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  routeName.isEmpty
                      ? 'This screen is not available yet.'
                      : 'No page is registered for $routeName.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF939BB4),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4255FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back home',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
