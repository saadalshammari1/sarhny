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
  String get ludoYourTurn => 'Your turn';

  @override
  String ludoBotTurn(Object name) {
    return '$name is playing…';
  }

  @override
  String get ludoRollDice => 'Roll dice';

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

  @override
  String get rpsGuessExplain =>
      'Guess your opponent\'s pick — get it right for a bonus point on top of your round win!';

  @override
  String get rateEnjoyTitle => 'Enjoying Sarhny?';

  @override
  String get rateEnjoyBody => 'Your rating helps Sarhny grow 💜';

  @override
  String get rateLove => 'Loving it 😍';

  @override
  String get rateMeh => 'Could be better';

  @override
  String get rateLater => 'Later';

  @override
  String get rateFeedbackTitle => 'How can we improve?';

  @override
  String get rateFeedbackHint => 'Write your feedback…';

  @override
  String get rateSend => 'Send';

  @override
  String get rateThanks => 'Thanks for your feedback! 💜';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get errorInvalidCredentials => 'Incorrect username or password';

  @override
  String get errorServerUnreachable => 'Couldn\'t reach the server';

  @override
  String get errorConnectionLost => 'Connection lost';

  @override
  String get errorUnexpected => 'Something went wrong';

  @override
  String get loginUsernameHint => 'e.g. ssarhny';

  @override
  String get loginSubtitle => 'Sign in to continue on Sarhny';

  @override
  String get registerAgeConfirmError => 'You must confirm you are 18 or older';

  @override
  String get registerTermsError => 'You must agree to the terms';

  @override
  String get registerUsernameTaken => 'Username is taken';

  @override
  String get registerUsernameFormat =>
      'Latin letters, numbers and underscores only';

  @override
  String get registerUsernameInvalid => 'Invalid username';

  @override
  String get registerEmailTaken => 'Email is already in use';

  @override
  String get registerEmailInvalid => 'Invalid email';

  @override
  String get registerPasswordWeak => 'Password is too short or doesn\'t match';

  @override
  String get registerSexRequired => 'Select your gender';

  @override
  String get registerUsernameMin => 'At least 3 characters';

  @override
  String get registerUsernameReserved => 'Reserved name';

  @override
  String get registerEmailInvalidShort => 'Invalid email';

  @override
  String get registerPasswordMin => 'At least 8 characters';

  @override
  String get registerPasswordMismatch => 'Doesn\'t match the password';

  @override
  String get registerJoinTitle => 'Join Sarhny';

  @override
  String get registerJoinSubtitle =>
      'A space for authentic self-expression — adults only';

  @override
  String get registerDisplayName => 'Display name';

  @override
  String get registerNameMin => 'At least 2 characters';

  @override
  String get registerUsernameHint => 'e.g. amal_x';

  @override
  String get registerPasswordConfirm => 'Confirm password';

  @override
  String get registerAgeConfirm => 'I confirm I am 18 or older';

  @override
  String get registerAdultsOnly => 'Sarhny is for adults only';

  @override
  String get registerAgreeTerms =>
      'I agree to the Terms of Use and Privacy Policy';

  @override
  String get registerHaveAccount => 'Have an account?';

  @override
  String get registerSignInCta => 'Sign in';

  @override
  String get registerGender => 'Gender';

  @override
  String get registerGenderMale => 'Male';

  @override
  String get registerGenderFemale => 'Female';

  @override
  String get forgotTitle => 'Recover password';

  @override
  String get forgotInstructions =>
      'Enter your registered email and we\'ll send you a link to reset your password within one hour.';

  @override
  String get forgotSendLink => 'Send link';

  @override
  String get forgotBackToLogin => 'Back to sign in';

  @override
  String get forgotCheckEmailTitle => 'Check your email';

  @override
  String get forgotEmailSentBody =>
      'If this email is registered, we\'ve sent a recovery link to';

  @override
  String get forgotCheckSpamHint =>
      'Check your inbox (and the spam folder too sometimes)';

  @override
  String get resetLinkExpired => 'The link has expired or is invalid';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String get resetHeading => 'New password';

  @override
  String get resetSubtitle => 'Choose a strong new password for your account.';

  @override
  String get resetPasswordMismatch => 'Doesn\'t match';

  @override
  String get resetDoneTitle => 'Password updated';

  @override
  String get resetDoneBody => 'You can now sign in with your new password.';

  @override
  String get resetGoToLogin => 'Sign in';

  @override
  String get diagnosticsTitle => 'Connection diagnostics';

  @override
  String get diagnosticsEnvStatus => '.env status';

  @override
  String get diagnosticsConnectionStatus => 'Connection status';

  @override
  String get diagnosticsHint =>
      'Tap \"Test connection\" to see what happens when connecting to the server.';

  @override
  String get diagnosticsTestButton => 'Test connection';

  @override
  String get feedSearchTooltip => 'Search';

  @override
  String get feedEmptyFollowingTitle => 'No posts yet';

  @override
  String get feedEmptySectionTitle => 'Nothing in this section';

  @override
  String get feedEmptyFollowingSubtitle => 'Follow people to see their posts';

  @override
  String get feedEmptySectionSubtitle => 'Be the first to post something ⚡';

  @override
  String get feedScopeFollowing => 'Following';

  @override
  String get feedScopeGlobal => 'Global';

  @override
  String get feedCrystalBadge => '✦ Crystal';

  @override
  String get feedQuestionFromAnonymous => 'Question from anonymous';

  @override
  String get feedQuestionFrom => 'Question from';

  @override
  String get feedUnsave => 'Unsave';

  @override
  String get feedSave => 'Save';

  @override
  String get feedShareFooter => '— from Sarhny';

  @override
  String get feedDeleteTitle => 'Delete post';

  @override
  String get feedDeleteBody =>
      'Your post will be permanently deleted and will no longer be visible to others. Are you sure?';

  @override
  String get feedDeleteSuccess => 'Post deleted';

  @override
  String get feedDeleteFailed => 'Couldn\'t delete';

  @override
  String get feedTimeNow => 'now';

  @override
  String get feedTimeAgo => 'قبل';

  @override
  String feedTimeMinutes(Object n) {
    return '$n min ago';
  }

  @override
  String feedTimeHours(Object n) {
    return '${n}h ago';
  }

  @override
  String feedTimeDays(Object n) {
    return '${n}d ago';
  }

  @override
  String feedTimeSeconds(Object n) {
    return '${n}s ago';
  }

  @override
  String feedTimeWeeks(Object n) {
    return '${n}w ago';
  }

  @override
  String feedTimeMonths(Object n) {
    return '${n}mo ago';
  }

  @override
  String feedTimeYears(Object n) {
    return '${n}y ago';
  }

  @override
  String get sectionAll => 'All';

  @override
  String get sectionMoments => 'Moments';

  @override
  String get sectionFaces => 'Faces';

  @override
  String get sectionMinds => 'Minds';

  @override
  String get sectionAnswers => 'Answers';

  @override
  String get ludoTitle => 'Ludo';

  @override
  String get ludoCustomizeSub => 'Boards & knights — customize your look';

  @override
  String get ludoPlayType => 'Game type';

  @override
  String get ludoClassic => 'Classic';

  @override
  String get ludoClassicSub => 'Classic Ludo';

  @override
  String get ludoPowers => 'Special powers';

  @override
  String get ludoPowersSub => 'Rocket • Freeze • Portal • Tornado';

  @override
  String get ludoPlay => 'Play';

  @override
  String get ludoRoyalSub => 'Royal Ludo — 4 players, dice & on-board powers';

  @override
  String get ludoBoardsKnights => 'Boards & Knights';

  @override
  String get ludoPickBoard => 'Choose board';

  @override
  String get ludoPickKnight => 'Choose knights';

  @override
  String get ludoAutoPlayed => 'Time is up — we played for you';

  @override
  String get ludoYouWon => '🎉 You won!';

  @override
  String ludoPlayerWon(Object name) {
    return '$name won';
  }

  @override
  String get ludoWinSub => 'You got all four pieces home';

  @override
  String get ludoLoseSub => 'Better luck next round';

  @override
  String get ludoEnded => 'Ended';

  @override
  String ludoPlayerTurn(Object name) {
    return '$name to play';
  }

  @override
  String get ludoChat => 'Chat';

  @override
  String get ludoExit => 'Exit';

  @override
  String get ludoEvCapture => 'Captured a piece!';

  @override
  String get ludoEvTornado => 'Tornado!';

  @override
  String ludoEvRocket(Object n) {
    return 'Rocket! +$n';
  }

  @override
  String get ludoEvFreeze => 'Frozen!';

  @override
  String ludoEvPortal(Object n) {
    return 'Portal! $n';
  }

  @override
  String get ludoEvShuffle => 'Powers shuffled';

  @override
  String get ludoColorGold => 'Gold';

  @override
  String get ludoColorBlue => 'Blue';

  @override
  String get ludoColorPurple => 'Purple';

  @override
  String get ludoColorYou => 'You';

  @override
  String get ludoSkinRoyal => 'Royal Gold';

  @override
  String get ludoSkinNeon => 'Neon Cyber';

  @override
  String get ludoSkinArabian => 'Arabian Nights';

  @override
  String get ludoKnightClassic => 'Classic';

  @override
  String get ludoKnightKnight => 'Knight';

  @override
  String get ludoKnightSorcerer => 'Sorcerer';

  @override
  String get ludoKnightCrown => 'Crown';

  @override
  String get ludoHubSubtitle =>
      'Royal Ludo — 4 players with on-board powers 🚀❄️🌀🌪';

  @override
  String get ludoHubTag => 'New';

  @override
  String get inboxAppBarTitle => 'Inbox';

  @override
  String get inboxEmptyTitle => 'Inbox is empty';

  @override
  String get inboxEmptySubtitle => 'Anonymous messages will appear here';

  @override
  String get inboxMarkedRead => 'Marked as read';

  @override
  String get inboxUpdateFailed => 'Couldn\'t update';

  @override
  String get inboxDeleted => 'Deleted';

  @override
  String get inboxDeleteFailed => 'Couldn\'t delete';

  @override
  String get inboxReported => 'Reported — we\'ll review it';

  @override
  String get inboxReportFailed => 'Couldn\'t report';

  @override
  String get inboxAnonymous => 'Anonymous';

  @override
  String get inboxReplyWithPost => 'Reply with a post';

  @override
  String get inboxAnswered => 'Answered';

  @override
  String get inboxReportTooltip => 'Report';

  @override
  String get inboxAnswerEmptyError => 'Write your reply first';

  @override
  String get inboxReplyPublished => 'Reply published ✨';

  @override
  String get inboxSessionExpired => 'Please sign in again';

  @override
  String get inboxRateLimited => 'Slow down, try again in a minute';

  @override
  String get inboxConnectionFailed => 'Connection failed —';

  @override
  String get inboxYourReplyLabel =>
      'Your reply (will be published as a post 🎨)';

  @override
  String get inboxReplyHint => 'Write your reply…';

  @override
  String get inboxHideLayer3 => 'Hide layer 3';

  @override
  String get inboxAddLayer3 => 'Add layer 3 — reflection';

  @override
  String get inboxLayer3Hint => 'Your reflection (optional)';

  @override
  String get inboxPublishReply => 'Publish reply';

  @override
  String get mirrorsNewMirror => 'New mirror';

  @override
  String get mirrorsEmptyTitle => 'No mirrors yet';

  @override
  String get mirrorsEmptySubtitle =>
      'Start posting mirrors — ask a question and let people answer honestly';

  @override
  String get mirrorsBadge => '🪞 Mirror';

  @override
  String get mirrorsResponsesSuffix => 'replies';

  @override
  String get mirrorsCopyLink => 'Copy link';

  @override
  String get mirrorsShareMessage => 'Share your answer to this mirror with me:';

  @override
  String get mirrorsShareSubject => 'Sarhny — Mirror';

  @override
  String get mirrorsShareFailed => 'Couldn\'t open sharing';

  @override
  String get mirrorsQuestionLabel => 'Mirror question';

  @override
  String get mirrorsCreateHint =>
      'A guiding question for self-discovery — replies are anonymous and build a word cloud.';

  @override
  String get mirrorsQuestionHint => 'e.g. What makes you proud of yourself?';

  @override
  String get mirrorsCreateButton => 'Create mirror';

  @override
  String get mirrorsCreated => 'Mirror created';

  @override
  String get mirrorsCreateFailed => 'Couldn\'t create';

  @override
  String get mirrorsLoginToRespond => 'Sign in to reply to the mirror';

  @override
  String get mirrorsRateLimit =>
      'You\'ve replied a lot recently — wait a moment';

  @override
  String get mirrorsSendFailed => 'Couldn\'t send';

  @override
  String get mirrorsBadgeShort => 'Mirror';

  @override
  String get mirrorsQuestionTitle => 'The question';

  @override
  String get mirrorsResponseHint =>
      'Write your honest reply — your identity won\'t show';

  @override
  String get mirrorsAnonymousNote =>
      'You can reply without signing in — your identity will never show';

  @override
  String get mirrorsSendResponse => 'Send my reply';

  @override
  String get mirrorsFrom => 'Mirror from';

  @override
  String get mirrorsSentTitle => 'Your reply was sent';

  @override
  String get mirrorsSentBody =>
      'Your words will add to the word cloud the mirror\'s owner sees. Thank you for your honesty 🌙';

  @override
  String get mirrorsBackHome => 'Back to home';

  @override
  String get postTitle => 'Post';

  @override
  String get postReplyHint => 'Write your reply…';

  @override
  String get postMicPermission => 'Microphone permission required';

  @override
  String get postRecordStartFailed => 'Couldn\'t start recording';

  @override
  String get postImagePickFailed => 'Couldn\'t pick the image';

  @override
  String get postSlowDownRetry => 'Slow down a moment, then try again';

  @override
  String get postSendFailed => 'Couldn\'t send';

  @override
  String get postTooltipImage => 'Image';

  @override
  String get postTooltipVoice => 'Voice recording';

  @override
  String get postVoiceRecording => 'Voice recording';

  @override
  String get postSecondsShort => 's';

  @override
  String get postReplySent => 'Sent 🌙';

  @override
  String get postLoginToReply => 'Sign in to reply';

  @override
  String get postSlowDownBeforeSend => 'Slow down a moment before sending';

  @override
  String get postRepliesTitle => 'Replies';

  @override
  String get postRepliesLoadFailed => 'Couldn\'t load replies';

  @override
  String get postRepliesEmpty =>
      'No replies yet. Be the first to start a conversation 🌙';

  @override
  String get postLoadMore => 'Load more';

  @override
  String get postAnonymous => 'Anonymous';

  @override
  String get postWithName => 'With my name';

  @override
  String get postDeleteReplyTitle => 'Delete reply';

  @override
  String get postDeleteReplyConfirmMine =>
      'Your reply will disappear. Are you sure?';

  @override
  String get postDeleteReplyConfirmOther =>
      'This reply will disappear from your post.';

  @override
  String get postDeleted => 'Deleted';

  @override
  String get postDeleteFailed => 'Couldn\'t delete';

  @override
  String get postDeleteCommentTitle => 'Delete comment';

  @override
  String get postDeleteCommentConfirm =>
      'This comment will be permanently deleted. Continue?';

  @override
  String get postPublished => 'Published';

  @override
  String get postLoginToComment => 'Sign in to comment';

  @override
  String get postPublishFailed => 'Couldn\'t publish';

  @override
  String get postCommentsTitle => 'Comments';

  @override
  String get postCommentHint => 'Write a comment…';

  @override
  String get postCommentsLoadFailed => 'Couldn\'t load comments';

  @override
  String get postCommentsEmpty => 'Be the first to comment';

  @override
  String get profileSessionIncomplete => 'Your session is incomplete';

  @override
  String get profileSessionIncompleteHint =>
      'Sign in again so everything works correctly.';

  @override
  String get profileLogoutRelogin => 'Sign out and sign in again';

  @override
  String get profileShareMine => 'Share my profile';

  @override
  String get profileThemeLight => 'Light mode';

  @override
  String get profileThemeDark => 'Dark mode';

  @override
  String get profileEmptyActiveTitle => 'No active posts';

  @override
  String get profileEmptyActiveSubtitle => 'Create a post ⚡';

  @override
  String get profileEmptyMomentsTitle => 'No moments yet';

  @override
  String get profileEmptyMomentsSubtitle => 'Share a moment from your day ⚡';

  @override
  String get profileEmptyAnswersTitle => 'No answers yet';

  @override
  String get profileEmptyAnswersSubtitle =>
      'Your replies to anonymous messages will appear here 🕶️';

  @override
  String get profileEmptyCrystalsTitle => 'No crystals yet';

  @override
  String get profileEmptyLikesTitle => 'You haven\'t liked any crystal yet';

  @override
  String get profileAvatarUpdated => 'Photo updated';

  @override
  String get profileUploadFailed => 'Upload failed';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileFieldDisplayName => 'Display name';

  @override
  String get profileFieldBio => 'Bio';

  @override
  String get profileFieldLocation => 'Location';

  @override
  String get profileFieldWebsite => 'Website';

  @override
  String get profileSaved => 'Saved';

  @override
  String get profileSaveFailed => 'Couldn\'t save';

  @override
  String get profileShareAccount => 'Share your account';

  @override
  String get profilePersona => 'My persona';

  @override
  String get profileFollowingCount => 'Following';

  @override
  String get profileAnswers => 'Answers';

  @override
  String get profileBadgeCrystals => 'Crystals';

  @override
  String get profileBadgeStreak => 'Streak';

  @override
  String get profileBadgeMirrors => 'Mirrors';

  @override
  String get profileTabActiveShort => 'Active';

  @override
  String get profileTabMoments => 'Moments';

  @override
  String get profileTabAnswers => 'Answers';

  @override
  String get profileTabCrystalsShort => 'Crystallized';

  @override
  String get profileTabLikesShort => 'Likes';

  @override
  String get profileQuickSaved => 'My saves';

  @override
  String get profileQuickPlay => 'Play & challenge';

  @override
  String get profileQuickHelp => 'Help';

  @override
  String get profileShareThis => 'Share this profile';

  @override
  String get profileBlockUser => 'Block this user';

  @override
  String get profileBlockUserBody =>
      'You won\'t receive any messages or posts from them, and they won\'t see you either. You can unblock later from settings.';

  @override
  String get profileBlocked => 'Blocked';

  @override
  String get profileBlockFailed => 'Couldn\'t block';

  @override
  String get profileReportSent => 'Report sent — we\'ll review it';

  @override
  String get profileReport => 'Report';

  @override
  String get profileNothingHere => 'Nothing here yet';

  @override
  String get profileFollowingStat => 'Following';

  @override
  String get profileActionFailed => 'Couldn\'t complete the request';

  @override
  String get profileFollowingState => 'Following';

  @override
  String get profileFollowAction => 'Follow';

  @override
  String get profileBadgeHowToGet => 'How to earn it';

  @override
  String get profileBadgeCrystalsTitle => 'Crystals ✦';

  @override
  String get profileBadgeCrystalsLead =>
      'Crystals are your posts that survived 24 hours and earned genuine engagement, turning from a fleeting moment into a lasting mark.';

  @override
  String get profileBadgeCrystalsStep1 =>
      'Post something worth discussing — a moment, an image, or an idea.';

  @override
  String get profileBadgeCrystalsStep2 =>
      'Every interaction (like, reply) increases the post\'s gravity.';

  @override
  String get profileBadgeCrystalsStep3 =>
      'Reach the crystallization threshold before the 24 hours end → it becomes a permanent ✦ saved in your crystals.';

  @override
  String get profileBadgeCrystalsStep4 =>
      'Posts without engagement quietly disappear after 24 hours (that\'s what makes a crystal valuable).';

  @override
  String get profileBadgeCrystalsTip =>
      'Crystals appear to visitors on your profile as proof of your mark. Share what lasts, not what piles up.';

  @override
  String get profileBadgeStreakTitle => 'Streak 🔥';

  @override
  String get profileBadgeStreakLead =>
      'The streak is your run of consecutive days on Sarhny. Every day you post adds a spark to your flame.';

  @override
  String get profileBadgeStreakStep1 =>
      'Open the app and post at least once every 24 hours.';

  @override
  String get profileBadgeStreakStep2 =>
      'The streak keeps your run alive for up to 48 hours as a breathing margin.';

  @override
  String get profileBadgeStreakStep3 =>
      'The longer the streak, the nobler and more prominent your glow becomes on your profile.';

  @override
  String get profileBadgeStreakStep4 =>
      'Breaking the streak resets the counter — but it doesn\'t erase the crystals you\'ve built.';

  @override
  String get profileBadgeStreakTip =>
      'The streak measures dedication, not quality. A little every day beats a lot in one day.';

  @override
  String get profileBadgeMirrorsTitle => 'Mirrors 🪞';

  @override
  String get profileBadgeMirrorsLead =>
      'A mirror is an open question you ask, letting people describe you honestly through it. Answers accumulate into a cloud that reflects how those around you see you.';

  @override
  String get profileBadgeMirrorsStep1 =>
      'Tap the “Mirrors” tab and create a reflective question (e.g. What stands out most about me?).';

  @override
  String get profileBadgeMirrorsStep2 =>
      'Share the mirror link with your friends or on your account in another app.';

  @override
  String get profileBadgeMirrorsStep3 =>
      'Answers arrive anonymously — you don\'t know who said what, so people speak frankly.';

  @override
  String get profileBadgeMirrorsStep4 =>
      'Each mirror earns you a 🪞 badge that shows on your profile and boosts your weight on Sarhny.';

  @override
  String get profileBadgeMirrorsTip =>
      'Mirrors work best with specific questions, not vague ones. Ask about what you really want to know.';

  @override
  String get profileSavedTitle => 'Saved';

  @override
  String get profileSavedEmptyTitle => 'No saved items';

  @override
  String get profileSavedEmptySubtitle =>
      'Save a post by tapping 🔖 to see it here';

  @override
  String get profileAnonLoginRequired => 'Sign in to send a message';

  @override
  String get profileAnonSent => 'Your message was delivered 🌙';

  @override
  String get profileAnonRateLimited => 'Too many attempts — wait a moment';

  @override
  String get profileAnonSendFailed => 'Couldn\'t send';

  @override
  String get profileAnonTitle => 'Ask anonymously';

  @override
  String get profileAnonSubtitle =>
      'They won\'t know who sent it — unless you reveal yourself';

  @override
  String get profileAnonHint => 'Write your question or message…';

  @override
  String get profileAnonSend => 'Send';

  @override
  String get profileLinkCopied => 'Link copied';

  @override
  String get articleAppBarTitle => 'My Persona ✨';

  @override
  String get articleGenerated => 'Your article was created ✨';

  @override
  String get articleGenerateFailed => 'Couldn\'t generate';

  @override
  String get articleCurrentLabel => 'My current article';

  @override
  String articleArchiveLabel(Object count) {
    return 'Archive · past articles ($count)';
  }

  @override
  String get articleHeaderTitle => 'Your personal article';

  @override
  String get articleHeaderBody =>
      'Your article is written from your public answers to anonymous messages. The more honestly you answer, the better the AI knows you — and the truer it writes about you.';

  @override
  String get articleNextTitle => 'Next article';

  @override
  String articleDaysRemaining(Object days) {
    return '$days days left until you can create your next article.';
  }

  @override
  String articleCooldownNote(Object days) {
    return 'Every $days days you can create a new version. The new version will be built from your latest answers.';
  }

  @override
  String get articleProgress => 'Your progress';

  @override
  String articleNeedMore(Object count) {
    return 'You need $count more public answers to anonymous messages to unlock your article. These answers are what make the article truly like you.';
  }

  @override
  String get articleGenerating => 'Generating…';

  @override
  String get articleRegenerateCta => 'Create a new version of my article';

  @override
  String get articleGenerateCta => 'Write my article now ✨';

  @override
  String get articleSaved => 'Saved';

  @override
  String get articleSaveFailed => 'Couldn\'t save';

  @override
  String get articlePublishTitle => 'Publish the article publicly';

  @override
  String get articlePublishBody =>
      '24 hours after publishing, the article becomes available to anyone via a public link on the blog. You can delete it whenever you want.';

  @override
  String get articlePublishConfirm => 'Publish';

  @override
  String get articlePublishScheduled => 'It will appear in 24 hours 🌙';

  @override
  String get articlePublishFailed => 'Couldn\'t publish';

  @override
  String get articleDeleteTitle => 'Delete article';

  @override
  String get articleDeleteBody =>
      'The current article will be deleted. Previous versions remain saved in the archive.';

  @override
  String get articleDeleted => 'Deleted';

  @override
  String get articleDeleteFailed => 'Couldn\'t delete';

  @override
  String get articleStatusPublished => 'Published';

  @override
  String get articleStatusPrivate => 'Private';

  @override
  String get articlePublishAction => 'Publish it';

  @override
  String get articleEdit => 'Edit';

  @override
  String get articleDeleteHistoryTitle => 'Delete from archive';

  @override
  String get articleDeleteHistoryBody =>
      'This version will be permanently deleted from your archive.';

  @override
  String get composeImageTooLarge => 'Image is larger than 15 MB';

  @override
  String get composeCropImage => 'Crop image';

  @override
  String get composeUploadFailed => 'Couldn\'t upload the image';

  @override
  String get composePublishedToast => 'Published with heart ✨';

  @override
  String get composePublishFailed => 'Couldn\'t publish';

  @override
  String get composeDiscardTitle => 'Discard draft?';

  @override
  String get composeDiscardBody => 'You\'ll lose what you wrote. Continue?';

  @override
  String get composeKeep => 'Keep';

  @override
  String get composeDiscard => 'Discard';

  @override
  String get composeClose => 'Close';

  @override
  String get composeNewPost => 'New post';

  @override
  String get composeWriteFromHeart => 'Write from the heart';

  @override
  String get composeLivesTitle => 'Your post lives only 24 hours';

  @override
  String get composeLivesBody =>
      'If it earns genuine engagement before it ends → it crystallizes ✦ and stays forever. Without it, it quietly fades. Share what deserves discussion.';

  @override
  String get composeLayer1Title => 'Layer 1 — Essence';

  @override
  String get composeLayer1Subtitle => 'The core idea in a few lines';

  @override
  String get composeLayer1Hint => 'What\'s on your mind?';

  @override
  String get composeLayer2Title => 'Layer 2 — Images';

  @override
  String get composeLayer2Subtitle => 'Up to 4 images (square)';

  @override
  String get composeUploading => 'Uploading…';

  @override
  String get composeAddImage => 'Add image';

  @override
  String get composeHideLayer3 => 'Hide Layer 3';

  @override
  String get composeAddLayer3 => 'Add Layer 3 — reflection';

  @override
  String get composeLayer3Title => 'Layer 3 — Reflection';

  @override
  String get composeLayer3Subtitle => 'Long text (up to 4000 characters)';

  @override
  String get composeLayer3Hint => 'Reflect with us… (optional)';

  @override
  String get composeMomentDesc =>
      'A fleeting line from your day — a quick feeling, a thought, something happening now. The shortest, the most honest.';

  @override
  String get composeFaceDesc =>
      'An image that tells your mark, with a short caption. For visual moments worth keeping.';

  @override
  String get composeMindDesc =>
      'A deeper reflection you write calmly. A place for thoughts that need time to read.';

  @override
  String get gameAiQLight => 'What makes you laugh the most these days?';

  @override
  String get gameAiQFunny =>
      'What\'s the most embarrassing thing that happened to you in public?';

  @override
  String get gameAiQBold => 'What\'s a secret you\'ve never told anyone?';

  @override
  String get helpTabFeatures => 'Features';

  @override
  String get helpTabFaq => 'FAQ';

  @override
  String get helpLegalLastUpdated => 'Last updated: November 2025';

  @override
  String get helpLegalReadFull => 'Read the full version on the website';

  @override
  String get helpLegalTermsSummary =>
      'By joining Sarhny, you agree to abide by these terms:\n\n• Age: The app is for adults (18 years and older) only. Any account found to belong to a minor will be deleted.\n\n• Content: You agree to post content that does not violate the law or incite harm, and does not contain blackmail, pornography, or hate speech.\n\n• Anonymous messages: You understand that our platform allows sending anonymous messages, and that you are responsible for your decisions to accept or report them.\n\n• Account: It is your responsibility to protect your email and password. Sarhny will never ask you for your password.\n\n• Service termination: We reserve the right to suspend any account that violates these terms without prior notice.\n\n• Applicable law: The laws of the Kingdom of Saudi Arabia govern your use of the app.\n\nTo read the full, updated version, open the link below.';

  @override
  String get helpLegalPrivacySummary =>
      'At Sarhny, your privacy is at the heart of our experience:\n\n• What we collect: email, username, the photos and texts you post, IP address upon sending (for abuse prevention only).\n\n• What we don\'t collect: we don\'t collect contacts, precise location, or browsing history outside the app.\n\n• Anonymous messages: the sender\'s identity is not shown to you or any other user. We keep an IP hash internally for 30 days for legal reporting purposes only.\n\n• Notifications: we don\'t send marketing notifications. All notifications are tied to activity within your account.\n\n• Data sharing: we don\'t sell any data to any third party. We only share:\n  - Upon an official judicial request.\n  - With infrastructure providers (server, cloud storage) to operate the service.\n\n• Your rights: you can request a copy of your data or permanently delete your account from the settings screen.\n\n• Children: the app is prohibited for those under 18. If we learn of a minor\'s account, we delete it immediately.\n\nFor the detailed legal version, open the link below.';

  @override
  String get helpLegalContentSummary =>
      'All content on Sarhny is subject to this policy:\n\n✓ Allowed: expressing opinions, honest questions, modest personal photos, art, reflective thoughts.\n\n✗ Prohibited and immediately deleted:\n• Pornographic or semi-pornographic content of any kind.\n• Hate speech against a religion, race, or gender.\n• Blackmail or threats.\n• Promoting violence, terrorism, or drugs.\n• Anything that reveals a minor\'s identity or targets minors.\n• Intrusive ads and marketing links.\n• Impersonating others.\n\nWe use machine learning algorithms + human review to detect violations. Reporting is available to all users via the \"Report\" button on any post or message.';

  @override
  String get notifTitle => 'Notifications';

  @override
  String notifAllMarkedRead(Object n) {
    return 'Marked as read ($n)';
  }

  @override
  String get notifMarkReadFailed => 'Couldn\'t update';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifEmptyTitle => 'No notifications';

  @override
  String get notifEmptySubtitle =>
      'Your alerts about everything new will appear here';

  @override
  String get notifLikedYourPost => 'liked your post';

  @override
  String get notifCommentedOnYourPost => 'commented on your post';

  @override
  String get notifStartedFollowingYou => 'started following you';

  @override
  String get notifAnonymousQuestion => 'You received an anonymous question';

  @override
  String get notifPostCrystallized => 'Your post crystallized ✦';

  @override
  String get searchHint => 'Search for a user or browse suggestions';

  @override
  String get searchEmptyBrowse => 'No users to show yet';

  @override
  String searchNoResults(Object query) {
    return 'No results match \"$query\"';
  }

  @override
  String get searchSuggestedForYou => 'Suggested for you';

  @override
  String get settingsTierPro => 'Pro';

  @override
  String get settingsTierCreator => 'Creator';

  @override
  String get settingsTierEternal => 'Eternal';

  @override
  String get settingsTierFree => 'Free';

  @override
  String get settingsPackagePrefix => 'Plan';

  @override
  String get settingsAttentionPrefix => 'Attention:';

  @override
  String get settingsManageSubscription => 'Manage subscription';

  @override
  String get settingsPlansTitle => 'Plans';

  @override
  String get settingsPlansSubtitle =>
      'Sarhny plans give you a bigger attention budget and a stronger presence.';

  @override
  String get settingsUpgraded => 'Upgraded ✨';

  @override
  String get settingsUpgradeFailed => 'Couldn\'t upgrade';

  @override
  String get settingsSubscriptionCancelled => 'Cancelled';

  @override
  String get settingsCancelFailed => 'Couldn\'t cancel';

  @override
  String get settingsDailyAttentionPrefix => 'Daily attention:';

  @override
  String get settingsCurrentPlan => 'Your current plan';

  @override
  String get settingsCancelSubscription => 'Cancel subscription';

  @override
  String get settingsUpgrade => 'Upgrade';

  @override
  String get settingsBlockedEmptyTitle => 'No blocked accounts';

  @override
  String get settingsBlockedEmptySubtitle =>
      'When you block an account, it shows up here and you can unblock it anytime.';

  @override
  String get settingsUnblocked => 'Unblocked';

  @override
  String get settingsUnblockFailed => 'Couldn\'t unblock';

  @override
  String get settingsUnblock => 'Unblock';

  @override
  String get reportReasonPostAbusive => 'Abusive content or insults';

  @override
  String get reportReasonPostHarassment => 'Harassment or bullying';

  @override
  String get reportReasonPostSexual => 'Sexual content';

  @override
  String get reportReasonPostRacism => 'Racism or incitement';

  @override
  String get reportReasonPostSpam => 'Spam or duplicate content';

  @override
  String get reportReasonPostPrivacy => 'Privacy violation';

  @override
  String get reportReasonPostMisinfo => 'Misleading information';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportReasonUserAbusive => 'Abusive or bullying account';

  @override
  String get reportReasonUserImpersonation => 'Impersonation';

  @override
  String get reportReasonUserScam => 'Scam / spam account';

  @override
  String get reportReasonUserMinors => 'Targets minors';

  @override
  String get reportReasonUserSpamMessages => 'Repeatedly sends spam messages';

  @override
  String get reportReasonUserProfile => 'Violating profile content';

  @override
  String get reportNeedClearReason => 'Write a clear reason for the report';

  @override
  String get reportReceived => 'Report received. Thank you 🌙';

  @override
  String get reportSendFailed => 'Couldn\'t send the report';

  @override
  String get reportTitlePost => 'Report post';

  @override
  String get reportTitleUser => 'Report user';

  @override
  String get reportConfidentialNote =>
      'Reports are confidential. The moderation team reviews them within 24 hours.';

  @override
  String get reportExplainBriefly => 'Briefly explain the reason';

  @override
  String get reportExtraDetails => 'Additional details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get commonComingSoon => 'Coming soon…';

  @override
  String get carromChatLoadFailed => 'Couldn\'t load messages';

  @override
  String get carromWalletBalance => 'Your current balance';

  @override
  String get carromWalletLoadFailed => 'Couldn\'t load balance';

  @override
  String get carromGotIt => 'Got it';

  @override
  String carromAimAnglePower(Object angle, Object power) {
    return 'Angle $angle° · Power $power%';
  }

  @override
  String get carromAimDragStriker => 'Drag the striker left or right';

  @override
  String get carromMmSearchFailed => 'Couldn\'t find an opponent';

  @override
  String get carromMmWaitAverage => 'Average wait under 30 seconds';

  @override
  String get carromMmWaitLongTitle => 'Taking a while?';

  @override
  String get carromMmVsComputerSoon =>
      'Match against the computer — coming soon';

  @override
  String get carromInviteCreateFailed => 'Couldn\'t create the invite';

  @override
  String get carromInvitePasteFirst => 'Paste the invite code first';

  @override
  String get carromInviteJoinFailed => 'Couldn\'t join the invite';

  @override
  String get carromInviteYourCode => 'Your invite code';

  @override
  String get carromInviteCodeHint =>
      'The code is valid for 5 minutes. Share it with your friend to join the match.';

  @override
  String get carromInviteCopied => 'Code copied';

  @override
  String get carromInviteEnterRoom => 'Enter room';

  @override
  String get carromWalletLoading => 'Loading wallet...';

  @override
  String get carromRulesTitle => 'Quick rules';

  @override
  String get carromRule1 =>
      '• Drag inward from the striker to aim — the longer the drag, the stronger the shot';

  @override
  String get carromRule2 =>
      '• White pieces = 1 point, black = 2, queen = 3 (but you must cover it)';

  @override
  String get carromRule3 =>
      '• You keep your turn if you pocket your own color, and lose it on a foul';

  @override
  String get carromRule4 =>
      '• The winner reveals to the opponent (optional) and takes all the points';

  @override
  String get carromConcedeTitle => 'Concede the match?';

  @override
  String carromConcedeBody(Object pot) {
    return 'If you concede now, your opponent wins $pot points. This can\'t be undone.';
  }

  @override
  String get carromConcedeContinue => 'Continue the match';

  @override
  String get carromGameTitle => 'Carrom';

  @override
  String carromReconnectAttempt(Object attempt) {
    return 'Reconnecting... (attempt #$attempt)';
  }

  @override
  String get carromOpponentDisconnected =>
      'Your opponent disconnected — waiting ';

  @override
  String get carromRematchStartFailed =>
      'Couldn\'t start the rematch right now';

  @override
  String get carromActionFailed => 'Couldn\'t perform the action right now';

  @override
  String get carromRevealSent =>
      'Done — if your opponent agrees, you\'ll exchange identities';

  @override
  String get carromStayedAnonymous => 'You stayed anonymous';

  @override
  String get carromRequestFailed => 'Couldn\'t send the request';

  @override
  String get carromSarhnyTitle => 'A Sarhny message to your opponent';

  @override
  String get carromSarhnySubtitle =>
      'It reaches your opponent\'s inbox tagged \"played Carrom with you\"';

  @override
  String get carromSarhnyHint => 'Write your message...';

  @override
  String get carromMessageTooShort => 'The message is too short';

  @override
  String get carromSendFailed => 'Couldn\'t send';

  @override
  String get carromMessageDelivered => 'Your message reached your opponent';

  @override
  String carromAdReward(Object credited, Object balance) {
    return '+$credited points — balance: $balance';
  }

  @override
  String get carromAdDailyCap => 'You\'ve hit the daily limit (10 ads)';

  @override
  String get carromAdUnavailable => 'Ad unavailable right now — try later';

  @override
  String get carromAdVerifyFailed => 'Couldn\'t verify the ad';

  @override
  String get carromAdUnsupported => 'Ads aren\'t supported on this platform';

  @override
  String get carromAdRewardFailed => 'Couldn\'t add the reward';

  @override
  String get carromRevealTitle => 'Reveal your identity to your opponent';

  @override
  String get carromRevealSubtitle => 'You both reveal — free';

  @override
  String get carromHideTitle => 'Hide my identity';

  @override
  String get carromHideSubtitle => 'Stay anonymous — costs 10 points';

  @override
  String get carromSendSarhnyTitle => 'Send a Sarhny message';

  @override
  String get carromSendSarhnySubtitle =>
      'To your opponent\'s inbox — with match context';

  @override
  String get carromWatchAdTitle => 'Watch an ad for +1 point';

  @override
  String get carromWatchAdSubtitle => 'Up to 10 ads per day';

  @override
  String get carromSendSarhnyShort => 'Send a Sarhny';

  @override
  String get carromSendSarhnyShortSub =>
      'Send your opponent a message — without revealing who you are';

  @override
  String get carromOpponentConceded => 'Your opponent conceded';

  @override
  String get carromOpponentConcededSub => 'The title is yours. New match?';

  @override
  String get carromYouConceded => 'You conceded this match';

  @override
  String get carromYouConcededSub =>
      'Every match is a lesson. Try again whenever you like.';

  @override
  String get carromWonSubtitle => 'You\'re the champion of this match';

  @override
  String get carromLostSubtitle => 'Every match is a new chance';

  @override
  String get carromPoints => 'points';

  @override
  String get carromBackToLobby => 'Back to lobby';

  @override
  String get carromSearchOther => 'Find another opponent';

  @override
  String carromRematchWaiting(Object seconds) {
    return 'Waiting for opponent to accept… (${seconds}s)';
  }

  @override
  String get carromRematchWaitingHint =>
      'If your opponent taps \"Rematch\", the game starts immediately';

  @override
  String get carromRematchDeclined => 'Your opponent declined the rematch';

  @override
  String get carromRematchTimeout => 'Time\'s up — opponent unavailable';

  @override
  String get carromRematchSameOpponent => 'Or rematch the same opponent';

  @override
  String get carromRematchSameOpponentAction => 'Rematch the same opponent';

  @override
  String get carromRematchAction => 'Rematch';

  @override
  String get carromWhatHappenedLabel => 'What happened in this match';

  @override
  String get carromMatchReviewSoon => 'Match review (coming soon)';

  @override
  String get carromWhatHappened => 'What happened?';

  @override
  String get carromSoon => 'Soon';

  @override
  String get carromReviewMovesSoon => 'Review your last moves (coming soon)';

  @override
  String get carromMmRaceHint => 'Whoever arrives first starts playing';

  @override
  String get carromCosmeticsTitle2 => 'Carrom skins';

  @override
  String get carromCosmeticsBoard => 'Board';

  @override
  String get carromCosmeticsPieces => 'Pieces';

  @override
  String get carromCosmeticsSound => 'Sound';

  @override
  String get carromCosmeticsMute => 'Mute game sounds';

  @override
  String get carromBoardWalnut => 'Fine wood';

  @override
  String get carromBoardSapphire => 'Royal blue';

  @override
  String get carromBoardEmerald => 'Emerald green';

  @override
  String get carromCoinClassic => 'Classic';

  @override
  String get carromCoinRoyal => 'Royal gold';

  @override
  String get carromCoinVivid => 'Vivid';

  @override
  String get carromCoinCandy => 'Candy';

  @override
  String get carromChatNiceGame => 'Nice game';

  @override
  String get carromChatFireShot => 'Fire shot';

  @override
  String get carromChatPreciseAim => 'Precise aim';

  @override
  String get carromChatWatchLearn => 'Watch and learn';

  @override
  String get carromChatMyLuck => 'Just my luck';

  @override
  String get carromChatBravo => 'Bravo';

  @override
  String get carromChatWow => 'Wow!';

  @override
  String get carromChatGoodLuck => 'Good luck';

  @override
  String get carromChatEasy => 'Easy';

  @override
  String get carromChatMadeItHard => 'You made it hard';

  @override
  String get carromChatCovered => 'Covered it!';

  @override
  String get carromChatBeautifulGame => 'Beautiful game';

  @override
  String get carromMatchWonMatch => 'You won the match 🏆';

  @override
  String get carromMatchOppWon => 'Opponent won';

  @override
  String get carromMatchOppAiming => 'Opponent is aiming…';

  @override
  String get carromMatchPiecesMoving => 'Pieces are moving…';

  @override
  String get carromMatchOppCoversQueen => 'Opponent is covering the queen 👑';

  @override
  String get carromMatchCoverQueen =>
      'Cover the queen 👑 — pocket one of your pieces';

  @override
  String get carromMatchYourTurnHint =>
      'Your turn — drag the striker back to aim, then release';

  @override
  String get carromMatchTitle => 'Carrom';

  @override
  String get carromOnlineTitle => 'Carrom Online';

  @override
  String get carromUnmute => 'Unmute';

  @override
  String get carromMute => 'Mute';

  @override
  String get carromSkins => 'Skins';

  @override
  String get carromYou => 'You';

  @override
  String get carromOpponent => 'Opponent';

  @override
  String get carromFoulStriker => 'Foul: the striker went into the pocket';

  @override
  String get carromFoulNoHit => 'Foul: you didn\'t touch any piece';

  @override
  String get carromFoulTimeout => 'Your time is up — pass to the opponent';

  @override
  String get carromFoulTimeoutOnline => 'Player\'s time is up — pass';

  @override
  String get carromFoul => 'Foul';

  @override
  String get carromQaWinAsk => 'You won! Ask your opponent a question';

  @override
  String get carromQaLoseAnswer => 'Opponent won — answer their question';

  @override
  String get carromQaQuestionHint => 'Write your question for the opponent…';

  @override
  String get carromQaAnswerHint => 'Write your answer…';

  @override
  String get carromQaFetchingQuestion => 'Fetching the question…';

  @override
  String get carromQaPrivate => 'Private — not saved';

  @override
  String get carromQaWaitingAnswer => 'Waiting for the opponent\'s answer…';

  @override
  String get carromQaWaitingQuestion => 'Waiting for the opponent\'s question…';

  @override
  String get carromQaAnswerSent => 'Your answer was sent ✓';

  @override
  String get carromBubbleOppAnswer => 'Opponent\'s answer';

  @override
  String get carromBubbleOppQuestion => 'Opponent\'s question';

  @override
  String get carromSkip => 'Skip';

  @override
  String get carromFinish => 'Finish';

  @override
  String get carromSendQuestion => 'Send question';

  @override
  String get carromSendAnswer => 'Send answer';

  @override
  String get carromYouWon => 'You won!';

  @override
  String get carromNewMatch => 'New match';

  @override
  String get carromNewOpponent => 'New opponent';

  @override
  String get carromOppLeft => 'Opponent left';

  @override
  String get carromConnected => 'Connected';

  @override
  String get carromConnecting => 'Connecting…';

  @override
  String get carromAimMoveStriker => 'Slide the striker left and right';

  @override
  String get carromAimDragToAim => 'Drag the striker to aim';

  @override
  String get carromMmAvgWait => 'Average wait under 30 seconds';

  @override
  String get carromOnlineWon => 'You won! 🏆';

  @override
  String get carromOnlineLost => 'You lost';

  @override
  String get carromScoreYou => 'You';

  @override
  String get carromScoreOpp => 'Opp';

  @override
  String get carromOpponentLeft =>
      'Your opponent left — waiting for them to return';

  @override
  String get carromConcedeAction => 'Concede';

  @override
  String get carromMatchOver => 'Match over';

  @override
  String get carromTurnYouAim => 'Your turn — aim';

  @override
  String get carromTurnWaitOpp => 'Waiting for your opponent…';

  @override
  String get carromExitTitle => 'Leave the match?';

  @override
  String get carromExitBody => 'The current round will count as a loss.';

  @override
  String get carromExitAction => 'Exit';

  @override
  String get carromTitleShort => 'Carrom';

  @override
  String get carromPiecesMoving => 'Pieces are moving…';

  @override
  String get carromStatusDragHint =>
      'Drag from the striker to set power and angle';

  @override
  String get carromNewPractice => 'New practice';

  @override
  String get carromFoulStrikerPocketed =>
      'Foul: the striker fell in the pocket';

  @override
  String get carromFoulNoPieceHit => 'Foul: you didn\'t hit a piece';

  @override
  String get carromFoulWrongColor =>
      'Foul: you hit the opponent\'s piece first';

  @override
  String get carromFoulQueenUncovered => 'Foul: the queen wasn\'t covered';

  @override
  String get carromFoulGeneric => 'Foul on the shot';

  @override
  String get carromChatToughOne => 'You made it tough';

  @override
  String get carromChatNicePlay => 'Nice play';

  @override
  String get carromConcedeProTitle => 'Withdraw from the match?';

  @override
  String get carromConcedeProBody => 'It will count as a loss.';

  @override
  String get carromWithdraw => 'Withdraw';

  @override
  String get carromProTitle => 'Carrom Pro';

  @override
  String get carromChat => 'Chat';

  @override
  String get carromStatusWonMatch => 'You won the match 🏆';

  @override
  String get carromStatusOppWon => 'Opponent won';

  @override
  String get carromStatusOppAiming => 'Opponent is aiming…';

  @override
  String get carromStatusOppCoverQueen => 'Opponent is covering the queen 👑';

  @override
  String get carromStatusCoverQueen =>
      'Cover the queen 👑 — pocket one of your pieces';

  @override
  String get carromStatusYourTurnDrag =>
      'Your turn — drag the striker, aim, then release';

  @override
  String get carromFoulStrikerPocketed2 =>
      'Foul: the striker went in the pocket';

  @override
  String get carromFoulNoPieceHit2 => 'Foul: you didn\'t touch any piece';

  @override
  String get ludoInviteCreateFailed => 'Couldn\'t create the invite';

  @override
  String get ludoInvitePasteFirst => 'Paste the invite code first';

  @override
  String get ludoInviteJoinFailed => 'Couldn\'t join the invite';

  @override
  String get ludoInviteCodeTitle => 'Your invite code';

  @override
  String get ludoInviteCodeHint =>
      'The code is valid for 5 minutes. Share it so others can join the match.';

  @override
  String get ludoCodeCopied => 'Code copied';

  @override
  String get ludoCopy => 'Copy';

  @override
  String get ludoEnterRoom => 'Enter room';

  @override
  String get ludoBadgeNew => 'New';

  @override
  String get ludoBadge2to4 => '2-4 players';

  @override
  String get ludoHeroTitle => 'Golden Ludo';

  @override
  String get ludoHeroSubtitle => 'The dice decide, courage wins';

  @override
  String get ludoChooseMode => 'Choose a mode';

  @override
  String get ludoMoment => 'One moment…';

  @override
  String get ludoStartMatch => 'Start a match';

  @override
  String get ludoPlayWithFriends => 'Play with friends';

  @override
  String get ludoJoinByInvite => 'Join by invite';

  @override
  String get ludoPasteCode => 'Paste the code';

  @override
  String get ludoJoin => 'Join';

  @override
  String ludoEntryWinner(Object fee, Object pot) {
    return 'Entry $fee — winner takes $pot';
  }

  @override
  String ludoCurrentBalance(Object points) {
    return 'Your balance: $points points';
  }

  @override
  String get ludoCount2Players => '2 players';

  @override
  String get ludoCount4Players => '4 players';

  @override
  String get ludoMmSearchFailed => 'Couldn\'t find opponents';

  @override
  String get ludoMmSearch3 => 'Searching for 3 opponents…';

  @override
  String get ludoMmSearch1 => 'Searching for an opponent…';

  @override
  String ludoMmQueuePos(Object pos) {
    return 'Your queue position: $pos';
  }

  @override
  String get ludoMmAvgWait => 'Average wait under 45 seconds';

  @override
  String get ludoConcedeTitle => 'Concede?';

  @override
  String get ludoConcedeBody =>
      'If you quit now, you forfeit your entry to the pot and take last place.';

  @override
  String get ludoConcedeBack => 'Go back';

  @override
  String get ludoConcede => 'Concede';

  @override
  String ludoErrorPrefixed(Object error) {
    return 'Error: $error';
  }

  @override
  String get ludoReconnecting => 'Reconnecting…';

  @override
  String get ludoMoving => 'Moving…';

  @override
  String get ludoMovableHighlighted => 'Movable pieces are glowing green';

  @override
  String get ludoDiceHint => 'The dice drive your steps forward';

  @override
  String get ludoColorRed => 'Red';

  @override
  String get ludoColorGreen => 'Green';

  @override
  String get ludoColorYellow => 'Yellow';

  @override
  String get ludoOpponent => 'Opponent';

  @override
  String get ludoWinTitle => 'Crushing win!';

  @override
  String get ludoNiceMatch => 'Nice match';

  @override
  String ludoWonPoints(Object pot) {
    return 'You won $pot points';
  }

  @override
  String ludoWinnerTakesPoints(Object pot) {
    return 'Winner takes $pot points';
  }

  @override
  String get ludoBackToLobby => 'Back to lobby';

  @override
  String get ludoNewMatch => 'New match';

  @override
  String get ludoArena => 'Arena';

  @override
  String get ludoRank1 => 'First';

  @override
  String get ludoRank2 => 'Second';

  @override
  String get ludoRank3 => 'Third';

  @override
  String get ludoRank4 => 'Fourth';

  @override
  String ludoRankYou(Object rank) {
    return '$rank · You';
  }

  @override
  String get ludoWaiting => 'Waiting…';

  @override
  String get ludoChatLoadFailed => 'Couldn\'t load messages';

  @override
  String get ludoVariantMagic => 'Magic Ludo';

  @override
  String get ludoVariantNormal => 'Classic Ludo';

  @override
  String get ludoPlayersSuffix => 'players';

  @override
  String get ludoPlayerLabel => 'Player';

  @override
  String get ludoTurnNow => 'Their turn';

  @override
  String get ludoFrozenShort => 'Frozen';

  @override
  String get ludoMatchOverTitle => 'Leave the match?';

  @override
  String get ludoContinue => 'Continue';

  @override
  String get ludoLeave => 'Leave';

  @override
  String get ludoMatchEnded => 'Match over';

  @override
  String get ludoTapDiceToRoll => 'Tap the dice to roll';

  @override
  String get ludoTapDiceFrozen => 'Tap the dice to spend a roll';

  @override
  String get ludoPowerRocket => 'Rocket';

  @override
  String get ludoPowerFreeze => 'Freeze';

  @override
  String get ludoPowerDoor => 'Door';

  @override
  String get ludoPowerDoors => 'Doors';

  @override
  String get ludoPowerGate => 'Gate';

  @override
  String get ludoPowerTornado => 'Tornado';

  @override
  String get ludoRocketRange => '+1 to +6';

  @override
  String get ludoFreezeThreeRolls => '3 rolls';

  @override
  String get ludoTeleport => 'Teleport';

  @override
  String get ludoRandom => 'Random';

  @override
  String get ludoEventFreezeEndedFor => 'Freeze ended for';

  @override
  String get ludoEventFrozenRemaining => 'frozen — remaining';

  @override
  String get ludoEventRocketReachedHome => 'got you home';

  @override
  String get ludoEventRocketSteps => 'pushed you';

  @override
  String get ludoEventRocketStepsSuffix => 'steps';

  @override
  String get ludoEventFreezeFor => 'Freeze';

  @override
  String get ludoEventFreezeForThreeRolls => 'for 3 rolls';

  @override
  String get ludoEventDoorForward => 'You went through the door and forward';

  @override
  String get ludoEventDoorBack => 'The door sent you back';

  @override
  String get ludoEventTornadoMoved =>
      'The tornado moved the pawn to an unexpected spot';

  @override
  String get codexLudoTitle => 'Codex Ludo';

  @override
  String get codexCarromTitle => 'Codex Carrom';

  @override
  String get codexLudoIntro => 'Codex Ludo: tap the dice and watch the powers';

  @override
  String get codexRolled => 'rolled';

  @override
  String get codexRocketSteps => 'Codex rocket: +';

  @override
  String get codexStepsSuffix => 'steps';

  @override
  String get codexFreezePlayer => 'Freeze player';

  @override
  String get codexForThreeRolls => 'for three rolls';

  @override
  String get codexGateMovedTo => 'Codex gate moved you to square';

  @override
  String get codexCycloneNewSpot => 'Cyclone: an unexpected new spot';

  @override
  String get codexReachedFinish => 'reached the finish';

  @override
  String get codexSixPlayAgain => 'Six: player';

  @override
  String get codexPlaysAgain => 'plays again';

  @override
  String get codexFrozenShort => 'frozen';

  @override
  String get codexFrozenRemaining => 'remaining';

  @override
  String get codexIceShort => 'Ice';

  @override
  String get codexRollShort => 'Roll';

  @override
  String get codexCarromIntro2 => 'Codex Carrom: drag and shoot';

  @override
  String get codexHitSuccess => 'Nice shot: +1';

  @override
  String get codexMissPocket => 'The coin didn\'t drop, adjust your angle';

  @override
  String get codexMissCoin => 'You didn\'t touch a coin';

  @override
  String get codexBoardCleared => 'You cleared the board with';

  @override
  String get codexResetTable => 'Reset table';

  @override
  String get carromCosmeticsLoadFailed => 'Couldn\'t load the designs';

  @override
  String get carromConcedeBodyPlain =>
      'If you concede now, your opponent wins. This can\'t be undone.';

  @override
  String get hubCarromTitle => 'Carrom Pro';

  @override
  String get hubCarromSubtitle =>
      'Realistic physics & a smart rival — aim, strike, pocket';

  @override
  String get hubCarromTag => 'Pro ✦';

  @override
  String get hubChooseMode => 'Choose game mode';

  @override
  String get hubModeAi => 'vs Computer';

  @override
  String get hubModeAiSub => 'Play now on your device against a smart opponent';

  @override
  String get hubModeOnline => 'Online';

  @override
  String get hubModeOnlineSub => 'Challenge a real player — winner asks';

  @override
  String get navGames => 'Play';
}
