// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Sarhny';

  @override
  String get tagline => '진정한 자기 표현';

  @override
  String get splashLoading => '불러오는 중...';

  @override
  String get loginTitle => '다시 오신 것을 환영합니다';

  @override
  String get loginEmailOrUsername => '사용자 이름 또는 이메일';

  @override
  String get loginPassword => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get loginForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginNoAccount => '계정이 없나요?';

  @override
  String get loginSignUp => '가입하기';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get registerName => '이름';

  @override
  String get registerUsername => '사용자 이름';

  @override
  String get registerEmail => '이메일';

  @override
  String get registerPassword => '비밀번호';

  @override
  String get registerButton => '계정 만들기';

  @override
  String get registerHasAccount => '이미 계정이 있나요?';

  @override
  String get registerSignIn => '로그인';

  @override
  String get navHome => '홈';

  @override
  String get navInbox => '받은편지';

  @override
  String get navCompose => '게시';

  @override
  String get navMirrors => '거울';

  @override
  String get navProfile => '프로필';

  @override
  String get feedGlobalTab => '전체';

  @override
  String get feedFollowingTab => '팔로잉';

  @override
  String get feedSectionAll => '모두';

  @override
  String get feedSectionMoment => '순간';

  @override
  String get feedSectionFace => '얼굴';

  @override
  String get feedSectionMind => '생각';

  @override
  String get postCrystalBadge => '결정';

  @override
  String get postLayersHint => '읽기';

  @override
  String get postGravityApproaching => '결정에 가까워짐';

  @override
  String get postGravityFading => '사라지는 중';

  @override
  String get composeChooseSection => '섹션을 선택하세요';

  @override
  String get composeMoment => '순간';

  @override
  String get composeFace => '얼굴';

  @override
  String get composeMind => '생각';

  @override
  String get composeLayer1 => '본문';

  @override
  String get composeLayer2 => '이미지 추가 (선택)';

  @override
  String get composeLayer3 => '더 깊은 글 쓰기 (선택)';

  @override
  String get composeCrystallizeHint => '24시간 수명으로 시작 — 반응이 있으면 결정화됨';

  @override
  String get composePublish => '게시';

  @override
  String get profileEdit => '편집';

  @override
  String get profileFollow => '팔로우';

  @override
  String get profileFollowing => '팔로잉';

  @override
  String get profileBlock => '차단';

  @override
  String get profileFollowers => '팔로워';

  @override
  String get profileCrystals => '결정';

  @override
  String get profileReplies => '답글';

  @override
  String get profileTabCrystals => '결정';

  @override
  String get profileTabActive => '활성';

  @override
  String get profileTabMirrors => '거울';

  @override
  String get profileTabLikes => '좋아요';

  @override
  String get inboxTitle => '익명 메시지';

  @override
  String get inboxEmpty => '아직 메시지가 없습니다';

  @override
  String get inboxReplyPublic => '공개 답변';

  @override
  String get inboxIgnore => '무시';

  @override
  String get inboxReport => '신고';

  @override
  String get inboxDelete => '삭제';

  @override
  String get mirrorsTitle => '거울';

  @override
  String get mirrorsCreate => '새 거울 만들기';

  @override
  String get mirrorsShare => '링크 공유';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAccount => '계정';

  @override
  String get settingsPrivacy => '개인정보';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsAnonymous => '익명 메시지';

  @override
  String get settingsSubscription => '구독';

  @override
  String get settingsHelp => '도움말';

  @override
  String get settingsLogout => '로그아웃';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get themeSystem => '시스템';

  @override
  String get commonRetry => '재시도';

  @override
  String get commonSave => '저장';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫기';

  @override
  String get commonShare => '공유';

  @override
  String get commonReport => '신고';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonError => '문제가 발생했습니다';

  @override
  String get commonLoading => '불러오는 중...';

  @override
  String get commonEmpty => '내용 없음';

  @override
  String get gamesHubTitle => '게임';

  @override
  String get carromTitle => 'Carrom 1v1';

  @override
  String get carromSubtitle => '익명 상대에게 도전 — 그들의 점수를 획득';

  @override
  String get carromLobbyPlayRandom => '랜덤 매치 시작';

  @override
  String get carromLobbyPlayRandomSub => '지금 가능한 상대 찾기';

  @override
  String get carromLobbyInvite => '친구와 플레이';

  @override
  String get carromLobbyInviteSub => '공유할 초대 코드 생성';

  @override
  String get carromLobbyJoinByCode => '코드로 참여';

  @override
  String get carromLobbyJoinHint => '코드를 붙여넣으세요';

  @override
  String get carromLobbyJoinAction => '참여';

  @override
  String carromLobbyEntryFee(Object entry, Object pot) {
    return '참가 $entry — 승자 $pot 획득';
  }

  @override
  String get carromMmSearching => '상대 찾는 중...';

  @override
  String get carromMmCancel => '검색 취소';

  @override
  String carromMmQueue(Object pos) {
    return '대기열 위치: $pos';
  }

  @override
  String get carromMatchYourTurn => '당신 차례';

  @override
  String get carromMatchOppTurn => '상대 차례';

  @override
  String get carromMatchConcede => '기권';

  @override
  String get carromMatchConcedeConfirm => '지금 기권하면 상대가 모든 점수를 가져갑니다.';

  @override
  String get carromMatchReconnect => '서버에 다시 연결 중...';

  @override
  String get carromOpponentUnknown => '익명 상대';

  @override
  String get carromOpponentTurnNow => '상대 차례';

  @override
  String get carromOpponentWaiting => '차례 대기 중';

  @override
  String get carromAimHint => '조준하려면 스트라이커를 안쪽으로 드래그하세요';

  @override
  String get carromGameOverWon => '승리!';

  @override
  String get carromGameOverLost => '다음 기회에';

  @override
  String get carromGameOverReveal => '신원 공개';

  @override
  String get carromGameOverHide => '익명 유지';

  @override
  String get carromGameOverSarhny => 'Sarhny 메시지 보내기';

  @override
  String get carromGameOverRematch => '재대결';

  @override
  String get carromGameOverLobby => '로비';

  @override
  String get carromWalletEarn1 => '받은 Sarhny 메시지 하나당';

  @override
  String get carromWalletEarn2 => '짧은 광고 시청';

  @override
  String get carromWalletEarn3 => 'Carrom 매치 승리';

  @override
  String get carromCosmeticsTitle => '게임 커스터마이즈';

  @override
  String get carromCosmeticsTabBoard => '보드';

  @override
  String get carromCosmeticsTabPieces => '말';

  @override
  String get carromCosmeticsTabStriker => '스트라이커';

  @override
  String get carromCosmeticsLockedHint => '이 스킨을 잠금 해제하려면 포인트를 획득하세요';

  @override
  String carromCosmeticsSaved(Object name) {
    return '$name 선택됨';
  }

  @override
  String get carromCosmeticsSaveFailed => '저장할 수 없습니다, 다시 시도하세요';

  @override
  String get carromLobbyCustomize => '게임 커스터마이즈';

  @override
  String get carromLobbyCustomizeSub => '보드, 말 색상, 스트라이커를 선택하세요';

  @override
  String get actionPlay => '플레이';

  @override
  String get actionPlayAgain => '다시 플레이';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionConfirm => '확인';

  @override
  String get actionSend => '보내기';

  @override
  String get actionSkip => '건너뛰기';

  @override
  String get actionLockIn => '확정';

  @override
  String get actionDiscard => '버리기';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionLeave => '나가기';

  @override
  String get actionLeaveLobby => '로비로 돌아가기';

  @override
  String get actionJoin => '참여';

  @override
  String get actionCopy => '복사';

  @override
  String get actionPaste => '붙여넣기';

  @override
  String get actionDone => '완료';

  @override
  String get labelLobby => '로비';

  @override
  String get labelGamesHome => '아레나';

  @override
  String get labelOpponent => '상대';

  @override
  String get labelYou => '당신';

  @override
  String get labelMe => '나';

  @override
  String get labelAi => 'AI';

  @override
  String get labelVs => 'VS';

  @override
  String get labelTurnYours => '당신 차례';

  @override
  String get labelTurnTheirs => '상대 차례';

  @override
  String get labelTurnAi => 'AI가 생각 중…';

  @override
  String labelRound(Object n) {
    return '$n 라운드';
  }

  @override
  String get labelWaiting => '대기 중…';

  @override
  String get labelWaitingOpponent => '상대를 기다리는 중…';

  @override
  String get labelSearching => '상대를 찾는 중…';

  @override
  String get outcomeYouWon => '이겼습니다!';

  @override
  String get outcomeYouLost => '졌습니다';

  @override
  String get outcomeDraw => '무승부';

  @override
  String get outcomeAiWins => 'AI 승리';

  @override
  String get moodLight => '가벼움';

  @override
  String get moodBold => '대담함';

  @override
  String get moodFunny => '재미';

  @override
  String get moodChoose => '게임 분위기 선택';

  @override
  String get lobbyVsRandom => '랜덤 상대';

  @override
  String get lobbyVsAi => 'AI와 대전';

  @override
  String get lobbyVsAiSub => '즉시 연습 — AI가 이기면 질문합니다';

  @override
  String get lobbyInviteFriend => '친구와 플레이';

  @override
  String get lobbyInviteFriendSub => '공유할 초대 코드 생성';

  @override
  String get lobbyJoinByCode => '코드로 참여';

  @override
  String get lobbyPasteCode => '코드 붙여넣기';

  @override
  String get questionAsk => '질문하세요';

  @override
  String get questionAnswer => '솔직히 답하세요';

  @override
  String get questionWaitingQ => '상대의 질문을 기다리는 중…';

  @override
  String get questionWaitingA => '상대의 답을 기다리는 중…';

  @override
  String get questionSkipNew => '다른 질문';

  @override
  String get questionAbstainAd => '기권 · 광고 보기 (+1 포인트)';

  @override
  String get questionAbstainNote => '기권하면 답변 없이 매치가 끝나고 포인트가 추가됩니다.';

  @override
  String get adLoading => '광고 로딩 중…';

  @override
  String get adIncomplete => '광고가 완료되지 않음';

  @override
  String get adUnavailable => '이용 가능한 광고 없음';

  @override
  String get adDailyCap => '일일 광고 한도 도달';

  @override
  String get adRewardEarned => '포인트를 받았습니다.';

  @override
  String get rpsRock => '바위';

  @override
  String get rpsPaper => '보';

  @override
  String get rpsScissors => '가위';

  @override
  String get rpsChooseHand => '손을 선택하세요';

  @override
  String get rpsGuessHand => '상대의 손을 추측';

  @override
  String get rpsAiQuestionLabel => 'AI의 질문';

  @override
  String get rpsMyQuestionLabel => 'AI에게 할 질문';

  @override
  String get rpsAnswerPrivate => '답변은 당신만의 것 — 저장되거나 전송되지 않습니다.';

  @override
  String get xoCellFilled => '이미 차지된 칸 — 다른 칸 선택';

  @override
  String get xoNotYourTurn => '아직 당신 차례가 아닙니다';

  @override
  String get xoPracticeTitle => 'XO — 연습';

  @override
  String get leaveTitle => '매치 나가기?';

  @override
  String get leaveBody => '이번 라운드는 패배로 처리됩니다.';

  @override
  String get rematchTitle => '다시 대결할까요?';

  @override
  String get rematchAccept => '다시 플레이';

  @override
  String get rematchDecline => '그만';

  @override
  String get rematchWaiting => '상대 응답 대기…';

  @override
  String get rematchDeclined => '상대가 재대결을 거절했습니다';

  @override
  String get rematchTimeout => '재대결 시간 종료';

  @override
  String get hubGameRps => '결투';

  @override
  String get hubGameRpsSub => '가위·바위·보 — 승자가 질문합니다';

  @override
  String get hubGameXo => '틱택토';

  @override
  String get hubGameXoSub => '삼목 — 승자가 질문합니다';

  @override
  String get hubAdEarnTitle => '짧은 광고 보기';

  @override
  String get hubAdEarnSub => '일일 한도 10 — 포인트가 즉시 지갑에 들어갑니다.';

  @override
  String get hubAdPointBadge => '+1 포인트';

  @override
  String get hubTagAdNew => '신규';

  @override
  String get hubTagOnline => '온라인';

  @override
  String get hubSectionPlay => '지금 플레이';

  @override
  String get hubSectionEarn => '안 해도 포인트 획득';

  @override
  String get hubAbstainHint => '게임 중에도 광고를 보고 답변을 기권할 수 있습니다.';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageAuto => '자동 (기기 언어)';

  @override
  String get settingsEmail => '이메일';

  @override
  String get settingsChangePassword => '비밀번호 변경';

  @override
  String get settingsAnonymousReceive => '익명 메시지 받기';

  @override
  String get settingsVoiceReceive => '음성 메시지 받기';

  @override
  String get settingsImageReceive => '이미지 받기';

  @override
  String get settingsRegisteredOnly => '가입한 사용자만';

  @override
  String get settingsBlockedAccounts => '차단된 계정';

  @override
  String get settingsLikes => '좋아요';

  @override
  String get settingsComments => '댓글';

  @override
  String get settingsFollowers => '새 팔로워';

  @override
  String get settingsAppearance => '테마';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsHelpCenter => '도움말 센터';

  @override
  String get settingsTerms => '이용 약관';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsContentPolicy => '콘텐츠 정책';

  @override
  String get settingsDangerZone => '위험 영역';

  @override
  String get settingsDeleteAccount => '계정 삭제';

  @override
  String get settingsUpdated => '업데이트되었습니다';

  @override
  String get settingsUpdateFailed => '업데이트할 수 없습니다';

  @override
  String get settingsPasswordShort => '새 비밀번호가 너무 짧습니다';

  @override
  String get settingsPasswordCurrent => '현재 비밀번호';

  @override
  String get settingsPasswordNew => '새 비밀번호';

  @override
  String get settingsDeleteConfirmTitle => '계정 영구 삭제';

  @override
  String get settingsDeleteConfirmBody => '이 작업은 취소할 수 없습니다 — 모든 데이터가 삭제됩니다.';

  @override
  String get settingsDeleteConfirmField => '비밀번호를 확인하세요';

  @override
  String get settingsDeleteAction => '삭제';

  @override
  String get settingsDeleteFailed => '삭제할 수 없습니다';

  @override
  String get settingsThemeAuto => '자동';

  @override
  String get errorGeneric => '문제가 발생했습니다';

  @override
  String get errorMatchLoad => '매치를 불러올 수 없습니다';

  @override
  String get errorGameStart => '게임을 시작할 수 없습니다';

  @override
  String get errorAdLaunch => '광고를 재생할 수 없습니다';

  @override
  String get errorClipboardCopied => '복사됨';

  @override
  String get roundWon => '이번 라운드에서 이겼습니다';

  @override
  String get roundLost => '상대가 이번 라운드에서 이겼습니다';

  @override
  String get roundDraw => '이번 라운드 승자 없음';

  @override
  String get gameOverTitle => '게임 종료';

  @override
  String get revealingSoon => '공개 중…';

  @override
  String get nextRoundSoon => '다음 라운드 시작…';

  @override
  String get leaveStay => '남기';

  @override
  String get answerWriteHint => '솔직하게 답을 적어주세요';

  @override
  String get questionWriteHint => '솔직하게 질문을 적어주세요';

  @override
  String get continueMatch => '계속하기';

  @override
  String get xoPageTitle => '틱택토 챌린지';

  @override
  String xoMovesProgress(Object moves, Object total) {
    return '$moves/$total 수';
  }

  @override
  String get questionUsePresetCta => '또는 준비된 질문 사용';

  @override
  String get questionSkipUsed => '교체 사용됨';

  @override
  String questionYoursPrefix(Object q) {
    return '당신의 질문: $q';
  }

  @override
  String get xoLocalDrawSub => '막상막하의 경기.';

  @override
  String get xoLocalWinSub => '한 줄로 세 개 — 멋져요.';

  @override
  String get xoLocalLoseSub => '다시 시도해 보세요.';

  @override
  String get lobbyStartMatchSection => '경기 시작';

  @override
  String get lobbyVsRandomSub => '온라인 상대를 찾아보세요';

  @override
  String get xoLobbyHeroDescription =>
      '상대보다 먼저 한 줄로 세 개를 만드세요.\n승자는 질문하고, 패자는 답합니다.';

  @override
  String get gamePageTitle => '챌린지 🎮';

  @override
  String get gameLobbyRandomSub => '5라운드 가위바위보 + 예측 • 먼저 5점에 도달하면 승리';

  @override
  String get gameRulesTitle => '간단한 규칙';

  @override
  String get gameRule1 => '한 손을 선택하고 상대의 선택을 예측하세요';

  @override
  String get gameRule2 => '라운드 승리 = 1점. 예측 적중 = 1점';

  @override
  String get gameRule3 => '먼저 5점에 도달하면 승리';

  @override
  String get gameRule4 => '승자는 패자에게 질문을 작성합니다 (25초)';

  @override
  String get gameRule5 => '모욕적인 답변이나 질문 → 라운드 무효';

  @override
  String get gameUnusualEndSub => '라운드가 예기치 않게 종료되었습니다.';

  @override
  String get gameAnonymityTagline => '당신의 정체를 밝히지 마세요. 상대의 정체도요.';

  @override
  String secondsRemaining(Object n) {
    return '$n초 남음';
  }

  @override
  String secondsToAnswer(Object n) {
    return '답변까지 $n초';
  }

  @override
  String secondsShort(Object n) {
    return '$n초';
  }

  @override
  String get questionAutoFallbackPrefix => '쓰지 않으면 자동 질문:';

  @override
  String get questionFromOpponent => '상대로부터의 질문';

  @override
  String get questionAppearingSoon => '질문이 곧 나타납니다. 잠시만 기다려주세요.';

  @override
  String get questionSent => '질문 전송됨 — 잠시 후 답변이 도착합니다.';

  @override
  String get rpsPracticeTitle => '챌린지 — 연습';

  @override
  String get rpsLocalAskHint => '솔직한 질문을 해보세요... (재미로만)';

  @override
  String get rpsLocalAiPreparing => '질문을 준비 중입니다...';

  @override
  String get rpsLocalAnswerHint => '스스로 답해보세요...';

  @override
  String get ludoPowerTitle => '파워 루도';

  @override
  String get ludoPowerSubtitle =>
      '초능력을 가진 4인 루도 — 로켓, 빙결, 포털, 토네이도. 능력은 3번 굴릴 때마다 재배치됩니다.';

  @override
  String get ludoLobbyChooseMode => '모드 선택';

  @override
  String get ludoMode2Players => '2인 (1대1)';

  @override
  String get ludoMode2PlayersSub => '당신 vs 봇 — 더 빠르고 강렬하게';

  @override
  String get ludoMode4Players => '4인';

  @override
  String get ludoMode4PlayersSub => '당신 vs 봇 3명 — 완전한 경험';

  @override
  String get ludoStartTap => '주사위를 탭하여 시작';

  @override
  String get ludoTapPawn => '이동할 말을 선택하세요';

  @override
  String get ludoExtraTurn => '추가 턴! 다시 굴리세요';

  @override
  String get ludoYourTurn => 'Your turn';

  @override
  String ludoBotTurn(Object name) {
    return '$name 플레이 중…';
  }

  @override
  String get ludoRollDice => 'Roll dice';

  @override
  String ludoTurnLabel(Object name) {
    return '$name 차례';
  }

  @override
  String get ludoYouWin => '🎉 승리!';

  @override
  String ludoBotWin(Object name) {
    return '$name 승리';
  }

  @override
  String get ludoYouWinSub => '네 개의 말이 모두 중앙에 도착했습니다';

  @override
  String get ludoLossSub => '다음 라운드에 행운을';

  @override
  String get ludoNewGame => 'New game';

  @override
  String get ludoNoMove => 'No move';

  @override
  String get ludoPlayerGold => '골드';

  @override
  String get ludoPlayerBlue => '블루';

  @override
  String get ludoPlayerPurple => '퍼플';

  @override
  String get ludoPlayerGreen => '그린';

  @override
  String ludoEventRocket(Object boost) {
    return '로켓! +$boost';
  }

  @override
  String get ludoEventFreeze => '빙결!';

  @override
  String ludoEventPortalForward(Object diff) {
    return '포털! +$diff';
  }

  @override
  String ludoEventPortalBack(Object diff) {
    return '포털! -$diff';
  }

  @override
  String get ludoEventTornado => '토네이도!';

  @override
  String get ludoEventCapture => '포획!';

  @override
  String get ludoEventShuffle => '능력 재배치됨';

  @override
  String get hubGameLudoPower => '파워 루도';

  @override
  String get hubGameLudoPowerSub => '초능력을 가진 4인 루도 — 추천';

  @override
  String get hubTagFeatured => '추천';

  @override
  String get ludoPlayerYou => '나';

  @override
  String ludoOpponentN(Object n) {
    return '상대 $n';
  }

  @override
  String get ludoBotThinking => '생각 중…';

  @override
  String get ludoMmTitle => '상대 찾는 중';

  @override
  String get ludoMmSearching => '플레이어 검색 중…';

  @override
  String get ludoMmRealPlayers => '실제 플레이어를 찾고 있어요';

  @override
  String ludoMmCountdownHint(Object seconds) {
    return '찾지 못하면 $seconds초 후 봇으로 채울게요';
  }

  @override
  String get ludoMmFilledByBots => '숙련된 봇으로 채워졌어요';

  @override
  String get ludoMmMatchFound => '매치 성사!';

  @override
  String get ludoMmCancel => '검색 취소';

  @override
  String get ludoMmStarting => '매치 시작 중…';

  @override
  String ludoMmFoundCount(Object found, Object total) {
    return '$found/$total명';
  }

  @override
  String get ludoMode1v1 => '1v1 상대';

  @override
  String get ludoMode1v1Sub => '빠른 매치, 익명 신원';

  @override
  String get ludoMode4Party => '4인 파티';

  @override
  String get ludoMode4PartySub => '상대 3명 찾기 • 빈 자리는 봇이 채워요';

  @override
  String get ludoLobbyHowToPlay => '플레이 방법';

  @override
  String get ludoRule1 => '주사위를 굴려 6이 나오면 집을 나가고, 4개의 말을 중앙으로';

  @override
  String get ludoRule2 => '경로에 4가지 초능력: 🚀 ❄ 🌀 🌪';

  @override
  String get ludoRule3 => '상대를 잡으면 추가 턴을 얻어요';

  @override
  String get ludoRule4 => '별은 안전 칸 • 능력은 3번 굴릴 때마다 재배치';

  @override
  String get rpsGuessExplain => '상대의 선택을 맞혀 보세요 — 정답이면 라운드 승점에 보너스 점수까지!';

  @override
  String get rateEnjoyTitle => 'Sarhny가 마음에 드시나요?';

  @override
  String get rateEnjoyBody => '회원님의 평가가 Sarhny 성장에 도움이 됩니다 💜';

  @override
  String get rateLove => '정말 좋아요 😍';

  @override
  String get rateMeh => '개선이 필요해요';

  @override
  String get rateLater => '나중에';

  @override
  String get rateFeedbackTitle => '어떻게 개선할까요?';

  @override
  String get rateFeedbackHint => '의견을 남겨 주세요…';

  @override
  String get rateSend => '보내기';

  @override
  String get rateThanks => '의견 감사합니다! 💜';

  @override
  String get fieldRequired => '필수 입력 항목';

  @override
  String get errorInvalidCredentials => '로그인 정보가 올바르지 않습니다';

  @override
  String get errorServerUnreachable => '서버에 연결할 수 없습니다';

  @override
  String get errorConnectionLost => '연결이 끊어졌습니다';

  @override
  String get errorUnexpected => '문제가 발생했습니다';

  @override
  String get loginUsernameHint => '예: ssarhny';

  @override
  String get loginSubtitle => 'Sarhny를 계속하려면 로그인하세요';

  @override
  String get registerAgeConfirmError => '만 18세 이상임을 확인해야 합니다';

  @override
  String get registerTermsError => '약관에 동의해야 합니다';

  @override
  String get registerUsernameTaken => '이미 사용 중인 사용자 이름입니다';

  @override
  String get registerUsernameFormat => '라틴 문자, 숫자, 밑줄만 사용 가능';

  @override
  String get registerUsernameInvalid => '유효하지 않은 사용자 이름입니다';

  @override
  String get registerEmailTaken => '이미 사용 중인 이메일입니다';

  @override
  String get registerEmailInvalid => '유효하지 않은 이메일입니다';

  @override
  String get registerPasswordWeak => '비밀번호가 너무 짧거나 일치하지 않습니다';

  @override
  String get registerSexRequired => '성별을 선택하세요';

  @override
  String get registerUsernameMin => '최소 3자 이상';

  @override
  String get registerUsernameReserved => '예약된 이름입니다';

  @override
  String get registerEmailInvalidShort => '유효하지 않은 이메일입니다';

  @override
  String get registerPasswordMin => '최소 8자 이상';

  @override
  String get registerPasswordMismatch => '비밀번호와 일치하지 않습니다';

  @override
  String get registerJoinTitle => 'Sarhny에 가입하기';

  @override
  String get registerJoinSubtitle => '진정한 자기표현의 공간 — 성인 전용';

  @override
  String get registerDisplayName => '표시 이름';

  @override
  String get registerNameMin => '최소 2자 이상';

  @override
  String get registerUsernameHint => '예: amal_x';

  @override
  String get registerPasswordConfirm => '비밀번호 확인';

  @override
  String get registerAgeConfirm => '만 18세 이상임을 확인합니다';

  @override
  String get registerAdultsOnly => 'Sarhny는 성인 전용입니다';

  @override
  String get registerAgreeTerms => '이용약관 및 개인정보 처리방침에 동의합니다';

  @override
  String get registerHaveAccount => '계정이 있으신가요?';

  @override
  String get registerSignInCta => '로그인';

  @override
  String get registerGender => '성별';

  @override
  String get registerGenderMale => '남성';

  @override
  String get registerGenderFemale => '여성';

  @override
  String get forgotTitle => '비밀번호 복구';

  @override
  String get forgotInstructions =>
      '등록된 이메일을 입력하면 한 시간 이내에 비밀번호 재설정 링크를 보내드립니다.';

  @override
  String get forgotSendLink => '링크 보내기';

  @override
  String get forgotBackToLogin => '로그인으로 돌아가기';

  @override
  String get forgotCheckEmailTitle => '이메일을 확인하세요';

  @override
  String get forgotEmailSentBody => '이 이메일이 등록되어 있으면 복구 링크를 보냈습니다';

  @override
  String get forgotCheckSpamHint => '받은 편지함을 확인하세요 (가끔은 스팸함도)';

  @override
  String get resetLinkExpired => '링크가 만료되었거나 유효하지 않습니다';

  @override
  String get resetTitle => '새 비밀번호 설정';

  @override
  String get resetHeading => '새 비밀번호';

  @override
  String get resetSubtitle => '계정에 사용할 강력한 새 비밀번호를 선택하세요.';

  @override
  String get resetPasswordMismatch => '일치하지 않습니다';

  @override
  String get resetDoneTitle => '비밀번호가 업데이트되었습니다';

  @override
  String get resetDoneBody => '이제 새 비밀번호로 로그인할 수 있습니다.';

  @override
  String get resetGoToLogin => '로그인';

  @override
  String get diagnosticsTitle => '연결 진단';

  @override
  String get diagnosticsEnvStatus => '.env 상태';

  @override
  String get diagnosticsConnectionStatus => '연결 상태';

  @override
  String get diagnosticsHint => '\"연결 테스트\"를 눌러 서버에 연결할 때 어떤 일이 일어나는지 확인하세요.';

  @override
  String get diagnosticsTestButton => '연결 테스트';

  @override
  String get feedSearchTooltip => '검색';

  @override
  String get feedEmptyFollowingTitle => '아직 게시물이 없습니다';

  @override
  String get feedEmptySectionTitle => '이 섹션에 아무것도 없습니다';

  @override
  String get feedEmptyFollowingSubtitle => '사람들을 팔로우하면 게시물을 볼 수 있습니다';

  @override
  String get feedEmptySectionSubtitle => '가장 먼저 무언가를 올려보세요 ⚡';

  @override
  String get feedScopeFollowing => '팔로잉';

  @override
  String get feedScopeGlobal => '글로벌';

  @override
  String get feedCrystalBadge => '✦ 크리스털';

  @override
  String get feedQuestionFromAnonymous => '익명의 질문';

  @override
  String get feedQuestionFrom => '질문자';

  @override
  String get feedUnsave => '저장 취소';

  @override
  String get feedSave => '저장';

  @override
  String get feedShareFooter => '— Sarhny에서';

  @override
  String get feedDeleteTitle => '게시물 삭제';

  @override
  String get feedDeleteBody => '게시물이 영구적으로 삭제되어 다른 사람에게 더 이상 표시되지 않습니다. 확실합니까?';

  @override
  String get feedDeleteSuccess => '게시물이 삭제되었습니다';

  @override
  String get feedDeleteFailed => '삭제할 수 없습니다';

  @override
  String get feedTimeNow => '방금';

  @override
  String get feedTimeAgo => 'قبل';

  @override
  String feedTimeMinutes(Object n) {
    return '$n분 전';
  }

  @override
  String feedTimeHours(Object n) {
    return '$n시간 전';
  }

  @override
  String feedTimeDays(Object n) {
    return '$n일 전';
  }

  @override
  String feedTimeSeconds(Object n) {
    return '$n초 전';
  }

  @override
  String feedTimeWeeks(Object n) {
    return '$n주 전';
  }

  @override
  String feedTimeMonths(Object n) {
    return '$n개월 전';
  }

  @override
  String feedTimeYears(Object n) {
    return '$n년 전';
  }

  @override
  String get sectionAll => '전체';

  @override
  String get sectionMoments => '순간';

  @override
  String get sectionFaces => '얼굴';

  @override
  String get sectionMinds => '생각';

  @override
  String get sectionAnswers => '답변';

  @override
  String get ludoTitle => '루도';

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
  String get ludoColorBlue => '파랑';

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
  String get inboxAppBarTitle => '받은 편지함';

  @override
  String get inboxEmptyTitle => '받은 편지함이 비어 있습니다';

  @override
  String get inboxEmptySubtitle => '익명 메시지가 여기에 표시됩니다';

  @override
  String get inboxMarkedRead => '읽음으로 표시됨';

  @override
  String get inboxUpdateFailed => '업데이트할 수 없습니다';

  @override
  String get inboxDeleted => '삭제됨';

  @override
  String get inboxDeleteFailed => '삭제할 수 없습니다';

  @override
  String get inboxReported => '신고됨 — 검토하겠습니다';

  @override
  String get inboxReportFailed => '신고할 수 없습니다';

  @override
  String get inboxAnonymous => '익명';

  @override
  String get inboxReplyWithPost => '게시물로 답장';

  @override
  String get inboxAnswered => '답변됨';

  @override
  String get inboxReportTooltip => '신고';

  @override
  String get inboxAnswerEmptyError => '먼저 답장을 작성하세요';

  @override
  String get inboxReplyPublished => '답장이 게시되었습니다 ✨';

  @override
  String get inboxSessionExpired => '다시 로그인해 주세요';

  @override
  String get inboxRateLimited => '잠시 후 1분 뒤에 다시 시도하세요';

  @override
  String get inboxConnectionFailed => '연결 실패 —';

  @override
  String get inboxYourReplyLabel => '내 답장 (게시물로 게시됩니다 🎨)';

  @override
  String get inboxReplyHint => '답장을 작성하세요…';

  @override
  String get inboxHideLayer3 => '레이어 3 숨기기';

  @override
  String get inboxAddLayer3 => '레이어 3 추가 — 성찰';

  @override
  String get inboxLayer3Hint => '내 성찰 (선택)';

  @override
  String get inboxPublishReply => '답장 게시';

  @override
  String get mirrorsNewMirror => '새 미러';

  @override
  String get mirrorsEmptyTitle => '아직 미러가 없습니다';

  @override
  String get mirrorsEmptySubtitle => '미러를 게시해 보세요 — 질문을 던지고 사람들이 솔직하게 답하게 하세요';

  @override
  String get mirrorsBadge => '🪞 미러';

  @override
  String get mirrorsResponsesSuffix => '개의 답변';

  @override
  String get mirrorsCopyLink => '링크 복사';

  @override
  String get mirrorsShareMessage => '이 미러에 대한 당신의 답을 나와 공유하세요:';

  @override
  String get mirrorsShareSubject => 'Sarhny — 미러';

  @override
  String get mirrorsShareFailed => '공유를 열 수 없습니다';

  @override
  String get mirrorsQuestionLabel => '미러 질문';

  @override
  String get mirrorsCreateHint => '자기 발견을 위한 질문입니다 — 답변은 익명이며 워드 클라우드를 만듭니다.';

  @override
  String get mirrorsQuestionHint => '예: 무엇이 스스로를 자랑스럽게 만드나요?';

  @override
  String get mirrorsCreateButton => '미러 만들기';

  @override
  String get mirrorsCreated => '미러가 생성되었습니다';

  @override
  String get mirrorsCreateFailed => '만들 수 없습니다';

  @override
  String get mirrorsLoginToRespond => '미러에 답하려면 로그인하세요';

  @override
  String get mirrorsRateLimit => '최근에 너무 많이 답했습니다 — 잠시 기다려 주세요';

  @override
  String get mirrorsSendFailed => '보낼 수 없습니다';

  @override
  String get mirrorsBadgeShort => '미러';

  @override
  String get mirrorsQuestionTitle => '질문';

  @override
  String get mirrorsResponseHint => '솔직한 답을 작성하세요 — 당신의 신원은 표시되지 않습니다';

  @override
  String get mirrorsAnonymousNote =>
      '로그인하지 않고도 답할 수 있습니다 — 당신의 신원은 절대 표시되지 않습니다';

  @override
  String get mirrorsSendResponse => '내 답변 보내기';

  @override
  String get mirrorsFrom => '미러 작성자';

  @override
  String get mirrorsSentTitle => '답변이 전송되었습니다';

  @override
  String get mirrorsSentBody =>
      '당신의 말은 미러 주인이 보는 워드 클라우드에 더해집니다. 솔직함에 감사합니다 🌙';

  @override
  String get mirrorsBackHome => '홈으로 돌아가기';

  @override
  String get postTitle => '게시물';

  @override
  String get postReplyHint => '답글을 작성하세요…';

  @override
  String get postMicPermission => '마이크 권한이 필요합니다';

  @override
  String get postRecordStartFailed => '녹음을 시작할 수 없습니다';

  @override
  String get postImagePickFailed => '이미지를 선택할 수 없습니다';

  @override
  String get postSlowDownRetry => '잠시 후 다시 시도하세요';

  @override
  String get postSendFailed => '보낼 수 없습니다';

  @override
  String get postTooltipImage => '이미지';

  @override
  String get postTooltipVoice => '음성 녹음';

  @override
  String get postVoiceRecording => '음성 녹음';

  @override
  String get postSecondsShort => '초';

  @override
  String get postReplySent => '전송됨 🌙';

  @override
  String get postLoginToReply => '답글을 달려면 로그인하세요';

  @override
  String get postSlowDownBeforeSend => '보내기 전에 잠시 기다리세요';

  @override
  String get postRepliesTitle => '답글';

  @override
  String get postRepliesLoadFailed => '답글을 불러올 수 없습니다';

  @override
  String get postRepliesEmpty => '아직 답글이 없습니다. 대화를 시작하는 첫 번째 사람이 되어 보세요 🌙';

  @override
  String get postLoadMore => '더 보기';

  @override
  String get postAnonymous => '익명';

  @override
  String get postWithName => '실명으로';

  @override
  String get postDeleteReplyTitle => '답글 삭제';

  @override
  String get postDeleteReplyConfirmMine => '답글이 사라집니다. 확실한가요?';

  @override
  String get postDeleteReplyConfirmOther => '이 답글이 게시물에서 사라집니다.';

  @override
  String get postDeleted => '삭제됨';

  @override
  String get postDeleteFailed => '삭제할 수 없습니다';

  @override
  String get postDeleteCommentTitle => '댓글 삭제';

  @override
  String get postDeleteCommentConfirm => '이 댓글이 영구적으로 삭제됩니다. 계속할까요?';

  @override
  String get postPublished => '게시됨';

  @override
  String get postLoginToComment => '댓글을 달려면 로그인하세요';

  @override
  String get postPublishFailed => '게시할 수 없습니다';

  @override
  String get postCommentsTitle => '댓글';

  @override
  String get postCommentHint => '댓글을 작성하세요…';

  @override
  String get postCommentsLoadFailed => '댓글을 불러올 수 없습니다';

  @override
  String get postCommentsEmpty => '첫 번째로 댓글을 남겨 보세요';

  @override
  String get profileSessionIncomplete => '세션이 완료되지 않았습니다';

  @override
  String get profileSessionIncompleteHint => '모든 것이 제대로 작동하도록 다시 로그인하세요.';

  @override
  String get profileLogoutRelogin => '로그아웃 후 다시 로그인';

  @override
  String get profileShareMine => '내 프로필 공유';

  @override
  String get profileThemeLight => '라이트 모드';

  @override
  String get profileThemeDark => '다크 모드';

  @override
  String get profileEmptyActiveTitle => '활성 게시물이 없습니다';

  @override
  String get profileEmptyActiveSubtitle => '게시물 작성 ⚡';

  @override
  String get profileEmptyMomentsTitle => '아직 순간이 없습니다';

  @override
  String get profileEmptyMomentsSubtitle => '하루의 한 순간을 공유하세요 ⚡';

  @override
  String get profileEmptyAnswersTitle => '아직 답변이 없습니다';

  @override
  String get profileEmptyAnswersSubtitle => '익명 메시지에 대한 답변이 여기에 표시됩니다 🕶️';

  @override
  String get profileEmptyCrystalsTitle => '아직 크리스탈이 없습니다';

  @override
  String get profileEmptyLikesTitle => '아직 어떤 크리스탈도 좋아하지 않았습니다';

  @override
  String get profileAvatarUpdated => '사진이 업데이트되었습니다';

  @override
  String get profileUploadFailed => '업로드 실패';

  @override
  String get profileEditTitle => '프로필 편집';

  @override
  String get profileFieldDisplayName => '표시 이름';

  @override
  String get profileFieldBio => '소개';

  @override
  String get profileFieldLocation => '위치';

  @override
  String get profileFieldWebsite => '웹사이트';

  @override
  String get profileSaved => '저장되었습니다';

  @override
  String get profileSaveFailed => '저장하지 못했습니다';

  @override
  String get profileShareAccount => '계정 공유';

  @override
  String get profilePersona => '내 페르소나';

  @override
  String get profileFollowingCount => '팔로잉';

  @override
  String get profileAnswers => '답변';

  @override
  String get profileBadgeCrystals => '크리스탈';

  @override
  String get profileBadgeStreak => '연속';

  @override
  String get profileBadgeMirrors => '거울';

  @override
  String get profileTabActiveShort => '활성';

  @override
  String get profileTabMoments => '순간';

  @override
  String get profileTabAnswers => '답변';

  @override
  String get profileTabCrystalsShort => '결정화';

  @override
  String get profileTabLikesShort => '좋아요';

  @override
  String get profileQuickSaved => '내 저장';

  @override
  String get profileQuickPlay => '플레이 & 도전';

  @override
  String get profileQuickHelp => '도움말';

  @override
  String get profileShareThis => '이 프로필 공유';

  @override
  String get profileBlockUser => '이 사용자 차단';

  @override
  String get profileBlockUserBody =>
      '상대방의 메시지나 게시물을 받지 않으며, 상대방도 당신을 볼 수 없습니다. 나중에 설정에서 차단을 해제할 수 있습니다.';

  @override
  String get profileBlocked => '차단되었습니다';

  @override
  String get profileBlockFailed => '차단하지 못했습니다';

  @override
  String get profileReportSent => '신고가 전송되었습니다 — 검토하겠습니다';

  @override
  String get profileReport => '신고';

  @override
  String get profileNothingHere => '아직 아무것도 없습니다';

  @override
  String get profileFollowingStat => '팔로잉';

  @override
  String get profileActionFailed => '요청을 완료하지 못했습니다';

  @override
  String get profileFollowingState => '팔로잉 중';

  @override
  String get profileFollowAction => '팔로우';

  @override
  String get profileBadgeHowToGet => '얻는 방법';

  @override
  String get profileBadgeCrystalsTitle => '크리스탈 ✦';

  @override
  String get profileBadgeCrystalsLead =>
      '크리스탈은 24시간을 견디고 진정한 반응을 얻어 스쳐가는 순간에서 영원한 흔적으로 바뀐 당신의 게시물입니다.';

  @override
  String get profileBadgeCrystalsStep1 =>
      '논의할 가치가 있는 것을 게시하세요 — 순간, 이미지 또는 아이디어.';

  @override
  String get profileBadgeCrystalsStep2 => '모든 상호작용(좋아요, 답글)이 게시물의 중력을 높입니다.';

  @override
  String get profileBadgeCrystalsStep3 =>
      '24시간이 끝나기 전에 결정화 임계값에 도달하면 → 영구적인 ✦가 되어 크리스탈에 저장됩니다.';

  @override
  String get profileBadgeCrystalsStep4 =>
      '반응이 없는 게시물은 24시간 후 조용히 사라집니다(그것이 크리스탈을 가치 있게 만듭니다).';

  @override
  String get profileBadgeCrystalsTip =>
      '크리스탈은 당신의 흔적을 증명하듯 프로필 방문자에게 표시됩니다. 쌓이는 것이 아니라 남는 것을 공유하세요.';

  @override
  String get profileBadgeStreakTitle => '연속 🔥';

  @override
  String get profileBadgeStreakLead =>
      '연속은 Sarhny에서 연이은 날들의 기록입니다. 게시하는 날마다 당신의 불꽃에 불씨를 더합니다.';

  @override
  String get profileBadgeStreakStep1 => '앱을 열고 24시간마다 최소 한 번 게시하세요.';

  @override
  String get profileBadgeStreakStep2 => '연속은 숨 돌릴 여유로 최대 48시간까지 기록을 유지합니다.';

  @override
  String get profileBadgeStreakStep3 => '연속이 길수록 프로필에서 당신의 빛은 더 고귀하고 두드러집니다.';

  @override
  String get profileBadgeStreakStep4 =>
      '연속이 끊기면 카운터가 초기화됩니다 — 하지만 쌓아온 크리스탈은 지워지지 않습니다.';

  @override
  String get profileBadgeStreakTip =>
      '연속은 품질이 아니라 헌신을 측정합니다. 하루에 많이보다 매일 조금이 낫습니다.';

  @override
  String get profileBadgeMirrorsTitle => '거울 🪞';

  @override
  String get profileBadgeMirrorsLead =>
      '거울은 당신이 던지는 열린 질문으로, 사람들이 그것을 통해 당신을 솔직하게 묘사하게 합니다. 답변이 쌓여 주변 사람들이 당신을 어떻게 보는지 반영하는 구름을 이룹니다.';

  @override
  String get profileBadgeMirrorsStep1 =>
      '「거울」 탭을 눌러 성찰적인 질문을 만드세요 (예: 나의 가장 두드러진 점은?).';

  @override
  String get profileBadgeMirrorsStep2 => '거울 링크를 친구들에게 또는 다른 앱의 계정에 공유하세요.';

  @override
  String get profileBadgeMirrorsStep3 =>
      '답변은 익명으로 도착합니다 — 누가 무슨 말을 했는지 알 수 없어 사람들이 솔직하게 말합니다.';

  @override
  String get profileBadgeMirrorsStep4 =>
      '각 거울은 프로필에 표시되어 Sarhny에서의 비중을 높이는 🪞 배지를 줍니다.';

  @override
  String get profileBadgeMirrorsTip =>
      '거울은 모호한 질문보다 구체적인 질문에서 가장 잘 작동합니다. 정말 알고 싶은 것을 물으세요.';

  @override
  String get profileSavedTitle => '저장됨';

  @override
  String get profileSavedEmptyTitle => '저장된 항목이 없습니다';

  @override
  String get profileSavedEmptySubtitle => '🔖 를 눌러 게시물을 저장하면 여기에 표시됩니다';

  @override
  String get profileAnonLoginRequired => '메시지를 보내려면 로그인하세요';

  @override
  String get profileAnonSent => '메시지가 전달되었습니다 🌙';

  @override
  String get profileAnonRateLimited => '시도가 너무 많습니다 — 잠시 기다리세요';

  @override
  String get profileAnonSendFailed => '보내지 못했습니다';

  @override
  String get profileAnonTitle => '익명으로 질문하기';

  @override
  String get profileAnonSubtitle => '당신이 밝히지 않는 한 누가 보냈는지 알 수 없습니다';

  @override
  String get profileAnonHint => '질문이나 메시지를 입력하세요…';

  @override
  String get profileAnonSend => '보내기';

  @override
  String get profileLinkCopied => '링크가 복사되었습니다';

  @override
  String get articleAppBarTitle => '나의 페르소나 ✨';

  @override
  String get articleGenerated => '기사가 생성되었습니다 ✨';

  @override
  String get articleGenerateFailed => '생성하지 못했습니다';

  @override
  String get articleCurrentLabel => '현재 내 기사';

  @override
  String articleArchiveLabel(Object count) {
    return '보관함 · 지난 기사 ($count)';
  }

  @override
  String get articleHeaderTitle => '당신의 개인 기사';

  @override
  String get articleHeaderBody =>
      '당신의 기사는 익명 메시지에 대한 공개 답변에서 작성됩니다. 솔직하게 답할수록 AI는 당신을 더 잘 알고 — 더 진실하게 당신에 대해 씁니다.';

  @override
  String get articleNextTitle => '다음 기사';

  @override
  String articleDaysRemaining(Object days) {
    return '다음 기사를 만들 수 있을 때까지 $days일 남았습니다.';
  }

  @override
  String articleCooldownNote(Object days) {
    return '$days일마다 새 버전을 만들 수 있습니다. 새 버전은 최신 답변을 바탕으로 작성됩니다.';
  }

  @override
  String get articleProgress => '당신의 진행 상황';

  @override
  String articleNeedMore(Object count) {
    return '기사를 잠금 해제하려면 익명 메시지에 대한 공개 답변이 $count개 더 필요합니다. 이 답변들이 기사를 진정으로 당신답게 만듭니다.';
  }

  @override
  String get articleGenerating => '생성 중…';

  @override
  String get articleRegenerateCta => '내 기사의 새 버전 만들기';

  @override
  String get articleGenerateCta => '지금 내 기사 작성하기 ✨';

  @override
  String get articleSaved => '저장됨';

  @override
  String get articleSaveFailed => '저장하지 못했습니다';

  @override
  String get articlePublishTitle => '기사를 공개 게시';

  @override
  String get articlePublishBody =>
      '게시 후 24시간이 지나면 블로그의 공개 링크를 통해 누구나 기사를 볼 수 있습니다. 언제든지 삭제할 수 있습니다.';

  @override
  String get articlePublishConfirm => '게시';

  @override
  String get articlePublishScheduled => '24시간 후에 표시됩니다 🌙';

  @override
  String get articlePublishFailed => '게시하지 못했습니다';

  @override
  String get articleDeleteTitle => '기사 삭제';

  @override
  String get articleDeleteBody => '현재 기사가 삭제됩니다. 이전 버전은 보관함에 저장된 채로 유지됩니다.';

  @override
  String get articleDeleted => '삭제됨';

  @override
  String get articleDeleteFailed => '삭제하지 못했습니다';

  @override
  String get articleStatusPublished => '게시됨';

  @override
  String get articleStatusPrivate => '비공개';

  @override
  String get articlePublishAction => '게시하기';

  @override
  String get articleEdit => '편집';

  @override
  String get articleDeleteHistoryTitle => '보관함에서 삭제';

  @override
  String get articleDeleteHistoryBody => '이 버전은 보관함에서 영구적으로 삭제됩니다.';

  @override
  String get composeImageTooLarge => '이미지가 15MB를 초과합니다';

  @override
  String get composeCropImage => '이미지 자르기';

  @override
  String get composeUploadFailed => '이미지를 업로드하지 못했습니다';

  @override
  String get composePublishedToast => '진심을 담아 게시했어요 ✨';

  @override
  String get composePublishFailed => '게시하지 못했습니다';

  @override
  String get composeDiscardTitle => '초안을 삭제할까요?';

  @override
  String get composeDiscardBody => '작성한 내용이 사라집니다. 계속할까요?';

  @override
  String get composeKeep => '유지';

  @override
  String get composeDiscard => '삭제';

  @override
  String get composeClose => '닫기';

  @override
  String get composeNewPost => '새 게시물';

  @override
  String get composeWriteFromHeart => '마음을 담아 써보세요';

  @override
  String get composeLivesTitle => '게시물은 24시간만 유지됩니다';

  @override
  String get composeLivesBody =>
      '끝나기 전에 진심 어린 반응을 얻으면 → 결정화되어 ✦ 영원히 남습니다. 그렇지 않으면 조용히 사라집니다. 논의할 가치가 있는 것을 나눠보세요.';

  @override
  String get composeLayer1Title => '레이어 1 — 핵심';

  @override
  String get composeLayer1Subtitle => '몇 줄로 담은 핵심 생각';

  @override
  String get composeLayer1Hint => '무슨 생각을 하고 있나요?';

  @override
  String get composeLayer2Title => '레이어 2 — 이미지';

  @override
  String get composeLayer2Subtitle => '최대 4장의 이미지(정사각형)';

  @override
  String get composeUploading => '업로드 중…';

  @override
  String get composeAddImage => '이미지 추가';

  @override
  String get composeHideLayer3 => '레이어 3 숨기기';

  @override
  String get composeAddLayer3 => '레이어 3 추가 — 성찰';

  @override
  String get composeLayer3Title => '레이어 3 — 성찰';

  @override
  String get composeLayer3Subtitle => '긴 글(최대 4000자)';

  @override
  String get composeLayer3Hint => '함께 생각해봐요… (선택)';

  @override
  String get composeMomentDesc =>
      '하루 중 스치는 한 줄 — 순간의 감정, 떠오른 생각, 지금 일어나는 일. 가장 짧고 가장 솔직하게.';

  @override
  String get composeFaceDesc => '당신의 흔적을 담은 이미지와 짧은 설명. 간직할 가치가 있는 시각적 순간을 위해.';

  @override
  String get composeMindDesc => '차분히 써 내려가는 더 깊은 사색. 읽는 데 시간이 필요한 생각을 위한 공간.';

  @override
  String get gameAiQLight => '요즘 가장 웃긴 게 뭐야?';

  @override
  String get gameAiQFunny => '사람들 앞에서 겪은 가장 창피했던 일은?';

  @override
  String get gameAiQBold => '아무에게도 말한 적 없는 비밀이 뭐야?';

  @override
  String get helpTabFeatures => '기능';

  @override
  String get helpTabFaq => '자주 묻는 질문';

  @override
  String get helpLegalLastUpdated => '마지막 업데이트: 2025년 11월';

  @override
  String get helpLegalReadFull => '웹사이트에서 전체 버전 읽기';

  @override
  String get helpLegalTermsSummary =>
      'Sarhny에 가입함으로써 귀하는 다음 약관을 준수하는 데 동의합니다:\n\n• 연령: 이 앱은 성인(만 18세 이상)만 이용할 수 있습니다. 미성년자의 것으로 확인된 계정은 삭제됩니다.\n\n• 콘텐츠: 법을 위반하거나 위해를 선동하지 않으며, 협박, 음란물 또는 혐오 발언을 포함하지 않는 콘텐츠를 게시할 것에 동의합니다.\n\n• 익명 메시지: 우리 플랫폼이 익명 메시지 전송을 허용하며, 이를 수락하거나 신고하는 결정에 대한 책임이 귀하에게 있음을 이해합니다.\n\n• 계정: 이메일과 비밀번호를 보호하는 것은 귀하의 책임입니다. Sarhny는 절대 비밀번호를 요구하지 않습니다.\n\n• 서비스 중단: 우리는 이 약관을 위반하는 계정을 사전 통지 없이 정지할 권리를 보유합니다.\n\n• 준거법: 앱 사용에는 사우디아라비아 왕국의 법률이 적용됩니다.\n\n전체 최신 버전을 읽으려면 아래 링크를 여세요.';

  @override
  String get helpLegalPrivacySummary =>
      'Sarhny에서 귀하의 개인정보는 우리 경험의 핵심입니다:\n\n• 우리가 수집하는 것: 이메일, 사용자 이름, 귀하가 게시하는 사진과 텍스트, 전송 시 IP 주소(악용 방지 목적으로만).\n\n• 우리가 수집하지 않는 것: 연락처, 정확한 위치, 앱 외부의 검색 기록은 수집하지 않습니다.\n\n• 익명 메시지: 발신자의 신원은 귀하나 다른 어떤 사용자에게도 표시되지 않습니다. 법적 신고 목적으로만 IP 해시를 내부적으로 30일간 보관합니다.\n\n• 알림: 마케팅 알림을 보내지 않습니다. 모든 알림은 귀하의 계정 내 활동과 관련됩니다.\n\n• 데이터 공유: 어떤 데이터도 제3자에게 판매하지 않습니다. 다음의 경우에만 공유합니다:\n  - 공식 사법 요청이 있을 때.\n  - 서비스를 운영하기 위한 인프라 제공업체(서버, 클라우드 저장소)와.\n\n• 귀하의 권리: 설정 화면에서 데이터 사본을 요청하거나 계정을 영구적으로 삭제할 수 있습니다.\n\n• 어린이: 이 앱은 만 18세 미만에게 금지됩니다. 미성년자의 계정을 알게 되면 즉시 삭제합니다.\n\n자세한 법적 버전은 아래 링크를 여세요.';

  @override
  String get helpLegalContentSummary =>
      'Sarhny의 모든 콘텐츠는 이 정책의 적용을 받습니다:\n\n✓ 허용: 의견 표현, 진솔한 질문, 단정한 개인 사진, 예술, 성찰적인 생각.\n\n✗ 금지되며 즉시 삭제됨:\n• 모든 형태의 음란물 또는 준음란 콘텐츠.\n• 종교, 인종 또는 성별에 대한 혐오 발언.\n• 협박 또는 위협.\n• 폭력, 테러 또는 마약 조장.\n• 미성년자의 신원을 드러내거나 미성년자를 대상으로 하는 모든 것.\n• 침해적인 광고 및 마케팅 링크.\n• 타인 사칭.\n\n우리는 위반 사항을 탐지하기 위해 머신러닝 알고리즘 + 사람의 검토를 사용합니다. 신고는 모든 게시물이나 메시지의 \"신고\" 버튼을 통해 모든 사용자가 이용할 수 있습니다.';

  @override
  String get notifTitle => '알림';

  @override
  String notifAllMarkedRead(Object n) {
    return '읽음으로 표시됨 ($n)';
  }

  @override
  String get notifMarkReadFailed => '업데이트하지 못했습니다';

  @override
  String get notifMarkAllRead => '모두 읽음';

  @override
  String get notifEmptyTitle => '알림이 없습니다';

  @override
  String get notifEmptySubtitle => '새로운 소식에 대한 알림이 여기에 표시됩니다';

  @override
  String get notifLikedYourPost => '회원님의 게시물을 좋아합니다';

  @override
  String get notifCommentedOnYourPost => '회원님의 게시물에 댓글을 남겼습니다';

  @override
  String get notifStartedFollowingYou => '회원님을 팔로우하기 시작했습니다';

  @override
  String get notifAnonymousQuestion => '익명 질문을 받았습니다';

  @override
  String get notifPostCrystallized => '회원님의 게시물이 결정화되었습니다 ✦';

  @override
  String get searchHint => '사용자 검색 또는 추천 보기';

  @override
  String get searchEmptyBrowse => '표시할 사용자가 아직 없습니다';

  @override
  String searchNoResults(Object query) {
    return '\"$query\"와 일치하는 결과가 없습니다';
  }

  @override
  String get searchSuggestedForYou => '추천';

  @override
  String get settingsTierPro => '프로';

  @override
  String get settingsTierCreator => '크리에이터';

  @override
  String get settingsTierEternal => '이터널';

  @override
  String get settingsTierFree => '무료';

  @override
  String get settingsPackagePrefix => '플랜';

  @override
  String get settingsAttentionPrefix => '주목도:';

  @override
  String get settingsManageSubscription => '구독 관리';

  @override
  String get settingsPlansTitle => '플랜';

  @override
  String get settingsPlansSubtitle => 'Sarhny 플랜은 더 큰 주목도 예산과 더 강한 존재감을 제공합니다.';

  @override
  String get settingsUpgraded => '업그레이드됨 ✨';

  @override
  String get settingsUpgradeFailed => '업그레이드하지 못했습니다';

  @override
  String get settingsSubscriptionCancelled => '취소됨';

  @override
  String get settingsCancelFailed => '취소하지 못했습니다';

  @override
  String get settingsDailyAttentionPrefix => '일일 주목도:';

  @override
  String get settingsCurrentPlan => '현재 플랜';

  @override
  String get settingsCancelSubscription => '구독 취소';

  @override
  String get settingsUpgrade => '업그레이드';

  @override
  String get settingsBlockedEmptyTitle => '차단된 계정이 없습니다';

  @override
  String get settingsBlockedEmptySubtitle =>
      '계정을 차단하면 여기에 표시되며 언제든지 차단을 해제할 수 있습니다.';

  @override
  String get settingsUnblocked => '차단을 해제했습니다';

  @override
  String get settingsUnblockFailed => '차단을 해제하지 못했습니다';

  @override
  String get settingsUnblock => '차단 해제';

  @override
  String get reportReasonPostAbusive => '욕설 또는 모욕적인 콘텐츠';

  @override
  String get reportReasonPostHarassment => '괴롭힘 또는 따돌림';

  @override
  String get reportReasonPostSexual => '성적인 콘텐츠';

  @override
  String get reportReasonPostRacism => '인종차별 또는 선동';

  @override
  String get reportReasonPostSpam => '스팸 또는 중복 콘텐츠';

  @override
  String get reportReasonPostPrivacy => '개인정보 침해';

  @override
  String get reportReasonPostMisinfo => '오해의 소지가 있는 정보';

  @override
  String get reportReasonOther => '기타';

  @override
  String get reportReasonUserAbusive => '욕설 또는 괴롭힘 계정';

  @override
  String get reportReasonUserImpersonation => '사칭';

  @override
  String get reportReasonUserScam => '사기 / 스팸 계정';

  @override
  String get reportReasonUserMinors => '미성년자를 표적으로 함';

  @override
  String get reportReasonUserSpamMessages => '반복적으로 스팸 메시지를 보냄';

  @override
  String get reportReasonUserProfile => '규정을 위반한 프로필 콘텐츠';

  @override
  String get reportNeedClearReason => '신고에 대한 명확한 사유를 적어 주세요';

  @override
  String get reportReceived => '신고가 접수되었습니다. 감사합니다 🌙';

  @override
  String get reportSendFailed => '신고를 보낼 수 없습니다';

  @override
  String get reportTitlePost => '게시물 신고';

  @override
  String get reportTitleUser => '사용자 신고';

  @override
  String get reportConfidentialNote =>
      '신고는 비밀이 보장됩니다. 모더레이션 팀이 24시간 이내에 검토합니다.';

  @override
  String get reportExplainBriefly => '사유를 간략히 설명해 주세요';

  @override
  String get reportExtraDetails => '추가 세부 정보 (선택 사항)';

  @override
  String get reportSubmit => '신고 제출';

  @override
  String get commonComingSoon => '곧 출시…';

  @override
  String get carromChatLoadFailed => '메시지를 불러올 수 없습니다';

  @override
  String get carromWalletBalance => '현재 잔액';

  @override
  String get carromWalletLoadFailed => '잔액을 불러올 수 없습니다';

  @override
  String get carromGotIt => '확인';

  @override
  String carromAimAnglePower(Object angle, Object power) {
    return '각도 $angle° · 파워 $power%';
  }

  @override
  String get carromAimDragStriker => '스트라이커를 좌우로 드래그하세요';

  @override
  String get carromMmSearchFailed => '상대를 찾을 수 없습니다';

  @override
  String get carromMmWaitAverage => '평균 대기 30초 미만';

  @override
  String get carromMmWaitLongTitle => '오래 걸리나요?';

  @override
  String get carromMmVsComputerSoon => '컴퓨터와의 대전 — 곧 출시';

  @override
  String get carromInviteCreateFailed => '초대를 만들 수 없습니다';

  @override
  String get carromInvitePasteFirst => '먼저 초대 코드를 붙여넣으세요';

  @override
  String get carromInviteJoinFailed => '초대에 참여할 수 없습니다';

  @override
  String get carromInviteYourCode => '내 초대 코드';

  @override
  String get carromInviteCodeHint => '코드는 5분간 유효합니다. 친구와 공유하여 경기에 참여하세요.';

  @override
  String get carromInviteCopied => '코드가 복사되었습니다';

  @override
  String get carromInviteEnterRoom => '방 입장';

  @override
  String get carromWalletLoading => '지갑 불러오는 중...';

  @override
  String get carromRulesTitle => '간단 규칙';

  @override
  String get carromRule1 => '• 조준하려면 스트라이커에서 안쪽으로 드래그 — 길게 끌수록 샷이 강해집니다';

  @override
  String get carromRule2 => '• 흰 말 = 1점, 검은 말 = 2점, 퀸 = 3점 (단, 커버해야 함)';

  @override
  String get carromRule3 => '• 자기 색을 넣으면 턴을 유지하고, 파울 시 잃습니다';

  @override
  String get carromRule4 => '• 승자는 상대에게 신원을 공개하고(선택) 모든 점수를 가져갑니다';

  @override
  String get carromConcedeTitle => '기권하시겠어요?';

  @override
  String carromConcedeBody(Object pot) {
    return '지금 기권하면 상대가 $pot점을 얻습니다. 되돌릴 수 없습니다.';
  }

  @override
  String get carromConcedeContinue => '경기 계속하기';

  @override
  String get carromGameTitle => '캐롬';

  @override
  String carromReconnectAttempt(Object attempt) {
    return '재연결 중... (시도 #$attempt)';
  }

  @override
  String get carromOpponentDisconnected => '상대가 연결이 끊겼습니다 — 대기 중 ';

  @override
  String get carromRematchStartFailed => '지금은 재대결을 시작할 수 없습니다';

  @override
  String get carromActionFailed => '지금은 작업을 수행할 수 없습니다';

  @override
  String get carromRevealSent => '완료 — 상대가 동의하면 서로 신원을 공개합니다';

  @override
  String get carromStayedAnonymous => '익명을 유지했습니다';

  @override
  String get carromRequestFailed => '요청을 보낼 수 없습니다';

  @override
  String get carromSarhnyTitle => '상대에게 보내는 Sarhny 메시지';

  @override
  String get carromSarhnySubtitle => '\"당신과 캐롬을 함께함\" 태그와 함께 상대 받은함에 전달됩니다';

  @override
  String get carromSarhnyHint => '메시지를 작성하세요...';

  @override
  String get carromMessageTooShort => '메시지가 너무 짧습니다';

  @override
  String get carromSendFailed => '보낼 수 없습니다';

  @override
  String get carromMessageDelivered => '메시지가 상대에게 전달되었습니다';

  @override
  String carromAdReward(Object credited, Object balance) {
    return '+$credited점 — 잔액: $balance';
  }

  @override
  String get carromAdDailyCap => '일일 한도에 도달했습니다 (광고 10개)';

  @override
  String get carromAdUnavailable => '지금은 광고를 사용할 수 없습니다 — 나중에 다시 시도하세요';

  @override
  String get carromAdVerifyFailed => '광고를 확인할 수 없습니다';

  @override
  String get carromAdUnsupported => '이 플랫폼에서는 광고가 지원되지 않습니다';

  @override
  String get carromAdRewardFailed => '보상을 추가할 수 없습니다';

  @override
  String get carromRevealTitle => '상대에게 신원을 공개하기';

  @override
  String get carromRevealSubtitle => '서로 공개 — 무료';

  @override
  String get carromHideTitle => '내 신원 숨기기';

  @override
  String get carromHideSubtitle => '익명 유지 — 10점 차감';

  @override
  String get carromSendSarhnyTitle => 'Sarhny 메시지 보내기';

  @override
  String get carromSendSarhnySubtitle => '상대 받은함으로 — 경기 맥락과 함께';

  @override
  String get carromWatchAdTitle => '광고 시청으로 +1점';

  @override
  String get carromWatchAdSubtitle => '하루 최대 광고 10개';

  @override
  String get carromSendSarhnyShort => 'Sarhny 보내기';

  @override
  String get carromSendSarhnyShortSub => '신원을 밝히지 않고 상대에게 메시지 보내기';

  @override
  String get carromOpponentConceded => '상대가 기권했습니다';

  @override
  String get carromOpponentConcededSub => '승리는 당신의 것입니다. 새 경기?';

  @override
  String get carromYouConceded => '이 경기를 기권했습니다';

  @override
  String get carromYouConcededSub => '모든 경기가 배움입니다. 언제든 다시 도전하세요.';

  @override
  String get carromWonSubtitle => '당신이 이 경기의 챔피언입니다';

  @override
  String get carromLostSubtitle => '모든 경기가 새로운 기회입니다';

  @override
  String get carromPoints => '점';

  @override
  String get carromBackToLobby => '로비로 돌아가기';

  @override
  String get carromSearchOther => '다른 상대 찾기';

  @override
  String carromRematchWaiting(Object seconds) {
    return '상대 수락 대기 중… ($seconds초)';
  }

  @override
  String get carromRematchWaitingHint => '상대가 \"재대결\"을 누르면 경기가 즉시 시작됩니다';

  @override
  String get carromRematchDeclined => '상대가 재대결을 거절했습니다';

  @override
  String get carromRematchTimeout => '시간 종료 — 상대 사용 불가';

  @override
  String get carromRematchSameOpponent => '또는 같은 상대와 재대결';

  @override
  String get carromRematchSameOpponentAction => '같은 상대와 재대결';

  @override
  String get carromRematchAction => '재대결';

  @override
  String get carromWhatHappenedLabel => '이 경기에서 무슨 일이 있었나';

  @override
  String get carromMatchReviewSoon => '경기 리뷰 (곧 출시)';

  @override
  String get carromWhatHappened => '무슨 일이 있었나요?';

  @override
  String get carromSoon => '곧';

  @override
  String get carromReviewMovesSoon => '마지막 수를 검토하기 (곧 출시)';

  @override
  String get carromMmRaceHint => '먼저 도착한 사람이 먼저 시작합니다';

  @override
  String get carromCosmeticsTitle2 => '캐롬 스킨';

  @override
  String get carromCosmeticsBoard => '보드';

  @override
  String get carromCosmeticsPieces => '말';

  @override
  String get carromCosmeticsSound => '소리';

  @override
  String get carromCosmeticsMute => '게임 소리 음소거';

  @override
  String get carromBoardWalnut => '고급 목재';

  @override
  String get carromBoardSapphire => '로열 블루';

  @override
  String get carromBoardEmerald => '에메랄드 그린';

  @override
  String get carromCoinClassic => '클래식';

  @override
  String get carromCoinRoyal => '로열 골드';

  @override
  String get carromCoinVivid => '선명한';

  @override
  String get carromCoinCandy => '캔디';

  @override
  String get carromChatNiceGame => '멋진 경기';

  @override
  String get carromChatFireShot => '불꽃 슛';

  @override
  String get carromChatPreciseAim => '정확한 조준';

  @override
  String get carromChatWatchLearn => '보고 배워';

  @override
  String get carromChatMyLuck => '내 운이란';

  @override
  String get carromChatBravo => '브라보';

  @override
  String get carromChatWow => '와우!';

  @override
  String get carromChatGoodLuck => '행운을 빌어';

  @override
  String get carromChatEasy => '쉽네';

  @override
  String get carromChatMadeItHard => '어렵게 만드네';

  @override
  String get carromChatCovered => '덮었다!';

  @override
  String get carromChatBeautifulGame => '멋진 경기';

  @override
  String get carromMatchWonMatch => '경기에서 이겼어요 🏆';

  @override
  String get carromMatchOppWon => '상대가 이겼어요';

  @override
  String get carromMatchOppAiming => '상대가 조준 중…';

  @override
  String get carromMatchPiecesMoving => '말이 움직이는 중…';

  @override
  String get carromMatchOppCoversQueen => '상대가 퀸을 커버하는 중 👑';

  @override
  String get carromMatchCoverQueen => '퀸을 커버하세요 👑 — 자기 말 하나를 넣으세요';

  @override
  String get carromMatchYourTurnHint => '당신 차례 — 스트라이커를 뒤로 당겨 조준한 뒤 놓으세요';

  @override
  String get carromMatchTitle => '캐롬';

  @override
  String get carromOnlineTitle => '캐롬 온라인';

  @override
  String get carromUnmute => '음소거 해제';

  @override
  String get carromMute => '음소거';

  @override
  String get carromSkins => '스킨';

  @override
  String get carromYou => '나';

  @override
  String get carromOpponent => '상대';

  @override
  String get carromFoulStriker => '파울: 스트라이커가 포켓에 들어감';

  @override
  String get carromFoulNoHit => '파울: 어떤 말도 맞히지 못함';

  @override
  String get carromFoulTimeout => '시간 종료 — 상대 차례';

  @override
  String get carromFoulTimeoutOnline => '플레이어 시간 종료 — 넘김';

  @override
  String get carromFoul => '파울';

  @override
  String get carromQaWinAsk => '이겼어요! 상대에게 질문하세요';

  @override
  String get carromQaLoseAnswer => '상대가 이겼어요 — 질문에 답하세요';

  @override
  String get carromQaQuestionHint => '상대에게 할 질문을 적으세요…';

  @override
  String get carromQaAnswerHint => '답변을 적으세요…';

  @override
  String get carromQaFetchingQuestion => '질문을 불러오는 중…';

  @override
  String get carromQaPrivate => '비공개 — 저장되지 않음';

  @override
  String get carromQaWaitingAnswer => '상대의 답변을 기다리는 중…';

  @override
  String get carromQaWaitingQuestion => '상대의 질문을 기다리는 중…';

  @override
  String get carromQaAnswerSent => '답변이 전송되었습니다 ✓';

  @override
  String get carromBubbleOppAnswer => '상대의 답변';

  @override
  String get carromBubbleOppQuestion => '상대의 질문';

  @override
  String get carromSkip => '건너뛰기';

  @override
  String get carromFinish => '완료';

  @override
  String get carromSendQuestion => '질문 보내기';

  @override
  String get carromSendAnswer => '답변 보내기';

  @override
  String get carromYouWon => '이겼어요!';

  @override
  String get carromNewMatch => '새 경기';

  @override
  String get carromNewOpponent => '새 상대';

  @override
  String get carromOppLeft => '상대가 나갔습니다';

  @override
  String get carromConnected => '연결됨';

  @override
  String get carromConnecting => '연결 중…';

  @override
  String get carromAimMoveStriker => '스트라이커를 좌우로 움직이세요';

  @override
  String get carromAimDragToAim => '스트라이커를 끌어 조준하세요';

  @override
  String get carromMmAvgWait => '평균 대기 30초 미만';

  @override
  String get carromOnlineWon => '이겼어요! 🏆';

  @override
  String get carromOnlineLost => '졌습니다';

  @override
  String get carromScoreYou => '나';

  @override
  String get carromScoreOpp => '상대';

  @override
  String get carromOpponentLeft => '상대가 나갔습니다 — 복귀 대기 중';

  @override
  String get carromConcedeAction => '기권';

  @override
  String get carromMatchOver => '경기 종료';

  @override
  String get carromTurnYouAim => '당신 차례 — 조준';

  @override
  String get carromTurnWaitOpp => '상대를 기다리는 중…';

  @override
  String get carromExitTitle => '경기를 나갈까요?';

  @override
  String get carromExitBody => '현재 라운드는 패배로 처리됩니다.';

  @override
  String get carromExitAction => '나가기';

  @override
  String get carromTitleShort => '캐롬';

  @override
  String get carromPiecesMoving => '말이 움직이는 중…';

  @override
  String get carromStatusDragHint => '스트라이커에서 끌어 파워와 각도를 설정하세요';

  @override
  String get carromNewPractice => '새 연습';

  @override
  String get carromFoulStrikerPocketed => '반칙: 스트라이커가 포켓에 들어갔습니다';

  @override
  String get carromFoulNoPieceHit => '반칙: 말을 맞히지 못했습니다';

  @override
  String get carromFoulWrongColor => '반칙: 상대 말을 먼저 맞혔습니다';

  @override
  String get carromFoulQueenUncovered => '반칙: 퀸이 커버되지 않았습니다';

  @override
  String get carromFoulGeneric => '샷 반칙';

  @override
  String get carromChatToughOne => '어렵게 만들었네';

  @override
  String get carromChatNicePlay => '멋진 플레이';

  @override
  String get carromConcedeProTitle => '경기에서 기권할까요?';

  @override
  String get carromConcedeProBody => '패배로 처리됩니다.';

  @override
  String get carromWithdraw => '기권';

  @override
  String get carromProTitle => '캐롬 프로';

  @override
  String get carromChat => '채팅';

  @override
  String get carromStatusWonMatch => '경기에서 이겼어요 🏆';

  @override
  String get carromStatusOppWon => '상대가 이겼습니다';

  @override
  String get carromStatusOppAiming => '상대가 조준 중…';

  @override
  String get carromStatusOppCoverQueen => '상대가 퀸을 커버하는 중 👑';

  @override
  String get carromStatusCoverQueen => '퀸을 커버하세요 👑 — 자기 말 하나를 넣으세요';

  @override
  String get carromStatusYourTurnDrag => '당신 차례 — 스트라이커를 끌어 조준 후 놓으세요';

  @override
  String get carromFoulStrikerPocketed2 => '반칙: 스트라이커가 포켓에 들어갔습니다';

  @override
  String get carromFoulNoPieceHit2 => '반칙: 어떤 말도 건드리지 않았습니다';

  @override
  String get ludoInviteCreateFailed => '초대를 만들 수 없습니다';

  @override
  String get ludoInvitePasteFirst => '먼저 초대 코드를 붙여넣으세요';

  @override
  String get ludoInviteJoinFailed => '초대에 참여할 수 없습니다';

  @override
  String get ludoInviteCodeTitle => '내 초대 코드';

  @override
  String get ludoInviteCodeHint => '코드는 5분간 유효합니다. 공유하여 다른 사람이 경기에 참여하게 하세요.';

  @override
  String get ludoCodeCopied => '코드가 복사되었습니다';

  @override
  String get ludoCopy => '복사';

  @override
  String get ludoEnterRoom => '방 입장';

  @override
  String get ludoBadgeNew => '신규';

  @override
  String get ludoBadge2to4 => '2-4명';

  @override
  String get ludoHeroTitle => '골든 루도';

  @override
  String get ludoHeroSubtitle => '주사위가 정하고 용기가 이긴다';

  @override
  String get ludoChooseMode => '모드 선택';

  @override
  String get ludoMoment => '잠시만요…';

  @override
  String get ludoStartMatch => '매치 시작';

  @override
  String get ludoPlayWithFriends => '친구와 플레이';

  @override
  String get ludoJoinByInvite => '초대로 참여';

  @override
  String get ludoPasteCode => '코드 붙여넣기';

  @override
  String get ludoJoin => '참여';

  @override
  String ludoEntryWinner(Object fee, Object pot) {
    return '입장 $fee — 승자가 $pot 획득';
  }

  @override
  String ludoCurrentBalance(Object points) {
    return '잔액: $points 포인트';
  }

  @override
  String get ludoCount2Players => '2명';

  @override
  String get ludoCount4Players => '4명';

  @override
  String get ludoMmSearchFailed => '상대를 찾을 수 없습니다';

  @override
  String get ludoMmSearch3 => '상대 3명 찾는 중…';

  @override
  String get ludoMmSearch1 => '상대 찾는 중…';

  @override
  String ludoMmQueuePos(Object pos) {
    return '대기열 순위: $pos';
  }

  @override
  String get ludoMmAvgWait => '평균 대기 45초 미만';

  @override
  String get ludoConcedeTitle => '기권할까요?';

  @override
  String get ludoConcedeBody => '지금 나가면 참가비를 잃고 꼴찌가 됩니다.';

  @override
  String get ludoConcedeBack => '뒤로';

  @override
  String get ludoConcede => '기권';

  @override
  String ludoErrorPrefixed(Object error) {
    return '오류: $error';
  }

  @override
  String get ludoReconnecting => '재연결 중…';

  @override
  String get ludoMoving => '이동 중…';

  @override
  String get ludoMovableHighlighted => '이동 가능한 말이 초록색으로 빛납니다';

  @override
  String get ludoDiceHint => '주사위가 발걸음을 이끕니다';

  @override
  String get ludoColorRed => '빨강';

  @override
  String get ludoColorGreen => '초록';

  @override
  String get ludoColorYellow => '노랑';

  @override
  String get ludoOpponent => '상대';

  @override
  String get ludoWinTitle => '완승!';

  @override
  String get ludoNiceMatch => '멋진 경기';

  @override
  String ludoWonPoints(Object pot) {
    return '$pot 포인트를 획득했습니다';
  }

  @override
  String ludoWinnerTakesPoints(Object pot) {
    return '승자가 $pot 포인트 획득';
  }

  @override
  String get ludoBackToLobby => '로비로 돌아가기';

  @override
  String get ludoNewMatch => '새 경기';

  @override
  String get ludoArena => '아레나';

  @override
  String get ludoRank1 => '1위';

  @override
  String get ludoRank2 => '2위';

  @override
  String get ludoRank3 => '3위';

  @override
  String get ludoRank4 => '4위';

  @override
  String ludoRankYou(Object rank) {
    return '$rank · 나';
  }

  @override
  String get ludoWaiting => '대기 중…';

  @override
  String get ludoChatLoadFailed => '메시지를 불러올 수 없습니다';

  @override
  String get ludoVariantMagic => '매직 루도';

  @override
  String get ludoVariantNormal => '클래식 루도';

  @override
  String get ludoPlayersSuffix => '명 플레이어';

  @override
  String get ludoPlayerLabel => '플레이어';

  @override
  String get ludoTurnNow => '차례';

  @override
  String get ludoFrozenShort => '빙결';

  @override
  String get ludoMatchOverTitle => '경기를 나가시겠어요?';

  @override
  String get ludoContinue => '계속';

  @override
  String get ludoLeave => '나가기';

  @override
  String get ludoMatchEnded => '경기 종료';

  @override
  String get ludoTapDiceToRoll => '주사위를 눌러 굴리기';

  @override
  String get ludoTapDiceFrozen => '주사위를 눌러 한 번 소모';

  @override
  String get ludoPowerRocket => '로켓';

  @override
  String get ludoPowerFreeze => '빙결';

  @override
  String get ludoPowerDoor => '문';

  @override
  String get ludoPowerDoors => '문';

  @override
  String get ludoPowerGate => '관문';

  @override
  String get ludoPowerTornado => '토네이도';

  @override
  String get ludoRocketRange => '+1 ~ +6';

  @override
  String get ludoFreezeThreeRolls => '3회';

  @override
  String get ludoTeleport => '순간이동';

  @override
  String get ludoRandom => '무작위';

  @override
  String get ludoEventFreezeEndedFor => '빙결 해제:';

  @override
  String get ludoEventFrozenRemaining => '빙결 — 남음';

  @override
  String get ludoEventRocketReachedHome => '홈에 도착';

  @override
  String get ludoEventRocketSteps => '전진시킴';

  @override
  String get ludoEventRocketStepsSuffix => '칸';

  @override
  String get ludoEventFreezeFor => '빙결';

  @override
  String get ludoEventFreezeForThreeRolls => '3회 동안';

  @override
  String get ludoEventDoorForward => '문을 지나 앞으로 갔어요';

  @override
  String get ludoEventDoorBack => '문이 당신을 뒤로 보냈어요';

  @override
  String get ludoEventTornadoMoved => '토네이도가 말을 예상치 못한 곳으로 옮겼어요';

  @override
  String get codexLudoTitle => '코덱스 루도';

  @override
  String get codexCarromTitle => '코덱스 캐롬';

  @override
  String get codexLudoIntro => '코덱스 루도: 주사위를 눌러 능력을 확인하세요';

  @override
  String get codexRolled => '굴림';

  @override
  String get codexRocketSteps => '코덱스 로켓: +';

  @override
  String get codexStepsSuffix => '칸';

  @override
  String get codexFreezePlayer => '플레이어 빙결';

  @override
  String get codexForThreeRolls => '세 번 동안';

  @override
  String get codexGateMovedTo => '코덱스 관문이 당신을 칸으로 이동';

  @override
  String get codexCycloneNewSpot => '사이클론: 예상치 못한 새 위치';

  @override
  String get codexReachedFinish => '결승에 도달';

  @override
  String get codexSixPlayAgain => '6: 플레이어';

  @override
  String get codexPlaysAgain => '다시 플레이';

  @override
  String get codexFrozenShort => '빙결';

  @override
  String get codexFrozenRemaining => '남음';

  @override
  String get codexIceShort => '얼음';

  @override
  String get codexRollShort => '굴리기';

  @override
  String get codexCarromIntro2 => '코덱스 캐롬: 끌어 쏘세요';

  @override
  String get codexHitSuccess => '멋진 샷: +1';

  @override
  String get codexMissPocket => '코인이 안 들어갔어요, 각도를 조정하세요';

  @override
  String get codexMissCoin => '코인을 건드리지 못했어요';

  @override
  String get codexBoardCleared => '보드를 정리했어요, 점수';

  @override
  String get codexResetTable => '보드 초기화';

  @override
  String get carromCosmeticsLoadFailed => '디자인을 불러올 수 없습니다';

  @override
  String get carromConcedeBodyPlain => '지금 기권하면 상대가 승리합니다. 되돌릴 수 없습니다.';

  @override
  String get hubCarromTitle => '캐롬 프로';

  @override
  String get hubCarromSubtitle => '사실적인 물리와 똑똑한 상대 — 조준, 타격, 포켓';

  @override
  String get hubCarromTag => '프로 ✦';

  @override
  String get hubChooseMode => '게임 모드 선택';

  @override
  String get hubModeAi => '컴퓨터와 대전';

  @override
  String get hubModeAiSub => '지금 기기에서 똑똑한 상대와 플레이';

  @override
  String get hubModeOnline => '온라인';

  @override
  String get hubModeOnlineSub => '실제 플레이어에게 도전 — 승자가 질문';

  @override
  String get navGames => '플레이';
}
