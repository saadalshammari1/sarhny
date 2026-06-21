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
  String get ludoYourTurn => '당신 차례 — 주사위를 굴리세요';

  @override
  String ludoBotTurn(Object name) {
    return '$name 플레이 중…';
  }

  @override
  String get ludoRollDice => '주사위 굴리기';

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
  String get ludoNewGame => '새 게임';

  @override
  String get ludoNoMove => '이동 불가';

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
}
