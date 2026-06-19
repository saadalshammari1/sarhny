import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_providers.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../features/compose/presentation/pages/compose_page.dart';
import '../features/help/presentation/pages/help_page.dart';
import '../features/help/presentation/pages/legal_page.dart';
import '../features/inbox/presentation/pages/inbox_page.dart';
import '../features/mirrors/presentation/pages/mirror_response_page.dart';
import '../features/mirrors/presentation/pages/my_mirror_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/post/presentation/pages/post_detail_page.dart';
import '../features/profile/presentation/pages/badge_explainer_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/public_profile_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/article/presentation/pages/my_article_page.dart';
import '../features/game/presentation/pages/game_lobby_page.dart';
import '../features/game/presentation/pages/game_play_page.dart';
import '../features/games/games_hub_page.dart';
import '../features/games/carrom/application/carrom_match_state.dart';
import '../features/games/carrom/presentation/pages/carrom_cosmetics_page.dart';
import '../features/games/carrom/presentation/pages/carrom_game_over_page.dart';
import '../features/games/carrom/presentation/pages/carrom_lobby_page.dart';
import '../features/games/carrom/presentation/pages/carrom_match_page.dart';
import '../features/games/carrom/presentation/pages/carrom_matchmaking_page.dart';
import '../features/games/carrom_v2/presentation/carrom_match_page_v2.dart';
import '../features/games/ludo/application/ludo_match_state.dart';
import '../features/games/ludo/domain/ludo_state.dart';
import '../features/games/ludo/presentation/pages/ludo_game_over_page.dart';
import '../features/games/ludo/presentation/pages/ludo_lobby_page.dart';
import '../features/games/ludo/presentation/pages/ludo_match_page.dart';
import '../features/games/ludo/presentation/pages/ludo_matchmaking_page.dart';
import '../features/profile/presentation/pages/saved_posts_page.dart';
import '../features/settings/presentation/pages/blocked_accounts_page.dart';
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
  static const saved = '/saved';
  static const blockedAccounts = '/settings/blocked';
  static const forgotPassword = '/forgot';
  static String resetPassword(String token) => '/reset?token=$token';
  static const help = '/help';
  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';
  static const contentPolicy = '/legal/content-policy';
  static String postDetail(int id) => '/post/$id';
  static String userProfile(String username) => '/u/$username';
  static String badgeExplainer(String kind) => '/learn/$kind';
  static const String search = '/search';
  static const String myArticle = '/me/article';
  static const String gameLobby = '/game';
  static String gamePlay(String id) => '/game/play/$id';

  // Games hub + Carrom
  static const String gamesHub = '/games';
  static const String carromLobby = '/games/carrom';
  static const String carromCosmetics = '/games/carrom/cosmetics';
  static const String carromMatchmaking = '/games/carrom/matchmaking';
  static String carromMatch(String roomId) => '/games/carrom/match/$roomId';
  static String carromGameOver(String roomId) =>
      '/games/carrom/over/$roomId';
  /// Carrom v2 — local Box2D practice mode. New physics + new UI; runs
  /// independently of the WS matchmaking flow above.
  static const String carromPracticeV2 = '/games/carrom/practice-v2';

  // Ludo
  static const String ludoLobby = '/games/ludo';
  static const String ludoMatchmaking = '/games/ludo/matchmaking';
  static String ludoMatch(String roomId) => '/games/ludo/match/$roomId';
  static String ludoGameOver(String roomId) => '/games/ludo/over/$roomId';
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
          final isPublic = loc.startsWith('/u/') ||
              loc.startsWith('/post/') ||
              loc.startsWith('/mirror/');
          final isAuthRoute = loc == AppRoutes.login ||
              loc == AppRoutes.register ||
              loc == AppRoutes.splash ||
              loc == AppRoutes.forgotPassword ||
              loc.startsWith('/reset');
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
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
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
        path: AppRoutes.saved,
        builder: (_, __) => const SavedPostsPage(),
      ),
      GoRoute(
        path: AppRoutes.blockedAccounts,
        builder: (_, __) => const BlockedAccountsPage(),
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
      GoRoute(
        path: '/mirror/:token',
        builder: (_, state) {
          final t = state.pathParameters['token'] ?? '';
          return MirrorResponsePage(token: t);
        },
      ),
      GoRoute(
        path: '/learn/:kind',
        builder: (_, state) {
          final kind = state.pathParameters['kind'] ?? 'crystals';
          return BadgeExplainerPage.fromName(kind);
        },
      ),
      GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchPage()),
      GoRoute(path: AppRoutes.myArticle, builder: (_, __) => const MyArticlePage()),
      GoRoute(path: AppRoutes.gameLobby, builder: (_, __) => const GameLobbyPage()),
      GoRoute(
        path: '/game/play/:id',
        builder: (_, state) => GamePlayPage(gameId: state.pathParameters['id'] ?? ''),
      ),
      // ────────── Games Hub + Carrom ──────────
      GoRoute(path: AppRoutes.gamesHub, builder: (_, __) => const GamesHubPage()),
      GoRoute(
        path: AppRoutes.carromLobby,
        builder: (_, __) => const CarromLobbyPage(),
      ),
      GoRoute(
        path: AppRoutes.carromCosmetics,
        builder: (_, __) => const CarromCosmeticsPage(),
      ),
      GoRoute(
        path: AppRoutes.carromMatchmaking,
        builder: (_, __) => const CarromMatchmakingPage(),
      ),
      GoRoute(
        path: '/games/carrom/match/:roomId',
        builder: (_, state) => CarromMatchPage(
          roomId: state.pathParameters['roomId'] ?? '',
        ),
      ),
      // Carrom v2 — local Box2D practice (no roomId, no WS).
      GoRoute(
        path: AppRoutes.carromPracticeV2,
        builder: (_, __) => const CarromMatchPageV2(),
      ),
      GoRoute(
        path: '/games/carrom/over/:roomId',
        builder: (_, state) {
          final outcome = state.extra;
          // Fallback لو المستخدم refreshe الصفحة بدون extra — نرجعه للوبي.
          if (outcome is! CarromOutcome) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // ignore: use_build_context_synchronously
            });
            return const CarromLobbyPage();
          }
          return CarromGameOverPage(
            roomId: state.pathParameters['roomId'] ?? '',
            outcome: outcome,
          );
        },
      ),
      // ────────── Ludo ──────────
      GoRoute(
        path: AppRoutes.ludoLobby,
        builder: (_, __) => const LudoLobbyPage(),
      ),
      GoRoute(
        path: AppRoutes.ludoMatchmaking,
        builder: (_, state) {
          final raw = state.uri.queryParameters['mode'] ?? '2p';
          return LudoMatchmakingPage(mode: LudoModeParse.parse(raw));
        },
      ),
      GoRoute(
        path: '/games/ludo/match/:roomId',
        builder: (_, state) => LudoMatchPage(
          roomId: state.pathParameters['roomId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/games/ludo/over/:roomId',
        builder: (_, state) {
          final outcome = state.extra;
          if (outcome is! LudoOutcome) {
            return const LudoLobbyPage();
          }
          return LudoGameOverPage(
            roomId: state.pathParameters['roomId'] ?? '',
            outcome: outcome,
          );
        },
      ),
      GoRoute(path: AppRoutes.help, builder: (_, __) => const HelpPage()),
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, __) => const LegalPage(kind: LegalKind.terms),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (_, __) => const LegalPage(kind: LegalKind.privacy),
      ),
      GoRoute(
        path: AppRoutes.contentPolicy,
        builder: (_, __) => const LegalPage(kind: LegalKind.contentPolicy),
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
