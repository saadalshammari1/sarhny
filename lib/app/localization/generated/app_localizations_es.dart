// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Sarhny';

  @override
  String get tagline => 'Expresión auténtica de uno mismo';

  @override
  String get splashLoading => 'Cargando...';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginEmailOrUsername => 'Usuario o correo';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginForgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get loginSignUp => 'Registrarse';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerName => 'Nombre';

  @override
  String get registerUsername => 'Usuario';

  @override
  String get registerEmail => 'Correo';

  @override
  String get registerPassword => 'Contraseña';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerHasAccount => '¿Ya tienes cuenta?';

  @override
  String get registerSignIn => 'Iniciar sesión';

  @override
  String get navHome => 'Inicio';

  @override
  String get navInbox => 'Bandeja';

  @override
  String get navCompose => 'Publicar';

  @override
  String get navMirrors => 'Espejos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get feedGlobalTab => 'Global';

  @override
  String get feedFollowingTab => 'Siguiendo';

  @override
  String get feedSectionAll => 'Todo';

  @override
  String get feedSectionMoment => 'Momentos';

  @override
  String get feedSectionFace => 'Rostros';

  @override
  String get feedSectionMind => 'Mentes';

  @override
  String get postCrystalBadge => 'Cristal';

  @override
  String get postLayersHint => 'Leer';

  @override
  String get postGravityApproaching => 'se acerca a la cristalización';

  @override
  String get postGravityFading => 'desvaneciéndose';

  @override
  String get composeChooseSection => 'Elige una sección';

  @override
  String get composeMoment => 'Momento';

  @override
  String get composeFace => 'Rostro';

  @override
  String get composeMind => 'Mente';

  @override
  String get composeLayer1 => 'Texto principal';

  @override
  String get composeLayer2 => 'Añadir imagen (opcional)';

  @override
  String get composeLayer3 => 'Escribir un artículo más profundo (opcional)';

  @override
  String get composeCrystallizeHint =>
      'Empieza con 24 h de vida — cristaliza si resuena';

  @override
  String get composePublish => 'Publicar';

  @override
  String get profileEdit => 'Editar';

  @override
  String get profileFollow => 'Seguir';

  @override
  String get profileFollowing => 'Siguiendo';

  @override
  String get profileBlock => 'Bloquear';

  @override
  String get profileFollowers => 'Seguidores';

  @override
  String get profileCrystals => 'Cristales';

  @override
  String get profileReplies => 'Respuestas';

  @override
  String get profileTabCrystals => 'Cristales';

  @override
  String get profileTabActive => 'Activos';

  @override
  String get profileTabMirrors => 'Espejos';

  @override
  String get profileTabLikes => 'Me gusta';

  @override
  String get inboxTitle => 'Mensajes anónimos';

  @override
  String get inboxEmpty => 'Aún no hay mensajes';

  @override
  String get inboxReplyPublic => 'Responder en público';

  @override
  String get inboxIgnore => 'Ignorar';

  @override
  String get inboxReport => 'Reportar';

  @override
  String get inboxDelete => 'Eliminar';

  @override
  String get mirrorsTitle => 'Espejos';

  @override
  String get mirrorsCreate => 'Crear nuevo espejo';

  @override
  String get mirrorsShare => 'Compartir enlace';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsAnonymous => 'Mensajes anónimos';

  @override
  String get settingsSubscription => 'Suscripción';

  @override
  String get settingsHelp => 'Ayuda';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonReport => 'Reportar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonError => 'Algo salió mal';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonEmpty => 'Sin contenido';

  @override
  String get gamesHubTitle => 'Juegos';

  @override
  String get carromTitle => 'Carrom 1v1';

  @override
  String get carromSubtitle =>
      'Desafía a un oponente anónimo — gana sus puntos';

  @override
  String get carromLobbyPlayRandom => 'Empezar partida aleatoria';

  @override
  String get carromLobbyPlayRandomSub =>
      'Encuentra un oponente disponible ahora';

  @override
  String get carromLobbyInvite => 'Juega con un amigo';

  @override
  String get carromLobbyInviteSub => 'Genera un código de invitación';

  @override
  String get carromLobbyJoinByCode => 'Unirse con código';

  @override
  String get carromLobbyJoinHint => 'Pega el código';

  @override
  String get carromLobbyJoinAction => 'Unirse';

  @override
  String carromLobbyEntryFee(Object entry, Object pot) {
    return 'Entrada $entry — el ganador se lleva $pot';
  }

  @override
  String get carromMmSearching => 'Buscando oponente...';

  @override
  String get carromMmCancel => 'Cancelar búsqueda';

  @override
  String carromMmQueue(Object pos) {
    return 'Tu posición en la cola: $pos';
  }

  @override
  String get carromMatchYourTurn => 'Tu turno';

  @override
  String get carromMatchOppTurn => 'Turno del oponente';

  @override
  String get carromMatchConcede => 'Rendirse';

  @override
  String get carromMatchConcedeConfirm =>
      'Si te rindes ahora, tu oponente se lleva todo.';

  @override
  String get carromMatchReconnect => 'Reconectando al servidor...';

  @override
  String get carromOpponentUnknown => 'Oponente anónimo';

  @override
  String get carromOpponentTurnNow => 'Su turno';

  @override
  String get carromOpponentWaiting => 'Esperando turno';

  @override
  String get carromAimHint => 'Arrastra la pieza hacia adentro para apuntar';

  @override
  String get carromGameOverWon => '¡Has ganado!';

  @override
  String get carromGameOverLost => 'Mejor suerte la próxima';

  @override
  String get carromGameOverReveal => 'Revelar tu identidad';

  @override
  String get carromGameOverHide => 'Permanecer anónimo';

  @override
  String get carromGameOverSarhny => 'Enviar un mensaje Sarhny';

  @override
  String get carromGameOverRematch => 'Nueva partida';

  @override
  String get carromGameOverLobby => 'Lobby';

  @override
  String get carromWalletEarn1 => 'Cada mensaje Sarhny que recibas';

  @override
  String get carromWalletEarn2 => 'Ver un anuncio corto';

  @override
  String get carromWalletEarn3 => 'Ganar una partida de Carrom';

  @override
  String get carromCosmeticsTitle => 'Personaliza tu juego';

  @override
  String get carromCosmeticsTabBoard => 'Tablero';

  @override
  String get carromCosmeticsTabPieces => 'Fichas';

  @override
  String get carromCosmeticsTabStriker => 'Striker';

  @override
  String get carromCosmeticsLockedHint =>
      'Gana puntos para desbloquear este aspecto';

  @override
  String carromCosmeticsSaved(Object name) {
    return '$name seleccionado';
  }

  @override
  String get carromCosmeticsSaveFailed =>
      'No se pudo guardar, intenta de nuevo';

  @override
  String get carromLobbyCustomize => 'Personaliza tu juego';

  @override
  String get carromLobbyCustomizeSub =>
      'Elige tablero, colores de fichas y striker';

  @override
  String get actionPlay => 'Jugar';

  @override
  String get actionPlayAgain => 'Jugar de nuevo';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get actionLockIn => 'Confirmar jugada';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get actionBack => 'Volver';

  @override
  String get actionLeave => 'Salir';

  @override
  String get actionLeaveLobby => 'Volver al lobby';

  @override
  String get actionJoin => 'Unirse';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionDone => 'Listo';

  @override
  String get labelLobby => 'Lobby';

  @override
  String get labelGamesHome => 'Arena';

  @override
  String get labelOpponent => 'Oponente';

  @override
  String get labelYou => 'Tú';

  @override
  String get labelMe => 'Yo';

  @override
  String get labelAi => 'IA';

  @override
  String get labelVs => 'VS';

  @override
  String get labelTurnYours => 'Tu turno';

  @override
  String get labelTurnTheirs => 'Turno del oponente';

  @override
  String get labelTurnAi => 'La IA está pensando…';

  @override
  String labelRound(Object n) {
    return 'Ronda $n';
  }

  @override
  String get labelWaiting => 'Esperando…';

  @override
  String get labelWaitingOpponent => 'Esperando al oponente…';

  @override
  String get labelSearching => 'Buscando oponente…';

  @override
  String get outcomeYouWon => '¡Has ganado!';

  @override
  String get outcomeYouLost => 'Has perdido';

  @override
  String get outcomeDraw => 'Empate';

  @override
  String get outcomeAiWins => 'La IA gana';

  @override
  String get moodLight => 'Ligero';

  @override
  String get moodBold => 'Atrevido';

  @override
  String get moodFunny => 'Divertido';

  @override
  String get moodChoose => 'Elige el ambiente';

  @override
  String get lobbyVsRandom => 'Oponente aleatorio';

  @override
  String get lobbyVsAi => 'Contra la IA';

  @override
  String get lobbyVsAiSub => 'Práctica instantánea — la IA pregunta si gana';

  @override
  String get lobbyInviteFriend => 'Juega con un amigo';

  @override
  String get lobbyInviteFriendSub => 'Genera un código de invitación';

  @override
  String get lobbyJoinByCode => 'Unirse con código';

  @override
  String get lobbyPasteCode => 'Pega el código';

  @override
  String get questionAsk => 'Haz tu pregunta';

  @override
  String get questionAnswer => 'Responde con honestidad';

  @override
  String get questionWaitingQ => 'Esperando la pregunta del oponente…';

  @override
  String get questionWaitingA => 'Esperando la respuesta del oponente…';

  @override
  String get questionSkipNew => 'Otra pregunta';

  @override
  String get questionAbstainAd => 'Abstenerse · ver anuncio (+1 punto)';

  @override
  String get questionAbstainNote =>
      'Abstenerse termina el partido sin respuesta y suma un punto.';

  @override
  String get adLoading => 'Cargando anuncio…';

  @override
  String get adIncomplete => 'Anuncio no completado';

  @override
  String get adUnavailable => 'Ningún anuncio disponible';

  @override
  String get adDailyCap => 'Límite diario alcanzado';

  @override
  String get adRewardEarned => 'Ganaste un punto.';

  @override
  String get rpsRock => 'Piedra';

  @override
  String get rpsPaper => 'Papel';

  @override
  String get rpsScissors => 'Tijera';

  @override
  String get rpsChooseHand => 'Elige tu mano';

  @override
  String get rpsGuessHand => 'Adivina la mano del oponente';

  @override
  String get rpsAiQuestionLabel => 'Pregunta de la IA';

  @override
  String get rpsMyQuestionLabel => 'Tu pregunta para la IA';

  @override
  String get rpsAnswerPrivate =>
      'Tu respuesta es solo tuya — no se guarda ni se envía.';

  @override
  String get xoCellFilled => 'Casilla ocupada — elige otra';

  @override
  String get xoNotYourTurn => 'Aún no es tu turno';

  @override
  String get xoPracticeTitle => 'XO — Práctica';

  @override
  String get leaveTitle => '¿Salir del partido?';

  @override
  String get leaveBody => 'Tu ronda contará como derrota.';

  @override
  String get rematchTitle => '¿Revancha?';

  @override
  String get rematchAccept => 'Jugar de nuevo';

  @override
  String get rematchDecline => 'Terminé';

  @override
  String get rematchWaiting => 'Esperando respuesta del oponente…';

  @override
  String get rematchDeclined => 'El oponente rechazó la revancha';

  @override
  String get rematchTimeout => 'Tiempo de revancha agotado';

  @override
  String get hubGameRps => 'Duelo';

  @override
  String get hubGameRpsSub => 'Piedra · Papel · Tijera — el ganador pregunta';

  @override
  String get hubGameXo => 'Tres en raya';

  @override
  String get hubGameXoSub => 'Tres en línea — el ganador pregunta';

  @override
  String get hubAdEarnTitle => 'Mira un anuncio corto';

  @override
  String get hubAdEarnSub =>
      'Límite diario 10 — puntos a tu cartera al instante.';

  @override
  String get hubAdPointBadge => '+1 punto';

  @override
  String get hubTagAdNew => 'Nuevo';

  @override
  String get hubTagOnline => 'En línea';

  @override
  String get hubSectionPlay => 'Jugar ahora';

  @override
  String get hubSectionEarn => 'Gana puntos sin jugar';

  @override
  String get hubAbstainHint =>
      'También puedes abstenerte durante el juego viendo un anuncio.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageAuto => 'Automático (idioma del dispositivo)';

  @override
  String get settingsEmail => 'Correo electrónico';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsAnonymousReceive => 'Recibir mensajes anónimos';

  @override
  String get settingsVoiceReceive => 'Recibir mensajes de voz';

  @override
  String get settingsImageReceive => 'Recibir imágenes';

  @override
  String get settingsRegisteredOnly => 'Solo de usuarios registrados';

  @override
  String get settingsBlockedAccounts => 'Cuentas bloqueadas';

  @override
  String get settingsLikes => 'Me gusta';

  @override
  String get settingsComments => 'Comentarios';

  @override
  String get settingsFollowers => 'Nuevos seguidores';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsHelpCenter => 'Centro de ayuda';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsContentPolicy => 'Política de contenido';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsUpdated => 'Actualizado';

  @override
  String get settingsUpdateFailed => 'No se pudo actualizar';

  @override
  String get settingsPasswordShort => 'La nueva contraseña es demasiado corta';

  @override
  String get settingsPasswordCurrent => 'Contraseña actual';

  @override
  String get settingsPasswordNew => 'Nueva contraseña';

  @override
  String get settingsDeleteConfirmTitle => 'Eliminar la cuenta permanentemente';

  @override
  String get settingsDeleteConfirmBody =>
      'Esta acción no se puede deshacer — todos tus datos se borrarán.';

  @override
  String get settingsDeleteConfirmField => 'Confirma tu contraseña';

  @override
  String get settingsDeleteAction => 'Eliminar';

  @override
  String get settingsDeleteFailed => 'No se pudo eliminar';

  @override
  String get settingsThemeAuto => 'Automático';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get errorMatchLoad => 'No se pudo cargar la partida';

  @override
  String get errorGameStart => 'No se pudo iniciar el juego';

  @override
  String get errorAdLaunch => 'No se pudo reproducir el anuncio';

  @override
  String get errorClipboardCopied => 'Copiado';

  @override
  String get roundWon => 'Ganaste esta ronda';

  @override
  String get roundLost => 'El rival ganó esta ronda';

  @override
  String get roundDraw => 'Sin ganador en esta ronda';

  @override
  String get gameOverTitle => 'Partida terminada';

  @override
  String get revealingSoon => 'Revelando ahora…';

  @override
  String get nextRoundSoon => 'La siguiente ronda comienza…';

  @override
  String get leaveStay => 'Quedarse';

  @override
  String get answerWriteHint => 'Escribe tu respuesta con sinceridad';

  @override
  String get questionWriteHint => 'Escribe tu pregunta con sinceridad';

  @override
  String get continueMatch => 'Continuar';

  @override
  String get xoPageTitle => 'Desafío Tres en Raya';

  @override
  String xoMovesProgress(Object moves, Object total) {
    return 'Movimiento $moves/$total';
  }

  @override
  String get questionUsePresetCta => 'O usa una pregunta predefinida';

  @override
  String get questionSkipUsed => 'Cambio usado';

  @override
  String questionYoursPrefix(Object q) {
    return 'Tu pregunta: $q';
  }

  @override
  String get xoLocalDrawSub => 'Partida reñida.';

  @override
  String get xoLocalWinSub => 'Tres en raya — muy bien.';

  @override
  String get xoLocalLoseSub => 'Inténtalo otra vez.';

  @override
  String get lobbyStartMatchSection => 'Empezar una partida';

  @override
  String get lobbyVsRandomSub => 'Encuentra un rival en línea';

  @override
  String get xoLobbyHeroDescription =>
      'Adelántate a tu rival con tres en raya.\nEl ganador pregunta. El perdedor responde.';

  @override
  String get gamePageTitle => 'Desafío 🎮';

  @override
  String get gameLobbyRandomSub =>
      '5 rondas de piedra-papel-tijera + adivinanza • el primero en llegar a 5 puntos gana';

  @override
  String get gameRulesTitle => 'Reglas rápidas';

  @override
  String get gameRule1 => 'Elige una mano y adivina la del rival';

  @override
  String get gameRule2 =>
      'Ronda ganada = 1 punto. Adivinanza correcta = 1 punto';

  @override
  String get gameRule3 => 'Gana el primero en llegar a 5 puntos';

  @override
  String get gameRule4 =>
      'El ganador escribe una pregunta para el perdedor (25 segundos)';

  @override
  String get gameRule5 => 'Respuestas o preguntas ofensivas → ronda anulada';

  @override
  String get gameUnusualEndSub => 'La ronda terminó de forma inesperada.';

  @override
  String get gameAnonymityTagline =>
      'No reveles tu identidad. Tampoco la de tu rival.';

  @override
  String secondsRemaining(Object n) {
    return '${n}s restantes';
  }

  @override
  String secondsToAnswer(Object n) {
    return '${n}s para responder';
  }

  @override
  String secondsShort(Object n) {
    return '${n}s';
  }

  @override
  String get questionAutoFallbackPrefix =>
      'Pregunta automática si no escribes:';

  @override
  String get questionFromOpponent => 'Pregunta de tu rival';

  @override
  String get questionAppearingSoon =>
      'La pregunta aparecerá enseguida. Espera.';

  @override
  String get questionSent =>
      'Pregunta enviada — su respuesta llega en un momento.';

  @override
  String get rpsPracticeTitle => 'Desafío — Práctica';

  @override
  String get rpsLocalAskHint =>
      'Haz una pregunta sincera... (solo por diversión)';

  @override
  String get rpsLocalAiPreparing => 'Preparando una pregunta...';

  @override
  String get rpsLocalAnswerHint => 'Respóndete a ti mismo...';

  @override
  String get ludoPowerTitle => 'Parchís Poderes';

  @override
  String get ludoPowerSubtitle =>
      'Parchís de 4 jugadores con superpoderes — Cohete, Congelar, Portal, Tornado. Los poderes se reorganizan cada 3 tiradas.';

  @override
  String get ludoLobbyChooseMode => 'Elige modo';

  @override
  String get ludoMode2Players => 'Dos jugadores (1v1)';

  @override
  String get ludoMode2PlayersSub => 'Tú vs. un bot — más rápido, más intenso';

  @override
  String get ludoMode4Players => 'Cuatro jugadores';

  @override
  String get ludoMode4PlayersSub => 'Tú vs. 3 bots — la experiencia completa';

  @override
  String get ludoStartTap => 'Toca el dado para empezar';

  @override
  String get ludoTapPawn => 'Elige una ficha para mover';

  @override
  String get ludoExtraTurn => '¡Turno extra! Tira de nuevo';

  @override
  String get ludoYourTurn => 'Your turn';

  @override
  String ludoBotTurn(Object name) {
    return '$name está jugando…';
  }

  @override
  String get ludoRollDice => 'Roll dice';

  @override
  String ludoTurnLabel(Object name) {
    return 'Turno de $name';
  }

  @override
  String get ludoYouWin => '🎉 ¡Ganaste!';

  @override
  String ludoBotWin(Object name) {
    return '$name ganó';
  }

  @override
  String get ludoYouWinSub => 'Tus cuatro fichas llegaron al centro';

  @override
  String get ludoLossSub => 'Más suerte en la próxima ronda';

  @override
  String get ludoNewGame => 'New game';

  @override
  String get ludoNoMove => 'No move';

  @override
  String get ludoPlayerGold => 'Dorado';

  @override
  String get ludoPlayerBlue => 'Azul';

  @override
  String get ludoPlayerPurple => 'Morado';

  @override
  String get ludoPlayerGreen => 'Verde';

  @override
  String ludoEventRocket(Object boost) {
    return '¡Cohete! +$boost';
  }

  @override
  String get ludoEventFreeze => '¡Congelado!';

  @override
  String ludoEventPortalForward(Object diff) {
    return '¡Portal! +$diff';
  }

  @override
  String ludoEventPortalBack(Object diff) {
    return '¡Portal! -$diff';
  }

  @override
  String get ludoEventTornado => '¡Tornado!';

  @override
  String get ludoEventCapture => '¡Capturado!';

  @override
  String get ludoEventShuffle => 'Poderes reorganizados';

  @override
  String get hubGameLudoPower => 'Parchís Poderes';

  @override
  String get hubGameLudoPowerSub =>
      'Parchís de 4 jugadores con superpoderes — destacado';

  @override
  String get hubTagFeatured => 'Destacado';

  @override
  String get ludoPlayerYou => 'Tú';

  @override
  String ludoOpponentN(Object n) {
    return 'Rival $n';
  }

  @override
  String get ludoBotThinking => 'Pensando…';

  @override
  String get ludoMmTitle => 'Buscando rivales';

  @override
  String get ludoMmSearching => 'Buscando jugadores…';

  @override
  String get ludoMmRealPlayers => 'Buscando jugadores reales';

  @override
  String ludoMmCountdownHint(Object seconds) {
    return 'Completaremos con bots en $seconds s si no aparece nadie';
  }

  @override
  String get ludoMmFilledByBots => 'Completado con bots expertos';

  @override
  String get ludoMmMatchFound => '¡Partida encontrada!';

  @override
  String get ludoMmCancel => 'Cancelar búsqueda';

  @override
  String get ludoMmStarting => 'Comenzando partida…';

  @override
  String ludoMmFoundCount(Object found, Object total) {
    return '$found/$total jugadores';
  }

  @override
  String get ludoMode1v1 => 'Rival 1v1';

  @override
  String get ludoMode1v1Sub => 'Partida rápida, identidad anónima';

  @override
  String get ludoMode4Party => 'Partida de 4 jugadores';

  @override
  String get ludoMode4PartySub =>
      'Busca 3 rivales • los bots cubren los huecos';

  @override
  String get ludoLobbyHowToPlay => 'Cómo jugar';

  @override
  String get ludoRule1 =>
      'Tira el dado, sal de casa con un seis, lleva las 4 fichas al centro';

  @override
  String get ludoRule2 => '4 superpoderes en el camino: 🚀 ❄ 🌀 🌪';

  @override
  String get ludoRule3 => 'Capturar a un rival otorga un turno extra';

  @override
  String get ludoRule4 =>
      'Las estrellas son casillas seguras • los poderes se reordenan cada 3 tiradas';

  @override
  String get rpsGuessExplain =>
      'Adivina la elección de tu rival — si aciertas, ¡punto extra además del punto de la ronda!';

  @override
  String get rateEnjoyTitle => '¿Te gusta Sarhny?';

  @override
  String get rateEnjoyBody => 'Tu valoración ayuda a Sarhny a crecer 💜';

  @override
  String get rateLove => 'Me encanta 😍';

  @override
  String get rateMeh => 'Podría mejorar';

  @override
  String get rateLater => 'Más tarde';

  @override
  String get rateFeedbackTitle => '¿Cómo podemos mejorar?';

  @override
  String get rateFeedbackHint => 'Escribe tu comentario…';

  @override
  String get rateSend => 'Enviar';

  @override
  String get rateThanks => '¡Gracias por tu comentario! 💜';

  @override
  String get fieldRequired => 'Campo obligatorio';

  @override
  String get errorInvalidCredentials => 'Datos de acceso incorrectos';

  @override
  String get errorServerUnreachable => 'No se pudo conectar al servidor';

  @override
  String get errorConnectionLost => 'Conexión perdida';

  @override
  String get errorUnexpected => 'Algo salió mal';

  @override
  String get loginUsernameHint => 'p. ej.: ssarhny';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar en Sarhny';

  @override
  String get registerAgeConfirmError =>
      'Debes confirmar que tienes 18 años o más';

  @override
  String get registerTermsError => 'Debes aceptar los términos';

  @override
  String get registerUsernameTaken => 'El nombre de usuario ya está en uso';

  @override
  String get registerUsernameFormat =>
      'Solo letras latinas, números y guiones bajos';

  @override
  String get registerUsernameInvalid => 'Nombre de usuario no válido';

  @override
  String get registerEmailTaken => 'El correo ya está en uso';

  @override
  String get registerEmailInvalid => 'Correo no válido';

  @override
  String get registerPasswordWeak => 'La contraseña es muy corta o no coincide';

  @override
  String get registerSexRequired => 'Selecciona tu género';

  @override
  String get registerUsernameMin => 'Al menos 3 caracteres';

  @override
  String get registerUsernameReserved => 'Nombre reservado';

  @override
  String get registerEmailInvalidShort => 'Correo no válido';

  @override
  String get registerPasswordMin => 'Al menos 8 caracteres';

  @override
  String get registerPasswordMismatch => 'No coincide con la contraseña';

  @override
  String get registerJoinTitle => 'Únete a Sarhny';

  @override
  String get registerJoinSubtitle =>
      'Un espacio para la autoexpresión auténtica — solo adultos';

  @override
  String get registerDisplayName => 'Nombre visible';

  @override
  String get registerNameMin => 'Al menos 2 caracteres';

  @override
  String get registerUsernameHint => 'p. ej. amal_x';

  @override
  String get registerPasswordConfirm => 'Confirmar contraseña';

  @override
  String get registerAgeConfirm => 'Confirmo que tengo 18 años o más';

  @override
  String get registerAdultsOnly => 'Sarhny es solo para adultos';

  @override
  String get registerAgreeTerms =>
      'Acepto los Términos de uso y la Política de privacidad';

  @override
  String get registerHaveAccount => '¿Tienes una cuenta?';

  @override
  String get registerSignInCta => 'Inicia sesión';

  @override
  String get registerGender => 'Género';

  @override
  String get registerGenderMale => 'Hombre';

  @override
  String get registerGenderFemale => 'Mujer';

  @override
  String get forgotTitle => 'Recuperar contraseña';

  @override
  String get forgotInstructions =>
      'Introduce tu correo registrado y te enviaremos un enlace para restablecer tu contraseña en una hora.';

  @override
  String get forgotSendLink => 'Enviar enlace';

  @override
  String get forgotBackToLogin => 'Volver a iniciar sesión';

  @override
  String get forgotCheckEmailTitle => 'Revisa tu correo';

  @override
  String get forgotEmailSentBody =>
      'Si este correo está registrado, hemos enviado un enlace de recuperación a';

  @override
  String get forgotCheckSpamHint =>
      'Revisa tu bandeja de entrada (y a veces la carpeta de spam)';

  @override
  String get resetLinkExpired => 'El enlace ha expirado o no es válido';

  @override
  String get resetTitle => 'Establecer una nueva contraseña';

  @override
  String get resetHeading => 'Nueva contraseña';

  @override
  String get resetSubtitle =>
      'Elige una contraseña nueva y segura para tu cuenta.';

  @override
  String get resetPasswordMismatch => 'No coincide';

  @override
  String get resetDoneTitle => 'Contraseña actualizada';

  @override
  String get resetDoneBody =>
      'Ahora puedes iniciar sesión con tu nueva contraseña.';

  @override
  String get resetGoToLogin => 'Iniciar sesión';

  @override
  String get diagnosticsTitle => 'Diagnóstico de conexión';

  @override
  String get diagnosticsEnvStatus => 'Estado de .env';

  @override
  String get diagnosticsConnectionStatus => 'Estado de la conexión';

  @override
  String get diagnosticsHint =>
      'Toca \"Probar conexión\" para ver qué ocurre al conectarte al servidor.';

  @override
  String get diagnosticsTestButton => 'Probar conexión';

  @override
  String get feedSearchTooltip => 'Buscar';

  @override
  String get feedEmptyFollowingTitle => 'Aún no hay publicaciones';

  @override
  String get feedEmptySectionTitle => 'Nada en esta sección';

  @override
  String get feedEmptyFollowingSubtitle =>
      'Sigue a personas para ver sus publicaciones';

  @override
  String get feedEmptySectionSubtitle => 'Sé el primero en publicar algo ⚡';

  @override
  String get feedScopeFollowing => 'Siguiendo';

  @override
  String get feedScopeGlobal => 'Global';

  @override
  String get feedCrystalBadge => '✦ Cristal';

  @override
  String get feedQuestionFromAnonymous => 'Pregunta de un anónimo';

  @override
  String get feedQuestionFrom => 'Pregunta de';

  @override
  String get feedUnsave => 'Quitar de guardados';

  @override
  String get feedSave => 'Guardar';

  @override
  String get feedShareFooter => '— de Sarhny';

  @override
  String get feedDeleteTitle => 'Eliminar publicación';

  @override
  String get feedDeleteBody =>
      'Tu publicación se eliminará permanentemente y ya no será visible para los demás. ¿Estás seguro?';

  @override
  String get feedDeleteSuccess => 'Publicación eliminada';

  @override
  String get feedDeleteFailed => 'No se pudo eliminar';

  @override
  String get feedTimeNow => 'ahora';

  @override
  String get feedTimeAgo => 'hace';

  @override
  String feedTimeMinutes(Object n) {
    return 'hace $n min';
  }

  @override
  String feedTimeHours(Object n) {
    return 'hace $n h';
  }

  @override
  String feedTimeDays(Object n) {
    return 'hace $n d';
  }

  @override
  String feedTimeSeconds(Object n) {
    return 'hace $n s';
  }

  @override
  String feedTimeWeeks(Object n) {
    return 'hace $n sem';
  }

  @override
  String feedTimeMonths(Object n) {
    return 'hace $n meses';
  }

  @override
  String feedTimeYears(Object n) {
    return 'hace $n años';
  }

  @override
  String get sectionAll => 'Todo';

  @override
  String get sectionMoments => 'Momentos';

  @override
  String get sectionFaces => 'Rostros';

  @override
  String get sectionMinds => 'Mentes';

  @override
  String get sectionAnswers => 'Respuestas';

  @override
  String get ludoTitle => 'Parchís';

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
  String get ludoColorBlue => 'Azul';

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
  String get inboxAppBarTitle => 'Bandeja de entrada';

  @override
  String get inboxEmptyTitle => 'La bandeja de entrada está vacía';

  @override
  String get inboxEmptySubtitle => 'Los mensajes anónimos aparecerán aquí';

  @override
  String get inboxMarkedRead => 'Marcado como leído';

  @override
  String get inboxUpdateFailed => 'No se pudo actualizar';

  @override
  String get inboxDeleted => 'Eliminado';

  @override
  String get inboxDeleteFailed => 'No se pudo eliminar';

  @override
  String get inboxReported => 'Reportado — lo revisaremos';

  @override
  String get inboxReportFailed => 'No se pudo reportar';

  @override
  String get inboxAnonymous => 'Anónimo';

  @override
  String get inboxReplyWithPost => 'Responder con una publicación';

  @override
  String get inboxAnswered => 'Respondido';

  @override
  String get inboxReportTooltip => 'Reportar';

  @override
  String get inboxAnswerEmptyError => 'Escribe tu respuesta primero';

  @override
  String get inboxReplyPublished => 'Respuesta publicada ✨';

  @override
  String get inboxSessionExpired => 'Inicia sesión de nuevo';

  @override
  String get inboxRateLimited =>
      'Más despacio, inténtalo de nuevo en un minuto';

  @override
  String get inboxConnectionFailed => 'Conexión fallida —';

  @override
  String get inboxYourReplyLabel =>
      'Tu respuesta (se publicará como una publicación 🎨)';

  @override
  String get inboxReplyHint => 'Escribe tu respuesta…';

  @override
  String get inboxHideLayer3 => 'Ocultar capa 3';

  @override
  String get inboxAddLayer3 => 'Añadir capa 3 — reflexión';

  @override
  String get inboxLayer3Hint => 'Tu reflexión (opcional)';

  @override
  String get inboxPublishReply => 'Publicar respuesta';

  @override
  String get mirrorsNewMirror => 'Nuevo espejo';

  @override
  String get mirrorsEmptyTitle => 'Aún no hay espejos';

  @override
  String get mirrorsEmptySubtitle =>
      'Empieza a publicar espejos — haz una pregunta y deja que la gente responda con sinceridad';

  @override
  String get mirrorsBadge => '🪞 Espejo';

  @override
  String get mirrorsResponsesSuffix => 'respuestas';

  @override
  String get mirrorsCopyLink => 'Copiar enlace';

  @override
  String get mirrorsShareMessage =>
      'Comparte conmigo tu respuesta a este espejo:';

  @override
  String get mirrorsShareSubject => 'Sarhny — Espejo';

  @override
  String get mirrorsShareFailed => 'No se pudo abrir el menú de compartir';

  @override
  String get mirrorsQuestionLabel => 'Pregunta del espejo';

  @override
  String get mirrorsCreateHint =>
      'Una pregunta orientadora para el autoconocimiento — las respuestas son anónimas y forman una nube de palabras.';

  @override
  String get mirrorsQuestionHint =>
      'p. ej.: ¿Qué te hace sentir orgulloso de ti mismo?';

  @override
  String get mirrorsCreateButton => 'Crear espejo';

  @override
  String get mirrorsCreated => 'Espejo creado';

  @override
  String get mirrorsCreateFailed => 'No se pudo crear';

  @override
  String get mirrorsLoginToRespond => 'Inicia sesión para responder al espejo';

  @override
  String get mirrorsRateLimit =>
      'Has respondido mucho últimamente — espera un momento';

  @override
  String get mirrorsSendFailed => 'No se pudo enviar';

  @override
  String get mirrorsBadgeShort => 'Espejo';

  @override
  String get mirrorsQuestionTitle => 'La pregunta';

  @override
  String get mirrorsResponseHint =>
      'Escribe tu respuesta sincera — tu identidad no se mostrará';

  @override
  String get mirrorsAnonymousNote =>
      'Puedes responder sin iniciar sesión — tu identidad nunca se mostrará';

  @override
  String get mirrorsSendResponse => 'Enviar mi respuesta';

  @override
  String get mirrorsFrom => 'Espejo de';

  @override
  String get mirrorsSentTitle => 'Tu respuesta fue enviada';

  @override
  String get mirrorsSentBody =>
      'Tus palabras se sumarán a la nube de palabras que ve el dueño del espejo. Gracias por tu sinceridad 🌙';

  @override
  String get mirrorsBackHome => 'Volver al inicio';

  @override
  String get postTitle => 'Publicación';

  @override
  String get postReplyHint => 'Escribe tu respuesta…';

  @override
  String get postMicPermission => 'Se requiere permiso del micrófono';

  @override
  String get postRecordStartFailed => 'No se pudo iniciar la grabación';

  @override
  String get postImagePickFailed => 'No se pudo elegir la imagen';

  @override
  String get postSlowDownRetry => 'Espera un momento e inténtalo de nuevo';

  @override
  String get postSendFailed => 'No se pudo enviar';

  @override
  String get postTooltipImage => 'Imagen';

  @override
  String get postTooltipVoice => 'Grabación de voz';

  @override
  String get postVoiceRecording => 'Grabación de voz';

  @override
  String get postSecondsShort => 's';

  @override
  String get postReplySent => 'Enviado 🌙';

  @override
  String get postLoginToReply => 'Inicia sesión para responder';

  @override
  String get postSlowDownBeforeSend => 'Espera un momento antes de enviar';

  @override
  String get postRepliesTitle => 'Respuestas';

  @override
  String get postRepliesLoadFailed => 'No se pudieron cargar las respuestas';

  @override
  String get postRepliesEmpty =>
      'Aún no hay respuestas. Sé el primero en iniciar una conversación 🌙';

  @override
  String get postLoadMore => 'Cargar más';

  @override
  String get postAnonymous => 'Anónimo';

  @override
  String get postWithName => 'Con mi nombre';

  @override
  String get postDeleteReplyTitle => 'Eliminar respuesta';

  @override
  String get postDeleteReplyConfirmMine =>
      'Tu respuesta desaparecerá. ¿Estás seguro?';

  @override
  String get postDeleteReplyConfirmOther =>
      'Esta respuesta desaparecerá de tu publicación.';

  @override
  String get postDeleted => 'Eliminado';

  @override
  String get postDeleteFailed => 'No se pudo eliminar';

  @override
  String get postDeleteCommentTitle => 'Eliminar comentario';

  @override
  String get postDeleteCommentConfirm =>
      'Este comentario se eliminará permanentemente. ¿Continuar?';

  @override
  String get postPublished => 'Publicado';

  @override
  String get postLoginToComment => 'Inicia sesión para comentar';

  @override
  String get postPublishFailed => 'No se pudo publicar';

  @override
  String get postCommentsTitle => 'Comentarios';

  @override
  String get postCommentHint => 'Escribe un comentario…';

  @override
  String get postCommentsLoadFailed => 'No se pudieron cargar los comentarios';

  @override
  String get postCommentsEmpty => 'Sé el primero en comentar';

  @override
  String get profileSessionIncomplete => 'Tu sesión está incompleta';

  @override
  String get profileSessionIncompleteHint =>
      'Vuelve a iniciar sesión para que todo funcione correctamente.';

  @override
  String get profileLogoutRelogin => 'Cerrar sesión e iniciar de nuevo';

  @override
  String get profileShareMine => 'Compartir mi perfil';

  @override
  String get profileThemeLight => 'Modo claro';

  @override
  String get profileThemeDark => 'Modo oscuro';

  @override
  String get profileEmptyActiveTitle => 'No hay publicaciones activas';

  @override
  String get profileEmptyActiveSubtitle => 'Crea una publicación ⚡';

  @override
  String get profileEmptyMomentsTitle => 'Aún no hay momentos';

  @override
  String get profileEmptyMomentsSubtitle => 'Comparte un momento de tu día ⚡';

  @override
  String get profileEmptyAnswersTitle => 'Aún no hay respuestas';

  @override
  String get profileEmptyAnswersSubtitle =>
      'Tus respuestas a los mensajes anónimos aparecerán aquí 🕶️';

  @override
  String get profileEmptyCrystalsTitle => 'Aún no hay cristales';

  @override
  String get profileEmptyLikesTitle => 'Aún no te ha gustado ningún cristal';

  @override
  String get profileAvatarUpdated => 'Foto actualizada';

  @override
  String get profileUploadFailed => 'Error al subir';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileFieldDisplayName => 'Nombre visible';

  @override
  String get profileFieldBio => 'Biografía';

  @override
  String get profileFieldLocation => 'Ubicación';

  @override
  String get profileFieldWebsite => 'Sitio web';

  @override
  String get profileSaved => 'Guardado';

  @override
  String get profileSaveFailed => 'No se pudo guardar';

  @override
  String get profileShareAccount => 'Comparte tu cuenta';

  @override
  String get profilePersona => 'Mi personalidad';

  @override
  String get profileFollowingCount => 'Siguiendo';

  @override
  String get profileAnswers => 'Respuestas';

  @override
  String get profileBadgeCrystals => 'Cristales';

  @override
  String get profileBadgeStreak => 'Racha';

  @override
  String get profileBadgeMirrors => 'Espejos';

  @override
  String get profileTabActiveShort => 'Activo';

  @override
  String get profileTabMoments => 'Momentos';

  @override
  String get profileTabAnswers => 'Respuestas';

  @override
  String get profileTabCrystalsShort => 'Cristalizado';

  @override
  String get profileTabLikesShort => 'Me gusta';

  @override
  String get profileQuickSaved => 'Mis guardados';

  @override
  String get profileQuickPlay => 'Juega y desafía';

  @override
  String get profileQuickHelp => 'Ayuda';

  @override
  String get profileShareThis => 'Compartir este perfil';

  @override
  String get profileBlockUser => 'Bloquear a este usuario';

  @override
  String get profileBlockUserBody =>
      'No recibirás ningún mensaje ni publicación suya, y tampoco te verá. Puedes desbloquearlo más tarde desde ajustes.';

  @override
  String get profileBlocked => 'Bloqueado';

  @override
  String get profileBlockFailed => 'No se pudo bloquear';

  @override
  String get profileReportSent => 'Reporte enviado — lo revisaremos';

  @override
  String get profileReport => 'Reportar';

  @override
  String get profileNothingHere => 'Aún no hay nada aquí';

  @override
  String get profileFollowingStat => 'Siguiendo';

  @override
  String get profileActionFailed => 'No se pudo completar la solicitud';

  @override
  String get profileFollowingState => 'Siguiendo';

  @override
  String get profileFollowAction => 'Seguir';

  @override
  String get profileBadgeHowToGet => 'Cómo conseguirlo';

  @override
  String get profileBadgeCrystalsTitle => 'Cristales ✦';

  @override
  String get profileBadgeCrystalsLead =>
      'Los cristales son tus publicaciones que sobrevivieron 24 horas y lograron una interacción auténtica, pasando de un momento fugaz a una huella duradera.';

  @override
  String get profileBadgeCrystalsStep1 =>
      'Publica algo que merezca debate — un momento, una imagen o una idea.';

  @override
  String get profileBadgeCrystalsStep2 =>
      'Cada interacción (me gusta, respuesta) aumenta la gravedad de la publicación.';

  @override
  String get profileBadgeCrystalsStep3 =>
      'Alcanza el umbral de cristalización antes de que terminen las 24 horas → se convierte en un ✦ permanente guardado en tus cristales.';

  @override
  String get profileBadgeCrystalsStep4 =>
      'Las publicaciones sin interacción desaparecen silenciosamente tras 24 horas (eso es lo que hace valioso un cristal).';

  @override
  String get profileBadgeCrystalsTip =>
      'Los cristales aparecen a los visitantes en tu perfil como prueba de tu huella. Comparte lo que perdura, no lo que se acumula.';

  @override
  String get profileBadgeStreakTitle => 'Racha 🔥';

  @override
  String get profileBadgeStreakLead =>
      'La racha es tu serie de días consecutivos en Sarhny. Cada día que publicas añade una chispa a tu llama.';

  @override
  String get profileBadgeStreakStep1 =>
      'Abre la app y publica al menos una vez cada 24 horas.';

  @override
  String get profileBadgeStreakStep2 =>
      'La racha mantiene tu serie hasta 48 horas como margen de respiro.';

  @override
  String get profileBadgeStreakStep3 =>
      'Cuanto más larga sea la racha, más noble y notable será tu brillo en tu perfil.';

  @override
  String get profileBadgeStreakStep4 =>
      'Romper la racha reinicia el contador — pero no borra los cristales que has construido.';

  @override
  String get profileBadgeStreakTip =>
      'La racha mide la constancia, no la calidad. Un poco cada día es mejor que mucho en un día.';

  @override
  String get profileBadgeMirrorsTitle => 'Espejos 🪞';

  @override
  String get profileBadgeMirrorsLead =>
      'Un espejo es una pregunta abierta que haces, dejando que la gente te describa con sinceridad a través de ella. Las respuestas se acumulan en una nube que refleja cómo te ven quienes te rodean.';

  @override
  String get profileBadgeMirrorsStep1 =>
      'Toca la pestaña «Espejos» y crea una pregunta reflexiva (p. ej.: ¿Qué es lo que más me distingue?).';

  @override
  String get profileBadgeMirrorsStep2 =>
      'Comparte el enlace del espejo con tus amigos o en tu cuenta de otra app.';

  @override
  String get profileBadgeMirrorsStep3 =>
      'Las respuestas llegan de forma anónima — no sabes quién dijo qué, así que la gente habla con franqueza.';

  @override
  String get profileBadgeMirrorsStep4 =>
      'Cada espejo te otorga una insignia 🪞 que aparece en tu perfil y aumenta tu peso en Sarhny.';

  @override
  String get profileBadgeMirrorsTip =>
      'Los espejos funcionan mejor con preguntas concretas, no vagas. Pregunta lo que realmente quieres saber.';

  @override
  String get profileSavedTitle => 'Guardados';

  @override
  String get profileSavedEmptyTitle => 'No hay elementos guardados';

  @override
  String get profileSavedEmptySubtitle =>
      'Guarda una publicación tocando 🔖 para verla aquí';

  @override
  String get profileAnonLoginRequired => 'Inicia sesión para enviar un mensaje';

  @override
  String get profileAnonSent => 'Tu mensaje fue entregado 🌙';

  @override
  String get profileAnonRateLimited =>
      'Demasiados intentos — espera un momento';

  @override
  String get profileAnonSendFailed => 'No se pudo enviar';

  @override
  String get profileAnonTitle => 'Pregúntale de forma anónima';

  @override
  String get profileAnonSubtitle =>
      'No sabrá quién lo envió — a menos que te reveles';

  @override
  String get profileAnonHint => 'Escribe tu pregunta o mensaje…';

  @override
  String get profileAnonSend => 'Enviar';

  @override
  String get profileLinkCopied => 'Enlace copiado';

  @override
  String get articleAppBarTitle => 'Mi personalidad ✨';

  @override
  String get articleGenerated => 'Tu artículo fue creado ✨';

  @override
  String get articleGenerateFailed => 'No se pudo generar';

  @override
  String get articleCurrentLabel => 'Mi artículo actual';

  @override
  String articleArchiveLabel(Object count) {
    return 'Archivo · artículos anteriores ($count)';
  }

  @override
  String get articleHeaderTitle => 'Tu artículo personal';

  @override
  String get articleHeaderBody =>
      'Tu artículo se escribe a partir de tus respuestas públicas a mensajes anónimos. Cuanto más honestamente respondas, mejor te conocerá la IA — y más fiel será lo que escriba sobre ti.';

  @override
  String get articleNextTitle => 'Próximo artículo';

  @override
  String articleDaysRemaining(Object days) {
    return 'Quedan $days días para poder crear tu próximo artículo.';
  }

  @override
  String articleCooldownNote(Object days) {
    return 'Cada $days días puedes crear una nueva versión. La nueva versión se construirá a partir de tus respuestas más recientes.';
  }

  @override
  String get articleProgress => 'Tu progreso';

  @override
  String articleNeedMore(Object count) {
    return 'Necesitas $count respuestas públicas más a mensajes anónimos para desbloquear tu artículo. Estas respuestas son las que hacen que el artículo se parezca de verdad a ti.';
  }

  @override
  String get articleGenerating => 'Generando…';

  @override
  String get articleRegenerateCta => 'Crear una nueva versión de mi artículo';

  @override
  String get articleGenerateCta => 'Escribir mi artículo ahora ✨';

  @override
  String get articleSaved => 'Guardado';

  @override
  String get articleSaveFailed => 'No se pudo guardar';

  @override
  String get articlePublishTitle => 'Publicar el artículo públicamente';

  @override
  String get articlePublishBody =>
      '24 horas después de publicar, el artículo queda disponible para cualquiera mediante un enlace público en el blog. Puedes eliminarlo cuando quieras.';

  @override
  String get articlePublishConfirm => 'Publicar';

  @override
  String get articlePublishScheduled => 'Aparecerá en 24 horas 🌙';

  @override
  String get articlePublishFailed => 'No se pudo publicar';

  @override
  String get articleDeleteTitle => 'Eliminar artículo';

  @override
  String get articleDeleteBody =>
      'El artículo actual se eliminará. Las versiones anteriores permanecen guardadas en el archivo.';

  @override
  String get articleDeleted => 'Eliminado';

  @override
  String get articleDeleteFailed => 'No se pudo eliminar';

  @override
  String get articleStatusPublished => 'Publicado';

  @override
  String get articleStatusPrivate => 'Privado';

  @override
  String get articlePublishAction => 'Publicarlo';

  @override
  String get articleEdit => 'Editar';

  @override
  String get articleDeleteHistoryTitle => 'Eliminar del archivo';

  @override
  String get articleDeleteHistoryBody =>
      'Esta versión se eliminará permanentemente de tu archivo.';

  @override
  String get composeImageTooLarge => 'La imagen supera los 15 MB';

  @override
  String get composeCropImage => 'Recortar imagen';

  @override
  String get composeUploadFailed => 'No se pudo subir la imagen';

  @override
  String get composePublishedToast => 'Publicado con sinceridad ✨';

  @override
  String get composePublishFailed => 'No se pudo publicar';

  @override
  String get composeDiscardTitle => '¿Descartar borrador?';

  @override
  String get composeDiscardBody => 'Perderás lo que escribiste. ¿Continuar?';

  @override
  String get composeKeep => 'Mantener';

  @override
  String get composeDiscard => 'Descartar';

  @override
  String get composeClose => 'Cerrar';

  @override
  String get composeNewPost => 'Nueva publicación';

  @override
  String get composeWriteFromHeart => 'Escribe desde el corazón';

  @override
  String get composeLivesTitle => 'Tu publicación vive solo 24 horas';

  @override
  String get composeLivesBody =>
      'Si logra interacciones sinceras antes de terminar → se cristaliza ✦ y permanece para siempre. Sin ellas, se desvanece en silencio. Comparte lo que merece debate.';

  @override
  String get composeLayer1Title => 'Capa 1 — Esencia';

  @override
  String get composeLayer1Subtitle => 'La idea central en pocas líneas';

  @override
  String get composeLayer1Hint => '¿Qué tienes en mente?';

  @override
  String get composeLayer2Title => 'Capa 2 — Imágenes';

  @override
  String get composeLayer2Subtitle => 'Hasta 4 imágenes (cuadradas)';

  @override
  String get composeUploading => 'Subiendo…';

  @override
  String get composeAddImage => 'Añadir imagen';

  @override
  String get composeHideLayer3 => 'Ocultar capa 3';

  @override
  String get composeAddLayer3 => 'Añadir capa 3 — reflexión';

  @override
  String get composeLayer3Title => 'Capa 3 — Reflexión';

  @override
  String get composeLayer3Subtitle => 'Texto largo (hasta 4000 caracteres)';

  @override
  String get composeLayer3Hint => 'Reflexiona con nosotros… (opcional)';

  @override
  String get composeMomentDesc =>
      'Una línea fugaz de tu día — un sentimiento rápido, un pensamiento, algo del momento. La más corta, la más sincera.';

  @override
  String get composeFaceDesc =>
      'Una imagen que cuenta tu huella, con un pie de foto corto. Para momentos visuales que vale la pena guardar.';

  @override
  String get composeMindDesc =>
      'Una reflexión más profunda que escribes con calma. Un lugar para ideas que necesitan tiempo para leer.';

  @override
  String get gameAiQLight => '¿Qué es lo que más te hace reír últimamente?';

  @override
  String get gameAiQFunny =>
      '¿Cuál es la situación más vergonzosa que te ha pasado en público?';

  @override
  String get gameAiQBold =>
      '¿Cuál es un secreto que nunca le has contado a nadie?';

  @override
  String get helpTabFeatures => 'Funciones';

  @override
  String get helpTabFaq => 'Preguntas frecuentes';

  @override
  String get helpLegalLastUpdated => 'Última actualización: noviembre de 2025';

  @override
  String get helpLegalReadFull => 'Leer la versión completa en el sitio web';

  @override
  String get helpLegalTermsSummary =>
      'Al unirte a Sarhny, aceptas cumplir estas condiciones:\n\n• Edad: la aplicación es solo para adultos (mayores de 18 años). Cualquier cuenta que se determine que pertenece a un menor será eliminada.\n\n• Contenido: te comprometes a publicar contenido que no viole la ley ni incite al daño, y que no contenga chantaje, pornografía ni discurso de odio.\n\n• Mensajes anónimos: entiendes que nuestra plataforma permite enviar mensajes anónimos y que eres responsable de tus decisiones de aceptarlos o denunciarlos.\n\n• Cuenta: es tu responsabilidad proteger tu correo electrónico y tu contraseña. Sarhny nunca te pedirá tu contraseña.\n\n• Suspensión del servicio: nos reservamos el derecho de suspender cualquier cuenta que infrinja estas condiciones sin previo aviso.\n\n• Ley aplicable: las leyes del Reino de Arabia Saudita rigen tu uso de la aplicación.\n\nPara leer la versión completa y actualizada, abre el enlace de abajo.';

  @override
  String get helpLegalPrivacySummary =>
      'En Sarhny, tu privacidad está en el centro de nuestra experiencia:\n\n• Lo que recopilamos: el correo electrónico, el nombre de usuario, las fotos y textos que publicas, la dirección IP al enviar (solo para prevenir abusos).\n\n• Lo que no recopilamos: no recopilamos contactos, ni ubicación precisa, ni historial de navegación fuera de la aplicación.\n\n• Mensajes anónimos: la identidad del remitente no se te muestra a ti ni a ningún otro usuario. Conservamos un hash de IP internamente durante 30 días solo con fines de denuncia legal.\n\n• Notificaciones: no enviamos notificaciones de marketing. Todas las notificaciones están vinculadas a la actividad dentro de tu cuenta.\n\n• Compartir datos: no vendemos ningún dato a terceros. Solo compartimos:\n  - Ante una solicitud judicial oficial.\n  - Con proveedores de infraestructura (servidor, almacenamiento en la nube) para operar el servicio.\n\n• Tus derechos: puedes solicitar una copia de tus datos o eliminar tu cuenta de forma permanente desde la pantalla de ajustes.\n\n• Niños: la aplicación está prohibida para menores de 18 años. Si nos enteramos de la cuenta de un menor, la eliminamos de inmediato.\n\nPara la versión legal detallada, abre el enlace de abajo.';

  @override
  String get helpLegalContentSummary =>
      'Todo el contenido en Sarhny está sujeto a esta política:\n\n✓ Permitido: expresar opiniones, preguntas sinceras, fotos personales decorosas, arte, pensamientos reflexivos.\n\n✗ Prohibido y eliminado de inmediato:\n• Contenido pornográfico o semipornográfico de cualquier tipo.\n• Discurso de odio contra una religión, raza o género.\n• Chantaje o amenazas.\n• Promoción de la violencia, el terrorismo o las drogas.\n• Todo lo que revele la identidad de un menor o se dirija a menores.\n• Anuncios y enlaces de marketing intrusivos.\n• Suplantación de la identidad de otros.\n\nUtilizamos algoritmos de aprendizaje automático + revisión humana para detectar infracciones. La denuncia está disponible para todos los usuarios mediante el botón «Denunciar» en cualquier publicación o mensaje.';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String notifAllMarkedRead(Object n) {
    return 'Marcado como leído ($n)';
  }

  @override
  String get notifMarkReadFailed => 'No se pudo actualizar';

  @override
  String get notifMarkAllRead => 'Marcar todo como leído';

  @override
  String get notifEmptyTitle => 'Sin notificaciones';

  @override
  String get notifEmptySubtitle =>
      'Aquí aparecerán tus avisos sobre todo lo nuevo';

  @override
  String get notifLikedYourPost => 'le gustó tu publicación';

  @override
  String get notifCommentedOnYourPost => 'comentó tu publicación';

  @override
  String get notifStartedFollowingYou => 'empezó a seguirte';

  @override
  String get notifAnonymousQuestion => 'Recibiste una pregunta anónima';

  @override
  String get notifPostCrystallized => 'Tu publicación se cristalizó ✦';

  @override
  String get searchHint => 'Busca un usuario o explora las sugerencias';

  @override
  String get searchEmptyBrowse => 'Aún no hay usuarios para mostrar';

  @override
  String searchNoResults(Object query) {
    return 'No hay resultados que coincidan con \"$query\"';
  }

  @override
  String get searchSuggestedForYou => 'Sugerencias para ti';

  @override
  String get settingsTierPro => 'Pro';

  @override
  String get settingsTierCreator => 'Creador';

  @override
  String get settingsTierEternal => 'Eterno';

  @override
  String get settingsTierFree => 'Gratis';

  @override
  String get settingsPackagePrefix => 'Plan';

  @override
  String get settingsAttentionPrefix => 'Atención:';

  @override
  String get settingsManageSubscription => 'Gestionar suscripción';

  @override
  String get settingsPlansTitle => 'Planes';

  @override
  String get settingsPlansSubtitle =>
      'Los planes de Sarhny te dan un mayor presupuesto de atención y una presencia más fuerte.';

  @override
  String get settingsUpgraded => 'Actualizado ✨';

  @override
  String get settingsUpgradeFailed => 'No se pudo actualizar';

  @override
  String get settingsSubscriptionCancelled => 'Cancelado';

  @override
  String get settingsCancelFailed => 'No se pudo cancelar';

  @override
  String get settingsDailyAttentionPrefix => 'Atención diaria:';

  @override
  String get settingsCurrentPlan => 'Tu plan actual';

  @override
  String get settingsCancelSubscription => 'Cancelar suscripción';

  @override
  String get settingsUpgrade => 'Actualizar';

  @override
  String get settingsBlockedEmptyTitle => 'No hay cuentas bloqueadas';

  @override
  String get settingsBlockedEmptySubtitle =>
      'Cuando bloqueas una cuenta, aparece aquí y puedes desbloquearla en cualquier momento.';

  @override
  String get settingsUnblocked => 'Desbloqueado';

  @override
  String get settingsUnblockFailed => 'No se pudo desbloquear';

  @override
  String get settingsUnblock => 'Desbloquear';

  @override
  String get reportReasonPostAbusive => 'Contenido ofensivo o insultos';

  @override
  String get reportReasonPostHarassment => 'Acoso o intimidación';

  @override
  String get reportReasonPostSexual => 'Contenido sexual';

  @override
  String get reportReasonPostRacism => 'Racismo o incitación';

  @override
  String get reportReasonPostSpam => 'Spam o contenido duplicado';

  @override
  String get reportReasonPostPrivacy => 'Violación de la privacidad';

  @override
  String get reportReasonPostMisinfo => 'Información engañosa';

  @override
  String get reportReasonOther => 'Otro';

  @override
  String get reportReasonUserAbusive => 'Cuenta abusiva o acosadora';

  @override
  String get reportReasonUserImpersonation => 'Suplantación de identidad';

  @override
  String get reportReasonUserScam => 'Cuenta fraudulenta / spam';

  @override
  String get reportReasonUserMinors => 'Apunta a menores';

  @override
  String get reportReasonUserSpamMessages =>
      'Envía mensajes molestos repetidamente';

  @override
  String get reportReasonUserProfile =>
      'Contenido de perfil que infringe las normas';

  @override
  String get reportNeedClearReason => 'Escribe un motivo claro para el reporte';

  @override
  String get reportReceived => 'Reporte recibido. Gracias 🌙';

  @override
  String get reportSendFailed => 'No se pudo enviar el reporte';

  @override
  String get reportTitlePost => 'Reportar publicación';

  @override
  String get reportTitleUser => 'Reportar usuario';

  @override
  String get reportConfidentialNote =>
      'Los reportes son confidenciales. El equipo de moderación los revisa en 24 horas.';

  @override
  String get reportExplainBriefly => 'Explica brevemente el motivo';

  @override
  String get reportExtraDetails => 'Detalles adicionales (opcional)';

  @override
  String get reportSubmit => 'Enviar reporte';

  @override
  String get commonComingSoon => 'Próximamente…';

  @override
  String get carromChatLoadFailed => 'No se pudieron cargar los mensajes';

  @override
  String get carromWalletBalance => 'Tu saldo actual';

  @override
  String get carromWalletLoadFailed => 'No se pudo cargar el saldo';

  @override
  String get carromGotIt => 'Entendido';

  @override
  String carromAimAnglePower(Object angle, Object power) {
    return 'Ángulo $angle° · Potencia $power%';
  }

  @override
  String get carromAimDragStriker =>
      'Arrastra el disco a la izquierda o derecha';

  @override
  String get carromMmSearchFailed => 'No se pudo encontrar un oponente';

  @override
  String get carromMmWaitAverage => 'Espera media de menos de 30 segundos';

  @override
  String get carromMmWaitLongTitle => '¿Tarda mucho?';

  @override
  String get carromMmVsComputerSoon =>
      'Partida contra la computadora — próximamente';

  @override
  String get carromInviteCreateFailed => 'No se pudo crear la invitación';

  @override
  String get carromInvitePasteFirst => 'Primero pega el código de invitación';

  @override
  String get carromInviteJoinFailed => 'No se pudo unir a la invitación';

  @override
  String get carromInviteYourCode => 'Tu código de invitación';

  @override
  String get carromInviteCodeHint =>
      'El código es válido por 5 minutos. Compártelo con tu amigo para unirse a la partida.';

  @override
  String get carromInviteCopied => 'Código copiado';

  @override
  String get carromInviteEnterRoom => 'Entrar a la sala';

  @override
  String get carromWalletLoading => 'Cargando billetera...';

  @override
  String get carromRulesTitle => 'Reglas rápidas';

  @override
  String get carromRule1 =>
      '• Arrastra hacia adentro desde el disco para apuntar — cuanto más largo el arrastre, más fuerte el tiro';

  @override
  String get carromRule2 =>
      '• Fichas blancas = 1 punto, negras = 2, reina = 3 (pero debes cubrirla)';

  @override
  String get carromRule3 =>
      '• Mantienes tu turno si embocas tu color, y lo pierdes con una falta';

  @override
  String get carromRule4 =>
      '• El ganador se revela al oponente (opcional) y se lleva todos los puntos';

  @override
  String get carromConcedeTitle => '¿Rendirte?';

  @override
  String carromConcedeBody(Object pot) {
    return 'Si te rindes ahora, tu oponente gana $pot puntos. No se puede deshacer.';
  }

  @override
  String get carromConcedeContinue => 'Continuar la partida';

  @override
  String get carromGameTitle => 'Carrom';

  @override
  String carromReconnectAttempt(Object attempt) {
    return 'Reconectando... (intento n.º $attempt)';
  }

  @override
  String get carromOpponentDisconnected =>
      'Tu oponente se desconectó — esperando ';

  @override
  String get carromRematchStartFailed => 'No se pudo iniciar la revancha ahora';

  @override
  String get carromActionFailed => 'No se pudo realizar la acción ahora';

  @override
  String get carromRevealSent =>
      'Listo — si tu oponente acepta, intercambiarán identidades';

  @override
  String get carromStayedAnonymous => 'Permaneciste anónimo';

  @override
  String get carromRequestFailed => 'No se pudo enviar la solicitud';

  @override
  String get carromSarhnyTitle => 'Un mensaje de Sarhny a tu oponente';

  @override
  String get carromSarhnySubtitle =>
      'Llega a la bandeja de entrada del oponente con la etiqueta «jugó Carrom contigo»';

  @override
  String get carromSarhnyHint => 'Escribe tu mensaje...';

  @override
  String get carromMessageTooShort => 'El mensaje es demasiado corto';

  @override
  String get carromSendFailed => 'No se pudo enviar';

  @override
  String get carromMessageDelivered => 'Tu mensaje llegó a tu oponente';

  @override
  String carromAdReward(Object credited, Object balance) {
    return '+$credited puntos — saldo: $balance';
  }

  @override
  String get carromAdDailyCap => 'Has alcanzado el límite diario (10 anuncios)';

  @override
  String get carromAdUnavailable =>
      'Anuncio no disponible ahora — inténtalo más tarde';

  @override
  String get carromAdVerifyFailed => 'No se pudo verificar el anuncio';

  @override
  String get carromAdUnsupported =>
      'Los anuncios no son compatibles con esta plataforma';

  @override
  String get carromAdRewardFailed => 'No se pudo añadir la recompensa';

  @override
  String get carromRevealTitle => 'Revela tu identidad a tu oponente';

  @override
  String get carromRevealSubtitle => 'Ambos se revelan — gratis';

  @override
  String get carromHideTitle => 'Ocultar mi identidad';

  @override
  String get carromHideSubtitle => 'Permanece anónimo — cuesta 10 puntos';

  @override
  String get carromSendSarhnyTitle => 'Enviar un mensaje de Sarhny';

  @override
  String get carromSendSarhnySubtitle =>
      'A la bandeja del oponente — con el contexto de la partida';

  @override
  String get carromWatchAdTitle => 'Mira un anuncio por +1 punto';

  @override
  String get carromWatchAdSubtitle => 'Hasta 10 anuncios al día';

  @override
  String get carromSendSarhnyShort => 'Enviar un Sarhny';

  @override
  String get carromSendSarhnyShortSub =>
      'Envía un mensaje a tu oponente — sin revelar quién eres';

  @override
  String get carromOpponentConceded => 'Tu oponente se rindió';

  @override
  String get carromOpponentConcededSub => 'El título es tuyo. ¿Nueva partida?';

  @override
  String get carromYouConceded => 'Te rendiste en esta partida';

  @override
  String get carromYouConcededSub =>
      'Cada partida es una lección. Inténtalo de nuevo cuando quieras.';

  @override
  String get carromWonSubtitle => 'Eres el campeón de esta partida';

  @override
  String get carromLostSubtitle => 'Cada partida es una nueva oportunidad';

  @override
  String get carromPoints => 'puntos';

  @override
  String get carromBackToLobby => 'Volver al lobby';

  @override
  String get carromSearchOther => 'Buscar otro oponente';

  @override
  String carromRematchWaiting(Object seconds) {
    return 'Esperando que el oponente acepte… ($seconds s)';
  }

  @override
  String get carromRematchWaitingHint =>
      'Si tu oponente toca «Revancha», la partida comienza de inmediato';

  @override
  String get carromRematchDeclined => 'Tu oponente rechazó la revancha';

  @override
  String get carromRematchTimeout =>
      'Se acabó el tiempo — oponente no disponible';

  @override
  String get carromRematchSameOpponent => 'O revancha con el mismo oponente';

  @override
  String get carromRematchSameOpponentAction =>
      'Revancha con el mismo oponente';

  @override
  String get carromRematchAction => 'Revancha';

  @override
  String get carromWhatHappenedLabel => 'Qué pasó en esta partida';

  @override
  String get carromMatchReviewSoon => 'Revisión de la partida (próximamente)';

  @override
  String get carromWhatHappened => '¿Qué pasó?';

  @override
  String get carromSoon => 'Pronto';

  @override
  String get carromReviewMovesSoon =>
      'Revisa tus últimos movimientos (próximamente)';

  @override
  String get carromMmRaceHint => 'Quien llegue primero empieza a jugar';

  @override
  String get carromCosmeticsTitle2 => 'Aspectos de carrom';

  @override
  String get carromCosmeticsBoard => 'Tablero';

  @override
  String get carromCosmeticsPieces => 'Fichas';

  @override
  String get carromCosmeticsSound => 'Sonido';

  @override
  String get carromCosmeticsMute => 'Silenciar los sonidos del juego';

  @override
  String get carromBoardWalnut => 'Madera fina';

  @override
  String get carromBoardSapphire => 'Azul real';

  @override
  String get carromBoardEmerald => 'Verde esmeralda';

  @override
  String get carromCoinClassic => 'Clásico';

  @override
  String get carromCoinRoyal => 'Oro real';

  @override
  String get carromCoinVivid => 'Vívido';

  @override
  String get carromCoinCandy => 'Caramelo';

  @override
  String get carromChatNiceGame => 'Buen juego';

  @override
  String get carromChatFireShot => 'Tiro de fuego';

  @override
  String get carromChatPreciseAim => 'Puntería precisa';

  @override
  String get carromChatWatchLearn => 'Mira y aprende';

  @override
  String get carromChatMyLuck => 'Qué suerte la mía';

  @override
  String get carromChatBravo => 'Bravo';

  @override
  String get carromChatWow => '¡Guau!';

  @override
  String get carromChatGoodLuck => 'Buena suerte';

  @override
  String get carromChatEasy => 'Fácil';

  @override
  String get carromChatMadeItHard => 'Lo pusiste difícil';

  @override
  String get carromChatCovered => '¡La cubrió!';

  @override
  String get carromChatBeautifulGame => 'Hermoso juego';

  @override
  String get carromMatchWonMatch => 'Ganaste el partido 🏆';

  @override
  String get carromMatchOppWon => 'Ganó el oponente';

  @override
  String get carromMatchOppAiming => 'El oponente está apuntando…';

  @override
  String get carromMatchPiecesMoving => 'Las fichas se mueven…';

  @override
  String get carromMatchOppCoversQueen =>
      'El oponente está cubriendo la reina 👑';

  @override
  String get carromMatchCoverQueen =>
      'Cubre la reina 👑 — embolsa una de tus fichas';

  @override
  String get carromMatchYourTurnHint =>
      'Tu turno — arrastra el disco hacia atrás para apuntar, luego suelta';

  @override
  String get carromMatchTitle => 'Carrom';

  @override
  String get carromOnlineTitle => 'Carrom en línea';

  @override
  String get carromUnmute => 'Activar sonido';

  @override
  String get carromMute => 'Silenciar';

  @override
  String get carromSkins => 'Aspectos';

  @override
  String get carromYou => 'Tú';

  @override
  String get carromOpponent => 'Oponente';

  @override
  String get carromFoulStriker => 'Falta: el disco entró en la tronera';

  @override
  String get carromFoulNoHit => 'Falta: no tocaste ninguna ficha';

  @override
  String get carromFoulTimeout => 'Se acabó tu tiempo — pasa al oponente';

  @override
  String get carromFoulTimeoutOnline => 'Se acabó el tiempo del jugador — pasa';

  @override
  String get carromFoul => 'Falta';

  @override
  String get carromQaWinAsk => '¡Ganaste! Hazle una pregunta a tu oponente';

  @override
  String get carromQaLoseAnswer => 'Ganó el oponente — responde su pregunta';

  @override
  String get carromQaQuestionHint => 'Escribe tu pregunta para el oponente…';

  @override
  String get carromQaAnswerHint => 'Escribe tu respuesta…';

  @override
  String get carromQaFetchingQuestion => 'Obteniendo la pregunta…';

  @override
  String get carromQaPrivate => 'Privado — no se guarda';

  @override
  String get carromQaWaitingAnswer => 'Esperando la respuesta del oponente…';

  @override
  String get carromQaWaitingQuestion => 'Esperando la pregunta del oponente…';

  @override
  String get carromQaAnswerSent => 'Tu respuesta fue enviada ✓';

  @override
  String get carromBubbleOppAnswer => 'Respuesta del oponente';

  @override
  String get carromBubbleOppQuestion => 'Pregunta del oponente';

  @override
  String get carromSkip => 'Omitir';

  @override
  String get carromFinish => 'Finalizar';

  @override
  String get carromSendQuestion => 'Enviar pregunta';

  @override
  String get carromSendAnswer => 'Enviar respuesta';

  @override
  String get carromYouWon => '¡Ganaste!';

  @override
  String get carromNewMatch => 'Nuevo partido';

  @override
  String get carromNewOpponent => 'Nuevo oponente';

  @override
  String get carromOppLeft => 'El oponente se fue';

  @override
  String get carromConnected => 'Conectado';

  @override
  String get carromConnecting => 'Conectando…';

  @override
  String get carromAimMoveStriker => 'Desliza el tirador a izquierda y derecha';

  @override
  String get carromAimDragToAim => 'Arrastra el tirador para apuntar';

  @override
  String get carromMmAvgWait => 'Espera media de menos de 30 segundos';

  @override
  String get carromOnlineWon => '¡Ganaste! 🏆';

  @override
  String get carromOnlineLost => 'Perdiste';

  @override
  String get carromScoreYou => 'Tú';

  @override
  String get carromScoreOpp => 'Riv.';

  @override
  String get carromOpponentLeft => 'Tu rival se fue — esperando su regreso';

  @override
  String get carromConcedeAction => 'Rendirse';

  @override
  String get carromMatchOver => 'Partida terminada';

  @override
  String get carromTurnYouAim => 'Tu turno — apunta';

  @override
  String get carromTurnWaitOpp => 'Esperando a tu rival…';

  @override
  String get carromExitTitle => '¿Salir de la partida?';

  @override
  String get carromExitBody => 'La ronda actual contará como derrota.';

  @override
  String get carromExitAction => 'Salir';

  @override
  String get carromTitleShort => 'Carrom';

  @override
  String get carromPiecesMoving => 'Las fichas se mueven…';

  @override
  String get carromStatusDragHint =>
      'Arrastra desde el tirador para ajustar potencia y ángulo';

  @override
  String get carromNewPractice => 'Nueva práctica';

  @override
  String get carromFoulStrikerPocketed =>
      'Falta: el tirador cayó en la tronera';

  @override
  String get carromFoulNoPieceHit => 'Falta: no tocaste ninguna ficha';

  @override
  String get carromFoulWrongColor =>
      'Falta: tocaste primero la ficha del rival';

  @override
  String get carromFoulQueenUncovered => 'Falta: la reina no fue cubierta';

  @override
  String get carromFoulGeneric => 'Falta en el tiro';

  @override
  String get carromChatToughOne => 'Lo pusiste difícil';

  @override
  String get carromChatNicePlay => 'Buena jugada';

  @override
  String get carromConcedeProTitle => '¿Retirarte de la partida?';

  @override
  String get carromConcedeProBody => 'Contará como derrota.';

  @override
  String get carromWithdraw => 'Retirarse';

  @override
  String get carromProTitle => 'Carrom Pro';

  @override
  String get carromChat => 'Chat';

  @override
  String get carromStatusWonMatch => 'Ganaste la partida 🏆';

  @override
  String get carromStatusOppWon => 'Ganó el rival';

  @override
  String get carromStatusOppAiming => 'El rival está apuntando…';

  @override
  String get carromStatusOppCoverQueen => 'El rival está cubriendo la reina 👑';

  @override
  String get carromStatusCoverQueen =>
      'Cubre la reina 👑 — embolsa una de tus fichas';

  @override
  String get carromStatusYourTurnDrag =>
      'Tu turno — arrastra el tirador, apunta y suelta';

  @override
  String get carromFoulStrikerPocketed2 =>
      'Falta: el tirador entró en la tronera';

  @override
  String get carromFoulNoPieceHit2 => 'Falta: no tocaste ninguna ficha';

  @override
  String get ludoInviteCreateFailed => 'No se pudo crear la invitación';

  @override
  String get ludoInvitePasteFirst => 'Pega primero el código de invitación';

  @override
  String get ludoInviteJoinFailed => 'No se pudo unir a la invitación';

  @override
  String get ludoInviteCodeTitle => 'Tu código de invitación';

  @override
  String get ludoInviteCodeHint =>
      'El código es válido 5 minutos. Compártelo para que otros se unan a la partida.';

  @override
  String get ludoCodeCopied => 'Código copiado';

  @override
  String get ludoCopy => 'Copiar';

  @override
  String get ludoEnterRoom => 'Entrar a la sala';

  @override
  String get ludoBadgeNew => 'Nuevo';

  @override
  String get ludoBadge2to4 => '2-4 jugadores';

  @override
  String get ludoHeroTitle => 'Parchís dorado';

  @override
  String get ludoHeroSubtitle => 'Los dados deciden, la valentía gana';

  @override
  String get ludoChooseMode => 'Elige un modo';

  @override
  String get ludoMoment => 'Un momento…';

  @override
  String get ludoStartMatch => 'Iniciar partida';

  @override
  String get ludoPlayWithFriends => 'Jugar con amigos';

  @override
  String get ludoJoinByInvite => 'Unirse con invitación';

  @override
  String get ludoPasteCode => 'Pega el código';

  @override
  String get ludoJoin => 'Unirse';

  @override
  String ludoEntryWinner(Object fee, Object pot) {
    return 'Entrada $fee — el ganador se lleva $pot';
  }

  @override
  String ludoCurrentBalance(Object points) {
    return 'Tu saldo: $points puntos';
  }

  @override
  String get ludoCount2Players => '2 jugadores';

  @override
  String get ludoCount4Players => '4 jugadores';

  @override
  String get ludoMmSearchFailed => 'No se pudo buscar rivales';

  @override
  String get ludoMmSearch3 => 'Buscando 3 rivales…';

  @override
  String get ludoMmSearch1 => 'Buscando un rival…';

  @override
  String ludoMmQueuePos(Object pos) {
    return 'Tu posición en la cola: $pos';
  }

  @override
  String get ludoMmAvgWait => 'Espera media de menos de 45 segundos';

  @override
  String get ludoConcedeTitle => '¿Rendirse?';

  @override
  String get ludoConcedeBody =>
      'Si te retiras ahora, pierdes tu entrada al bote y quedas último.';

  @override
  String get ludoConcedeBack => 'Volver';

  @override
  String get ludoConcede => 'Rendirse';

  @override
  String ludoErrorPrefixed(Object error) {
    return 'Error: $error';
  }

  @override
  String get ludoReconnecting => 'Reconectando…';

  @override
  String get ludoMoving => 'Moviendo…';

  @override
  String get ludoMovableHighlighted => 'Las fichas movibles brillan en verde';

  @override
  String get ludoDiceHint => 'Los dados impulsan tus pasos';

  @override
  String get ludoColorRed => 'Rojo';

  @override
  String get ludoColorGreen => 'Verde';

  @override
  String get ludoColorYellow => 'Amarillo';

  @override
  String get ludoOpponent => 'Rival';

  @override
  String get ludoWinTitle => '¡Victoria aplastante!';

  @override
  String get ludoNiceMatch => 'Buena partida';

  @override
  String ludoWonPoints(Object pot) {
    return 'Ganaste $pot puntos';
  }

  @override
  String ludoWinnerTakesPoints(Object pot) {
    return 'El ganador se lleva $pot puntos';
  }

  @override
  String get ludoBackToLobby => 'Volver al lobby';

  @override
  String get ludoNewMatch => 'Nueva partida';

  @override
  String get ludoArena => 'Arena';

  @override
  String get ludoRank1 => 'Primero';

  @override
  String get ludoRank2 => 'Segundo';

  @override
  String get ludoRank3 => 'Tercero';

  @override
  String get ludoRank4 => 'Cuarto';

  @override
  String ludoRankYou(Object rank) {
    return '$rank · Tú';
  }

  @override
  String get ludoWaiting => 'Esperando…';

  @override
  String get ludoChatLoadFailed => 'No se pudieron cargar los mensajes';

  @override
  String get ludoVariantMagic => 'Ludo mágico';

  @override
  String get ludoVariantNormal => 'Ludo clásico';

  @override
  String get ludoPlayersSuffix => 'jugadores';

  @override
  String get ludoPlayerLabel => 'Jugador';

  @override
  String get ludoTurnNow => 'Su turno';

  @override
  String get ludoFrozenShort => 'Congelado';

  @override
  String get ludoMatchOverTitle => '¿Salir de la partida?';

  @override
  String get ludoContinue => 'Continuar';

  @override
  String get ludoLeave => 'Salir';

  @override
  String get ludoMatchEnded => 'Partida terminada';

  @override
  String get ludoTapDiceToRoll => 'Toca el dado para tirar';

  @override
  String get ludoTapDiceFrozen => 'Toca el dado para gastar un tiro';

  @override
  String get ludoPowerRocket => 'Cohete';

  @override
  String get ludoPowerFreeze => 'Congelar';

  @override
  String get ludoPowerDoor => 'Puerta';

  @override
  String get ludoPowerDoors => 'Puertas';

  @override
  String get ludoPowerGate => 'Portal';

  @override
  String get ludoPowerTornado => 'Tornado';

  @override
  String get ludoRocketRange => '+1 a +6';

  @override
  String get ludoFreezeThreeRolls => '3 tiros';

  @override
  String get ludoTeleport => 'Teletransporte';

  @override
  String get ludoRandom => 'Aleatorio';

  @override
  String get ludoEventFreezeEndedFor => 'Congelación terminada para';

  @override
  String get ludoEventFrozenRemaining => 'congelado — quedan';

  @override
  String get ludoEventRocketReachedHome => 'te llevó a casa';

  @override
  String get ludoEventRocketSteps => 'te empujó';

  @override
  String get ludoEventRocketStepsSuffix => 'pasos';

  @override
  String get ludoEventFreezeFor => 'Congelar a';

  @override
  String get ludoEventFreezeForThreeRolls => 'durante 3 tiros';

  @override
  String get ludoEventDoorForward => 'Cruzaste la puerta hacia adelante';

  @override
  String get ludoEventDoorBack => 'La puerta te envió atrás';

  @override
  String get ludoEventTornadoMoved =>
      'El tornado movió la ficha a un lugar inesperado';

  @override
  String get codexLudoTitle => 'Ludo Codex';

  @override
  String get codexCarromTitle => 'Carrom Codex';

  @override
  String get codexLudoIntro => 'Ludo Codex: toca el dado y observa los poderes';

  @override
  String get codexRolled => 'sacó';

  @override
  String get codexRocketSteps => 'Cohete Codex: +';

  @override
  String get codexStepsSuffix => 'pasos';

  @override
  String get codexFreezePlayer => 'Congelar al jugador';

  @override
  String get codexForThreeRolls => 'por tres tiros';

  @override
  String get codexGateMovedTo => 'El portal Codex te movió a la casilla';

  @override
  String get codexCycloneNewSpot => 'Ciclón: un nuevo lugar inesperado';

  @override
  String get codexReachedFinish => 'llegó a la meta';

  @override
  String get codexSixPlayAgain => 'Seis: el jugador';

  @override
  String get codexPlaysAgain => 'juega de nuevo';

  @override
  String get codexFrozenShort => 'congelado';

  @override
  String get codexFrozenRemaining => 'quedan';

  @override
  String get codexIceShort => 'Hielo';

  @override
  String get codexRollShort => 'Tirar';

  @override
  String get codexCarromIntro2 => 'Carrom Codex: arrastra y dispara';

  @override
  String get codexHitSuccess => 'Buen tiro: +1';

  @override
  String get codexMissPocket => 'La ficha no entró, ajusta el ángulo';

  @override
  String get codexMissCoin => 'No tocaste ninguna ficha';

  @override
  String get codexBoardCleared => 'Despejaste el tablero con';

  @override
  String get codexResetTable => 'Reiniciar tablero';

  @override
  String get carromCosmeticsLoadFailed => 'No se pudieron cargar los diseños';

  @override
  String get carromConcedeBodyPlain =>
      'Si te rindes ahora, tu oponente gana. No se puede deshacer.';

  @override
  String get hubCarromTitle => 'Carrom Pro';

  @override
  String get hubCarromSubtitle =>
      'Física realista y un rival inteligente: apunta, golpea, mete';

  @override
  String get hubCarromTag => 'Pro ✦';

  @override
  String get hubChooseMode => 'Elige el modo de juego';

  @override
  String get hubModeAi => 'Contra la máquina';

  @override
  String get hubModeAiSub =>
      'Juega ya en tu dispositivo contra un rival inteligente';

  @override
  String get hubModeOnline => 'En línea';

  @override
  String get hubModeOnlineSub => 'Reta a un jugador real: el ganador pregunta';

  @override
  String get navGames => 'Jugar';
}
