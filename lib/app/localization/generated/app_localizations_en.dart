// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sarhny';

  @override
  String get tagline => 'Authentic self-expression';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginEmailOrUsername => 'Username or email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerName => 'Name';

  @override
  String get registerUsername => 'Username';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get navHome => 'Home';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navCompose => 'Post';

  @override
  String get navMirrors => 'Mirrors';

  @override
  String get navProfile => 'Profile';

  @override
  String get feedGlobalTab => 'Global';

  @override
  String get feedFollowingTab => 'Following';

  @override
  String get feedSectionAll => 'All';

  @override
  String get feedSectionMoment => 'Moments';

  @override
  String get feedSectionFace => 'Faces';

  @override
  String get feedSectionMind => 'Minds';

  @override
  String get postCrystalBadge => 'Crystal';

  @override
  String get postLayersHint => 'Read';

  @override
  String get postGravityApproaching => 'approaching crystallization';

  @override
  String get postGravityFading => 'fading';

  @override
  String get composeChooseSection => 'Choose a section';

  @override
  String get composeMoment => 'Moment';

  @override
  String get composeFace => 'Face';

  @override
  String get composeMind => 'Mind';

  @override
  String get composeLayer1 => 'Primary text';

  @override
  String get composeLayer2 => 'Add image (optional)';

  @override
  String get composeLayer3 => 'Write a deeper article (optional)';

  @override
  String get composeCrystallizeHint =>
      'Starts with 24h life — crystallizes on resonance';

  @override
  String get composePublish => 'Publish';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileFollow => 'Follow';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileBlock => 'Block';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileCrystals => 'Crystals';

  @override
  String get profileReplies => 'Replies';

  @override
  String get profileTabCrystals => 'Crystals';

  @override
  String get profileTabActive => 'Active';

  @override
  String get profileTabMirrors => 'Mirrors';

  @override
  String get profileTabLikes => 'Likes';

  @override
  String get inboxTitle => 'Anonymous messages';

  @override
  String get inboxEmpty => 'No messages yet';

  @override
  String get inboxReplyPublic => 'Reply publicly';

  @override
  String get inboxIgnore => 'Ignore';

  @override
  String get inboxReport => 'Report';

  @override
  String get inboxDelete => 'Delete';

  @override
  String get mirrorsTitle => 'Mirrors';

  @override
  String get mirrorsCreate => 'Create a new mirror';

  @override
  String get mirrorsShare => 'Share link';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsAnonymous => 'Anonymous messages';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonShare => 'Share';

  @override
  String get commonReport => 'Report';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonEmpty => 'No content';

  @override
  String get gamesHubTitle => 'Games';

  @override
  String get carromTitle => 'Carrom 1v1';

  @override
  String get carromSubtitle =>
      'Challenge an anonymous opponent — win their points';

  @override
  String get carromLobbyPlayRandom => 'Start random match';

  @override
  String get carromLobbyPlayRandomSub => 'Find an opponent available now';

  @override
  String get carromLobbyInvite => 'Play with a friend';

  @override
  String get carromLobbyInviteSub => 'Generate an invite code to share';

  @override
  String get carromLobbyJoinByCode => 'Join with code';

  @override
  String get carromLobbyJoinHint => 'Paste the code';

  @override
  String get carromLobbyJoinAction => 'Join';

  @override
  String carromLobbyEntryFee(Object entry, Object pot) {
    return 'Entry $entry — winner takes $pot';
  }

  @override
  String get carromMmSearching => 'Finding opponent...';

  @override
  String get carromMmCancel => 'Cancel search';

  @override
  String carromMmQueue(Object pos) {
    return 'Your queue position: $pos';
  }

  @override
  String get carromMatchYourTurn => 'Your turn';

  @override
  String get carromMatchOppTurn => 'Opponent\'s turn';

  @override
  String get carromMatchConcede => 'Concede';

  @override
  String get carromMatchConcedeConfirm =>
      'If you concede now, your opponent wins the full pot.';

  @override
  String get carromMatchReconnect => 'Reconnecting to server...';

  @override
  String get carromOpponentUnknown => 'Anonymous opponent';

  @override
  String get carromOpponentTurnNow => 'Their turn';

  @override
  String get carromOpponentWaiting => 'Waiting for turn';

  @override
  String get carromAimHint => 'Drag from the striker inward to aim';

  @override
  String get carromGameOverWon => 'You won!';

  @override
  String get carromGameOverLost => 'Better luck next time';

  @override
  String get carromGameOverReveal => 'Reveal your identity';

  @override
  String get carromGameOverHide => 'Stay anonymous';

  @override
  String get carromGameOverSarhny => 'Send a Sarhny message';

  @override
  String get carromGameOverRematch => 'New match';

  @override
  String get carromGameOverLobby => 'Lobby';

  @override
  String get carromWalletEarn1 => 'Each Sarhny message you receive';

  @override
  String get carromWalletEarn2 => 'Watch a short ad';

  @override
  String get carromWalletEarn3 => 'Win a Carrom match';

  @override
  String get carromCosmeticsTitle => 'Customize your game';

  @override
  String get carromCosmeticsTabBoard => 'Board';

  @override
  String get carromCosmeticsTabPieces => 'Pieces';

  @override
  String get carromCosmeticsTabStriker => 'Striker';

  @override
  String get carromCosmeticsLockedHint => 'Earn points to unlock this skin';

  @override
  String carromCosmeticsSaved(Object name) {
    return 'Selected $name';
  }

  @override
  String get carromCosmeticsSaveFailed => 'Couldn\'t save, please try again';

  @override
  String get carromLobbyCustomize => 'Customize your game';

  @override
  String get carromLobbyCustomizeSub =>
      'Pick your board, piece colors, and striker';
}
