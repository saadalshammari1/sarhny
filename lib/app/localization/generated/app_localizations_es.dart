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
  String get ludoYourTurn => 'Tu turno — tira el dado';

  @override
  String ludoBotTurn(Object name) {
    return '$name está jugando…';
  }

  @override
  String get ludoRollDice => 'Tirar el dado';

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
  String get ludoNewGame => 'Nueva partida';

  @override
  String get ludoNoMove => 'Sin movimiento';

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
}
