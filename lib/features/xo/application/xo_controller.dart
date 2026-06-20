import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/xo_repository.dart';
import '../domain/xo_state.dart';

/// Controller for the live XO play page.
///
/// Pattern (matches the existing RPS controller):
///   * Poll `/state` every 2 seconds for opponent moves + phase changes.
///   * Optimistically apply our own moves and re-poll faster after.
///   * Expose snapshot + error/loading flags to the UI via family
///     provider keyed by gameId so multiple matches can coexist (e.g.
///     across rematch transitions).
class XoMatchState {
  XoMatchState({
    this.snapshot,
    this.loading = false,
    this.error,
    this.busy = false,
  });

  final XoSnapshot? snapshot;
  final bool loading;
  final String? error;
  /// True while a write request (move / answer / etc) is in-flight —
  /// the UI disables buttons to prevent double-submission.
  final bool busy;

  XoMatchState copyWith({
    XoSnapshot? snapshot,
    bool? loading,
    String? error,
    bool? busy,
    bool clearError = false,
  }) =>
      XoMatchState(
        snapshot: snapshot ?? this.snapshot,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        busy: busy ?? this.busy,
      );
}

class XoMatchController extends StateNotifier<XoMatchState> {
  XoMatchController(this._repo, this.gameId) : super(XoMatchState(loading: true)) {
    _bootstrap();
  }

  final XoRepository _repo;
  final String gameId;
  Timer? _poller;
  int _consecutiveErrors = 0;

  Future<void> _bootstrap() async {
    await refresh();
    _startPolling();
  }

  void _startPolling() {
    _poller?.cancel();
    // 1s during active play — opponent moves arrive snappier and the
    // "can I tap now?" lag disappears. The cost is small (≤1 req/sec
    // per active game).
    _poller = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  Future<void> refresh() async {
    if (!mounted) return;
    try {
      final snap = await _repo.state(gameId);
      _consecutiveErrors = 0;
      if (!mounted) return;
      state = state.copyWith(snapshot: snap, loading: false, clearError: true);
      // Stop polling once the match is fully done (no further state
      // transitions possible) AND we're past the rematch window —
      // for now we keep polling so rematch ready arrives reactively.
      if (snap.status == 'answered' || snap.status == 'abandoned') {
        // Keep polling at a slower cadence so the rematch dialog can
        // detect when the opponent accepts.
      }
    } catch (e) {
      _consecutiveErrors += 1;
      if (!mounted) return;
      // Only surface error after a couple of failed attempts to avoid
      // flashing transient network blips.
      if (_consecutiveErrors >= 3) {
        state = state.copyWith(
          loading: false,
          error: 'تعذّر تحديث الحالة',
        );
      }
    }
  }

  Future<void> _wrap(Future<XoSnapshot> Function() op) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final snap = await op();
      if (!mounted) return;
      state = state.copyWith(snapshot: snap, busy: false);
    } on XoApiException catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false, error: e.message);
      // The server rejected our action; the cause is often "you tapped
      // before the next poll showed the opponent's move". Force a
      // refresh so the UI re-syncs immediately.
      unawaited(refresh());
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(busy: false, error: 'تعذّر إكمال العملية');
      unawaited(refresh());
    }
  }

  Future<void> move(int row, int col) async {
    await _wrap(() => _repo.move(gameId, row, col));
    // Immediately refresh after a successful move — the server-side
    // win detection / turn flip can race with the 1s poll otherwise.
    if (mounted) unawaited(refresh());
  }
  Future<void> submitWinnerQuestion(String? text) =>
      _wrap(() => _repo.winnerQuestion(gameId, text));
  Future<void> submitAnswer(String text) => _wrap(() => _repo.answer(gameId, text));
  Future<void> skipQuestion() => _wrap(() => _repo.skip(gameId));
  Future<void> abstain(String adToken) =>
      _wrap(() => _repo.abstain(gameId, adToken));

  Future<void> leave() async {
    try {
      await _repo.leave(gameId);
    } catch (_) {/* best-effort */}
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }
}

final xoMatchControllerProvider =
    StateNotifierProvider.autoDispose.family<XoMatchController, XoMatchState, String>(
  (ref, gameId) => XoMatchController(ref.read(xoRepositoryProvider), gameId),
);
