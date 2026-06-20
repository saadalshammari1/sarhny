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

  @override
  String get actionPlay => 'Play';

  @override
  String get actionPlayAgain => 'Play again';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSend => 'Send';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionLockIn => 'Lock in';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionBack => 'Back';

  @override
  String get actionLeave => 'Leave';

  @override
  String get actionLeaveLobby => 'Back to lobby';

  @override
  String get actionJoin => 'Join';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionPaste => 'Paste';

  @override
  String get actionDone => 'Done';

  @override
  String get labelLobby => 'Lobby';

  @override
  String get labelGamesHome => 'Arena';

  @override
  String get labelOpponent => 'Opponent';

  @override
  String get labelYou => 'You';

  @override
  String get labelMe => 'Me';

  @override
  String get labelAi => 'AI';

  @override
  String get labelVs => 'VS';

  @override
  String get labelTurnYours => 'Your turn';

  @override
  String get labelTurnTheirs => 'Opponent\'s turn';

  @override
  String get labelTurnAi => 'AI is thinking…';

  @override
  String labelRound(Object n) {
    return 'Round $n';
  }

  @override
  String get labelWaiting => 'Waiting…';

  @override
  String get labelWaitingOpponent => 'Waiting for opponent…';

  @override
  String get labelSearching => 'Finding opponent…';

  @override
  String get outcomeYouWon => 'You won!';

  @override
  String get outcomeYouLost => 'You lost';

  @override
  String get outcomeDraw => 'Draw';

  @override
  String get outcomeAiWins => 'AI wins';

  @override
  String get moodLight => 'Light';

  @override
  String get moodBold => 'Bold';

  @override
  String get moodFunny => 'Funny';

  @override
  String get moodChoose => 'Choose mood';

  @override
  String get lobbyVsRandom => 'Random opponent';

  @override
  String get lobbyVsAi => 'vs AI';

  @override
  String get lobbyVsAiSub => 'Instant practice — AI asks if it wins';

  @override
  String get lobbyInviteFriend => 'Play with a friend';

  @override
  String get lobbyInviteFriendSub => 'Generate an invite code to share';

  @override
  String get lobbyJoinByCode => 'Join with code';

  @override
  String get lobbyPasteCode => 'Paste the code';

  @override
  String get questionAsk => 'Ask your question';

  @override
  String get questionAnswer => 'Answer honestly';

  @override
  String get questionWaitingQ => 'Waiting for opponent\'s question…';

  @override
  String get questionWaitingA => 'Waiting for opponent\'s answer…';

  @override
  String get questionSkipNew => 'Get a new question';

  @override
  String get questionAbstainAd => 'Abstain · watch ad (+1 point)';

  @override
  String get questionAbstainNote =>
      'Abstaining ends the match without an answer and adds a point.';

  @override
  String get adLoading => 'Loading ad…';

  @override
  String get adIncomplete => 'Ad not finished';

  @override
  String get adUnavailable => 'No ad available';

  @override
  String get adDailyCap => 'Daily ad limit reached';

  @override
  String get adRewardEarned => 'Got a point — abstained.';

  @override
  String get rpsRock => 'Rock';

  @override
  String get rpsPaper => 'Paper';

  @override
  String get rpsScissors => 'Scissors';

  @override
  String get rpsChooseHand => 'Choose your hand';

  @override
  String get rpsGuessHand => 'Guess opponent\'s hand';

  @override
  String get rpsAiQuestionLabel => 'AI\'s question';

  @override
  String get rpsMyQuestionLabel => 'Your question for the AI';

  @override
  String get rpsAnswerPrivate =>
      'Your answer stays with you — not saved or sent.';

  @override
  String get xoCellFilled => 'Cell already taken — pick another';

  @override
  String get xoNotYourTurn => 'Not your turn yet';

  @override
  String get xoPracticeTitle => 'XO — Practice';

  @override
  String get leaveTitle => 'Leave the match?';

  @override
  String get leaveBody => 'Your round will count as a loss.';

  @override
  String get rematchTitle => 'Want a rematch?';

  @override
  String get rematchAccept => 'Play again';

  @override
  String get rematchDecline => 'I\'m done';

  @override
  String get rematchWaiting => 'Waiting for opponent\'s response…';

  @override
  String get rematchDeclined => 'Opponent declined the rematch';

  @override
  String get rematchTimeout => 'Rematch window closed';

  @override
  String get hubGameRps => 'Showdown';

  @override
  String get hubGameRpsSub =>
      'Rock · Paper · Scissors — winner asks the question';

  @override
  String get hubGameXo => 'Tic-Tac-Toe';

  @override
  String get hubGameXoSub => 'Three in a row — winner asks the question';

  @override
  String get hubAdEarnTitle => 'Watch a short ad';

  @override
  String get hubAdEarnSub =>
      'Daily limit 10 — points added to your wallet instantly.';

  @override
  String get hubAdPointBadge => '+1 point';

  @override
  String get hubTagAdNew => 'New';

  @override
  String get hubTagOnline => 'Online';

  @override
  String get hubSectionPlay => 'Play now';

  @override
  String get hubSectionEarn => 'Earn points without playing';

  @override
  String get hubAbstainHint =>
      'You can also abstain mid-game by watching an ad.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageAuto => 'Auto (device language)';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsAnonymousReceive => 'Receive anonymous messages';

  @override
  String get settingsVoiceReceive => 'Receive voice messages';

  @override
  String get settingsImageReceive => 'Receive images';

  @override
  String get settingsRegisteredOnly => 'From registered users only';

  @override
  String get settingsBlockedAccounts => 'Blocked accounts';

  @override
  String get settingsLikes => 'Likes';

  @override
  String get settingsComments => 'Comments';

  @override
  String get settingsFollowers => 'New followers';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsHelpCenter => 'Help center';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsContentPolicy => 'Content policy';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsUpdated => 'Updated';

  @override
  String get settingsUpdateFailed => 'Could not update';

  @override
  String get settingsPasswordShort => 'New password is too short';

  @override
  String get settingsPasswordCurrent => 'Current password';

  @override
  String get settingsPasswordNew => 'New password';

  @override
  String get settingsDeleteConfirmTitle => 'Permanently delete account';

  @override
  String get settingsDeleteConfirmBody =>
      'This cannot be undone — all your data will be erased.';

  @override
  String get settingsDeleteConfirmField => 'Confirm your password';

  @override
  String get settingsDeleteAction => 'Delete';

  @override
  String get settingsDeleteFailed => 'Could not delete';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorMatchLoad => 'Could not load match';

  @override
  String get errorGameStart => 'Could not start game';

  @override
  String get errorAdLaunch => 'Could not play ad';

  @override
  String get errorClipboardCopied => 'Copied';

  @override
  String get roundWon => 'You won this round';

  @override
  String get roundLost => 'Opponent won this round';

  @override
  String get roundDraw => 'No winner this round';

  @override
  String get gameOverTitle => 'Game over';

  @override
  String get revealingSoon => 'Revealing now…';

  @override
  String get nextRoundSoon => 'Next round starting…';

  @override
  String get leaveStay => 'Stay';

  @override
  String get answerWriteHint => 'Write your honest answer';

  @override
  String get questionWriteHint => 'Write your honest question';

  @override
  String get continueMatch => 'Continue';

  @override
  String get xoPageTitle => 'XO Challenge';

  @override
  String xoMovesProgress(Object moves, Object total) {
    return 'Move $moves/$total';
  }

  @override
  String get questionUsePresetCta => 'Or use a preset question';

  @override
  String get questionSkipUsed => 'Swap used';

  @override
  String questionYoursPrefix(Object q) {
    return 'Your question: $q';
  }

  @override
  String get xoLocalDrawSub => 'Tight game.';

  @override
  String get xoLocalWinSub => 'Three in a row — nice.';

  @override
  String get xoLocalLoseSub => 'Try again.';

  @override
  String get lobbyStartMatchSection => 'Start a match';

  @override
  String get lobbyVsRandomSub => 'Find an online opponent';

  @override
  String get xoLobbyHeroDescription =>
      'Beat your opponent to three in a row.\nThe winner asks a question. The loser answers.';

  @override
  String get gamePageTitle => 'Challenge 🎮';

  @override
  String get gameLobbyRandomSub =>
      '5 rounds rock-paper-scissors + guess • first to 5 points wins';

  @override
  String get gameRulesTitle => 'Quick rules';

  @override
  String get gameRule1 => 'Pick a hand and guess your opponent\'s pick';

  @override
  String get gameRule2 => 'Round win = 1 point. Correct guess = 1 point';

  @override
  String get gameRule3 => 'First to 5 points wins';

  @override
  String get gameRule4 => 'Winner writes a question for the loser (25 seconds)';

  @override
  String get gameRule5 => 'Abusive answers or questions → round is voided';

  @override
  String get gameUnusualEndSub => 'The round ended unexpectedly.';

  @override
  String get gameAnonymityTagline =>
      'Don\'t reveal your identity. Don\'t reveal your opponent\'s.';

  @override
  String secondsRemaining(Object n) {
    return '${n}s remaining';
  }

  @override
  String secondsToAnswer(Object n) {
    return '${n}s to answer';
  }

  @override
  String secondsShort(Object n) {
    return '${n}s';
  }

  @override
  String get questionAutoFallbackPrefix => 'Auto question if you don\'t write:';

  @override
  String get questionFromOpponent => 'Question from your opponent';

  @override
  String get questionAppearingSoon =>
      'The question will appear shortly. Hang on.';

  @override
  String get questionSent =>
      'Question sent — their answer arrives in a moment.';

  @override
  String get rpsPracticeTitle => 'Challenge — Practice';

  @override
  String get rpsLocalAskHint => 'Ask a candid question... (for fun only)';

  @override
  String get rpsLocalAiPreparing => 'Preparing a question...';

  @override
  String get rpsLocalAnswerHint => 'Answer to yourself...';

  @override
  String get ludoPowerTitle => 'Power Ludo';

  @override
  String get ludoPowerSubtitle =>
      '4-player Ludo with superpowers — Rocket, Freeze, Portal, Tornado. Powers reshuffle every 3 rolls.';

  @override
  String get ludoLobbyChooseMode => 'Choose mode';

  @override
  String get ludoMode2Players => 'Two players (1v1)';

  @override
  String get ludoMode2PlayersSub => 'You vs. a bot — faster, more intense';

  @override
  String get ludoMode4Players => 'Four players';

  @override
  String get ludoMode4PlayersSub => 'You vs. 3 bots — the full experience';

  @override
  String get ludoStartTap => 'Tap the dice to start';

  @override
  String get ludoTapPawn => 'Pick a pawn to move';

  @override
  String get ludoExtraTurn => 'Extra turn! Roll again';

  @override
  String get ludoYourTurn => 'Your turn — roll the dice';

  @override
  String ludoBotTurn(Object name) {
    return '$name is playing…';
  }

  @override
  String get ludoRollDice => 'Roll the dice';

  @override
  String ludoTurnLabel(Object name) {
    return '$name\'s turn';
  }

  @override
  String get ludoYouWin => '🎉 You won!';

  @override
  String ludoBotWin(Object name) {
    return '$name won';
  }

  @override
  String get ludoYouWinSub => 'All four of your pieces reached the centre';

  @override
  String get ludoLossSub => 'Better luck next round';

  @override
  String get ludoNewGame => 'New game';

  @override
  String get ludoNoMove => 'No move';

  @override
  String get ludoPlayerGold => 'Gold';

  @override
  String get ludoPlayerBlue => 'Blue';

  @override
  String get ludoPlayerPurple => 'Purple';

  @override
  String get ludoPlayerGreen => 'Green';

  @override
  String ludoEventRocket(Object boost) {
    return 'Rocket! +$boost';
  }

  @override
  String get ludoEventFreeze => 'Frozen!';

  @override
  String ludoEventPortalForward(Object diff) {
    return 'Portal! +$diff';
  }

  @override
  String ludoEventPortalBack(Object diff) {
    return 'Portal! -$diff';
  }

  @override
  String get ludoEventTornado => 'Tornado!';

  @override
  String get ludoEventCapture => 'Captured!';

  @override
  String get ludoEventShuffle => 'Powers reshuffled';

  @override
  String get hubGameLudoPower => 'Power Ludo';

  @override
  String get hubGameLudoPowerSub => '4-player Ludo with superpowers — featured';

  @override
  String get hubTagFeatured => 'Featured';

  @override
  String get ludoPlayerYou => 'You';

  @override
  String ludoOpponentN(Object n) {
    return 'Opponent $n';
  }

  @override
  String get ludoBotThinking => 'Thinking…';

  @override
  String get ludoMmTitle => 'Finding opponents';

  @override
  String get ludoMmSearching => 'Searching for players…';

  @override
  String get ludoMmRealPlayers => 'Looking for real players';

  @override
  String ludoMmCountdownHint(Object seconds) {
    return 'We\'ll fill with bots in ${seconds}s if none found';
  }

  @override
  String get ludoMmFilledByBots => 'Filled with skilled bots';

  @override
  String get ludoMmMatchFound => 'Match found!';

  @override
  String get ludoMmCancel => 'Cancel search';

  @override
  String get ludoMmStarting => 'Starting match…';

  @override
  String ludoMmFoundCount(Object found, Object total) {
    return '$found/$total players';
  }

  @override
  String get ludoMode1v1 => '1v1 opponent';

  @override
  String get ludoMode1v1Sub => 'Quick match, anonymous identity';

  @override
  String get ludoMode4Party => '4-player party';

  @override
  String get ludoMode4PartySub => 'Search for 3 opponents • bots fill the gaps';

  @override
  String get ludoLobbyHowToPlay => 'How to play';

  @override
  String get ludoRule1 =>
      'Roll the dice, leave home on six, get all 4 pieces to centre';

  @override
  String get ludoRule2 => '4 super-powers on the path: 🚀 ❄ 🌀 🌪';

  @override
  String get ludoRule3 => 'Capturing an opponent grants an extra turn';

  @override
  String get ludoRule4 =>
      'Stars are safe cells • powers reshuffle every 3 rolls';
}
