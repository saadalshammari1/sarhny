/// كل عناوين الـ Sarhny V2 Backend في مكان واحد.
///
/// Backend prefix: `/api/v1`
/// كل المسارات نسبية للـ baseUrl المضبوط في `.env`.
class ApiEndpoints {
  ApiEndpoints._();

  // ────────── Auth ──────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String logoutAll = '/api/v1/auth/logout-all';
  static const String passwordReset = '/api/v1/auth/reset';
  static const String passwordResetConfirm = '/api/v1/auth/reset/confirm';

  // ────────── Feed ──────────
  static const String feedGlobal = '/api/v1/feed/global';
  static const String feedFollowing = '/api/v1/feed/following';

  // ────────── Posts ──────────
  static const String posts = '/api/v1/posts';
  static String postById(int id) => '/api/v1/posts/$id';
  static String postLayerRead(int id, int layer) =>
      '/api/v1/posts/$id/layer/$layer/read';
  static String postComments(int id) => '/api/v1/posts/$id/comments';
  static const String postsUploadImage = '/api/v1/posts/upload-image';

  // ────────── Anon Replies (V2 new) ──────────
  static String postReplies(int id) => '/api/v1/posts/$id/anon-replies';
  static String hideReply(int postId, int rid) =>
      '/api/v1/posts/$postId/anon-replies/$rid';
  static String reportReply(int postId, int rid) =>
      '/api/v1/posts/$postId/anon-replies/$rid/report';

  // ────────── Uploads (voice/image for messages) ──────────
  static const String uploadsVoice = '/api/v1/uploads/voice';
  static const String uploadsImage = '/api/v1/uploads/image';

  // ────────── Profile ──────────
  static String publicProfile(String username) =>
      '/api/v1/users/$username';
  static String profileCrystals(String username) =>
      '/api/v1/users/$username/crystals';
  static String profileActive(String username) =>
      '/api/v1/users/$username/active';
  static String profileLikes(String username) =>
      '/api/v1/users/$username/likes';
  static const String profileEdit = '/api/v1/profile/edit';
  static const String profileAvatar = '/api/v1/profile/avatar';
  static const String profileCover = '/api/v1/profile/cover';
  static const String profileUsername = '/api/v1/profile/username';

  // ────────── Inbox / Anonymous ──────────
  static const String inbox = '/api/v1/inbox';
  static String inboxAnswer(int id) => '/api/v1/inbox/$id/answer';
  static String inboxReport(int id) => '/api/v1/inbox/$id/report';
  static String inboxDelete(int id) => '/api/v1/inbox/$id';
  static String inboxRead(int id) => '/api/v1/inbox/$id/read';
  static const String anonymousSend = '/api/v1/anonymous/send';
  static String publicAsk(String username) =>
      '/api/v1/public/$username/ask';

  // ────────── Mirrors ──────────
  static const String mirrors = '/api/v1/mirrors';
  static const String mirrorsMe = '/api/v1/mirrors/me';
  static String publicMirror(String token) =>
      '/api/v1/public/mirror/$token';
  static String publicMirrorRespond(String token) =>
      '/api/v1/public/mirror/$token/respond';
  static String mirrorRespondAuthed(String token) =>
      '/api/v1/mirrors/$token/respond';

  // ────────── Interactions ──────────
  static const String like = '/api/v1/interactions/like';
  static String unlike(int postId) => '/api/v1/interactions/like/$postId';
  static const String save = '/api/v1/interactions/save';
  static String unsave(int postId) => '/api/v1/interactions/save/$postId';
  static const String comment = '/api/v1/interactions/comment';
  static String deleteComment(int commentId) =>
      '/api/v1/interactions/comment/$commentId';
  static const String share = '/api/v1/interactions/share';

  // ────────── Attention + Streaks ──────────
  static const String attentionBalance = '/api/v1/attention/balance';
  static const String streakMe = '/api/v1/streaks/me';
  static const String streakFreeze = '/api/v1/streaks/freeze';

  // ────────── Social (follow / block / leaderboard) ──────────
  static String follow(int userId) => '/api/v1/follow/$userId';
  static String block(int userId) => '/api/v1/block/$userId';
  static const String leaderboard = '/api/v1/users/leaderboard';
  static String userFollowers(String username) =>
      '/api/v1/users/$username/followers';
  static String userFollowing(String username) =>
      '/api/v1/users/$username/following';

  // ────────── Settings ──────────
  static const String settings = '/api/v1/settings';
  static const String settingsAccount = '/api/v1/settings/account';
  static const String settingsPassword = '/api/v1/settings/password';
  static const String settingsPrivacy = '/api/v1/settings/privacy';
  static const String settingsNotifications = '/api/v1/settings/notifications';
  static const String settingsAnonymous = '/api/v1/settings/anonymous';
  static const String settingsTheme = '/api/v1/settings/theme';
  static const String settingsDeleteAccount = '/api/v1/settings/account';

  // ────────── Notifications ──────────
  static const String notifications = '/api/v1/notifications';
  static const String notificationsMarkRead = '/api/v1/notifications/mark-read';
  static const String notificationsUnreadCount =
      '/api/v1/notifications/unread/count';

  // ────────── Subscription ──────────
  static const String subscriptionTiers = '/api/v1/subscription/tiers';
  static const String subscriptionMe = '/api/v1/subscription/me';
  static String subscriptionUpgrade(String tier) =>
      '/api/v1/subscription/upgrade/$tier';
  static const String subscriptionCancel = '/api/v1/subscription/cancel';

  // ────────── Devices (FCM tokens) ──────────
  static const String devices = '/api/v1/devices';

  // ────────── Help / Onboarding ──────────
  static const String helpFeatures = '/api/v1/help/features';
  static const String helpOnboarding = '/api/v1/help/onboarding';
  static const String helpFaq = '/api/v1/help/faq';
  static const String helpChangelog = '/api/v1/help/changelog';
}
