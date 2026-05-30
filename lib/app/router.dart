import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_providers.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../features/compose/presentation/pages/compose_page.dart';
import '../features/inbox/presentation/pages/inbox_page.dart';
import '../features/mirrors/presentation/pages/my_mirror_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/post/presentation/pages/post_detail_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/public_profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const feed = '/feed';
  static const profile = '/profile';
  static const inbox = '/inbox';
  static const mirrors = '/mirrors';
  static const settings = '/settings';
  static const compose = '/compose';
  static const notifications = '/notifications';
  static String postDetail(int id) => '/post/$id';
  static String userProfile(String username) => '/u/$username';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      return auth.when(
        loading: () => null,
        error: (_, __) => null,
        data: (s) {
          final loc = state.matchedLocation;
          final isPublic = loc.startsWith('/u/') || loc.startsWith('/post/');
          final isAuthRoute = loc == AppRoutes.login ||
              loc == AppRoutes.register ||
              loc == AppRoutes.splash;
          if (s.status == AuthStatus.unauthenticated &&
              !isAuthRoute &&
              !isPublic) {
            return AppRoutes.login;
          }
          if (s.status == AuthStatus.authenticated &&
              (loc == AppRoutes.login ||
                  loc == AppRoutes.register ||
                  loc == AppRoutes.splash)) {
            return AppRoutes.feed;
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(path: AppRoutes.feed, builder: (_, __) => const FeedPage()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
      GoRoute(path: AppRoutes.inbox, builder: (_, __) => const InboxPage()),
      GoRoute(path: AppRoutes.mirrors, builder: (_, __) => const MyMirrorPage()),
      GoRoute(
          path: AppRoutes.settings, builder: (_, __) => const SettingsPage()),
      // Placeholder destinations until later milestones land.
      GoRoute(
        path: AppRoutes.compose,
        builder: (_, __) => const ComposePage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PostDetailPage(postId: id);
        },
      ),
      GoRoute(
        path: '/u/:username',
        builder: (_, state) {
          final u = state.pathParameters['username'] ?? '';
          return PublicProfilePage(username: u);
        },
      ),
    ],
  );
});

/// Lightweight stand-in shown until the matching feature page is wired up.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const Center(child: Text('قريباً…')),
    );
  }
}
