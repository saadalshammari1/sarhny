import 'package:flutter/foundation.dart';
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
import '../features/game/presentation/pages/rps_local_play_page.dart';
import '../features/xo/presentation/pages/xo_lobby_page.dart';
import '../features/xo/presentation/pages/xo_local_play_page.dart';
import '../features/xo/presentation/pages/xo_play_page.dart';
import '../features/games/games_hub_page.dart';
import '../features/games/carrom3/presentation/carrom3_match_page.dart';
import '../features/games/ludo3/presentation/ludo3_lobby_page.dart';
import '../features/games/ludo_power/screens/ludo_power_lobby.dart';
import '../features/games/carrom3/presentation/carrom3_matchmaking_page.dart';
import '../features/games/carrom3/presentation/carrom3_online_match_page.dart';
import '../features/profile/presentation/pages/saved_posts_page.dart';
import '../features/settings/presentation/pages/blocked_accounts_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'localization/generated/app_localizations.dart';

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
  /// Local vs-AI RPS — single-device, no backend, instant play.
  static const String gameLocal = '/game/local';
  // Tic-Tac-Toe (XO) — sibling to RPS, same winner→question→answer flow.
  static const String xoLobby = '/xo';
  static String xoPlay(String id) => '/xo/play/$id';
  /// Local vs-AI XO — single-device, no backend, instant play.
  static const String xoLocal = '/xo/local';

  // Games hub + Carrom
  static const String gamesHub = '/games';
  static const String codexLudo = '/games/codex/ludo';
  static const String codexCarrom = '/games/codex/carrom';
  static const String carromLobby = '/games/carrom';
  static const String carromCosmetics = '/games/carrom/cosmetics';
  static const String carromMatchmaking = '/games/carrom/matchmaking';
  static String carromMatch(String roomId) => '/games/carrom/match/$roomId';
  static String carromGameOver(String roomId) => '/games/carrom/over/$roomId';

  /// Carrom v2 — local Box2D practice mode. New physics + new UI; runs
  /// independently of the WS matchmaking flow above.
  static const String carromPracticeV2 = '/games/carrom/practice-v2';

  /// Carrom Pro — single-device match vs the heuristic AI (Box2D physics,
  /// predictive aim, real scoring). The flagship Carrom entry in the hub.
  static const String carromPro = '/games/carrom/pro';

  /// Carrom v3 — full from-scratch rebuild (hand-written engine, 3 tables +
  /// 4 coin sets, precise controls). The current Carrom entry in the hub.
  static const String carrom3 = '/games/carrom3';

  /// Carrom v3 online — matchmaking lobby + the deterministic-lockstep match.
  static const String carrom3Online = '/games/carrom3/online';
  static const String carrom3OnlineMatch = '/games/carrom3/online/match';

  /// Carrom v2 — online matchmaking + online match.
  static const String carromV2Matchmaking = '/games/carrom/online-v2/find';
  static const String carromV2Match = '/games/carrom/online-v2/match';

  // Ludo
  static const String ludoLobby = '/games/ludo';
  static const String ludoMatchmaking = '/games/ludo/matchmaking';
  static String ludoMatch(String roomId) => '/games/ludo/match/$roomId';
  static String ludoGameOver(String roomId) => '/games/ludo/over/$roomId';

  /// Ludo v2 — local pass-and-play (2/3/4 players on the same device).
  /// Query string supports ?players=2|3|4 (default 4) and
  /// ?variant=normal|magic.
  static const String ludoLocalV2 = '/games/ludo/local-v2';

  // Ludo v3 — from-scratch rebuild (classic + magic, 1v1 / 2v2 / 4p).
  static const String ludo3 = '/games/ludo3';

  // Ludo Power — premium royal 4-player Ludo with on-board powers.
  static const String ludoPower = '/games/ludo-power';
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
          final isGamesPreviewRoute = kIsWeb && loc.startsWith('/games');
          final isPublic = isGamesPreviewRoute ||
              loc.startsWith('/u/') ||
              loc.startsWith('/post/') ||
              loc.startsWith('/mirror/');
          final isAuthRoute = loc == AppRoutes.login ||
              loc == AppRoutes.register ||
              loc == AppRoutes.splash ||
              loc == AppRoutes.forgotPassword ||
              loc.startsWith('/reset');
          if (kIsWeb && loc == AppRoutes.splash) {
            return AppRoutes.gamesHub;
          }
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
      GoRoute(
          path: AppRoutes.mirrors, builder: (_, __) => const MyMirrorPage()),
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
      GoRoute(
          path: AppRoutes.myArticle, builder: (_, __) => const MyArticlePage()),
      GoRoute(
          path: AppRoutes.gameLobby, builder: (_, __) => const GameLobbyPage()),
      GoRoute(
        path: AppRoutes.gameLocal,
        builder: (_, __) => const RpsLocalPlayPage(),
      ),
      GoRoute(
        path: '/game/play/:id',
        builder: (_, state) =>
            GamePlayPage(gameId: state.pathParameters['id'] ?? ''),
      ),
      // ────────── XO (Tic-Tac-Toe) ──────────
      GoRoute(
        path: AppRoutes.xoLobby,
        builder: (_, __) => const XoLobbyPage(),
      ),
      GoRoute(
        path: AppRoutes.xoLocal,
        builder: (_, __) => const XoLocalPlayPage(),
      ),
      GoRoute(
        path: '/xo/play/:id',
        builder: (_, state) =>
            XoPlayPage(gameId: state.pathParameters['id'] ?? ''),
      ),
      // ────────── Games Hub + Carrom ──────────
      GoRoute(
          path: AppRoutes.gamesHub, builder: (_, __) => const GamesHubPage()),
      // Carrom v3 — from-scratch rebuild.
      GoRoute(
        path: AppRoutes.carrom3,
        builder: (_, __) => const Carrom3MatchPage(),
      ),
      // Carrom v3 — online matchmaking lobby.
      GoRoute(
        path: AppRoutes.carrom3Online,
        builder: (_, __) => const Carrom3MatchmakingPage(),
      ),
      // Carrom v3 — online deterministic-lockstep match.
      GoRoute(
        path: AppRoutes.carrom3OnlineMatch,
        builder: (context, state) {
          final room = state.uri.queryParameters['room'] ?? '';
          final seat = state.uri.queryParameters['seat'] == 'b' ? 'b' : 'a';
          return Carrom3OnlineMatchPage(roomId: room, mySeat: seat);
        },
      ),
      // Ludo v3 — lobby (classic + magic, 1v1 / 2v2 / 4p).
      GoRoute(
        path: AppRoutes.ludo3,
        builder: (_, __) => const Ludo3LobbyPage(),
      ),
      // Ludo Power — lobby (game type + cosmetics) → premium royal Ludo.
      GoRoute(
        path: AppRoutes.ludoPower,
        builder: (_, __) => const LudoPowerLobby(),
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(child: Text(l.commonComingSoon)),
    );
  }
}
