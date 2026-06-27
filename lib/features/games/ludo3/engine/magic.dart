/// Magic Ludo — fully AUTOMATIC magic. No mana, no costs, no manual choices:
/// the interactive board grants effects that resolve instantly and pick their
/// own smart target (a shield auto-goes to the pawn that needs it most; a
/// freeze auto-hits the opponent closest to winning). It layers on top of the
/// classic engine: classic [LudoState]/rules drive movement, [MagicState]
/// carries the auto statuses (shields, freezes), and fixed board nodes
/// (Mystery Boxes 🎁, Wormholes 🌀) trigger on landing.
library;

import 'dart:math';

import 'ludo_models.dart';

/// Mystery Box nodes on the common track (auto loot on landing).
const Set<int> kMysteryTiles = {6, 19, 32, 45};

/// Quantum Wormholes — bidirectional teleport pair (1 fluid step).
const Map<int, int> kWormholes = {9: 35, 35: 9};

const int kShieldTurns = 2; // shield lasts 2 of the owner's turn rotations
const int kFreezeTurns = 1; // auto-freeze skips the target's next turn

String tokenKey(LudoColor color, int idx) => '${color.wire}:$idx';

/// One narration/animation event emitted by an automatic magic effect.
class MagicEvent {
  MagicEvent(this.kind, {this.detail = ''});
  final String kind; // shield|shieldBreak|freeze|frozenSkip|wormhole|mystery
  final String detail;
}

/// Auto-magic statuses for one match (no economy).
class MagicState {
  MagicState();

  /// tokenKey → remaining turn rotations of an auto Shield (break-on-contact).
  final Map<String, int> shields = {};

  /// seat → remaining frozen turns (skips roll+move).
  final Map<int, int> frozenTurns = {};

  factory MagicState.fresh(LudoState s) => MagicState();

  bool isShielded(LudoColor color, int idx) =>
      (shields[tokenKey(color, idx)] ?? 0) > 0;

  bool isFrozen(int seat) => (frozenTurns[seat] ?? 0) > 0;
}

// ── Smart auto-targeting ───────────────────────────────────────────────────

/// 0..57 progress metric (base=0 … finished=57) used to pick smart targets.
double progressOf(LudoColor color, int position) {
  if (position == kHomeBasePosition) return 0;
  if (position == kFinishedPosition) return 57;
  if (position >= kHomeStretchBase) {
    return 52 + (position - kHomeStretchBase).toDouble();
  }
  final entry = kColorEntry[color]!;
  return ((position - entry) % kTrackLength).toDouble();
}

/// The pawn that most "needs" a shield = the owner's most-advanced ACTIVE pawn
/// that is currently exposed (not on a safe square). Falls back to the most
/// advanced active pawn. Returns its token index, or null if none active.
int? bestShieldTarget(LudoState s, MagicState m, int seat) {
  final p = s.playerBySeat(seat);
  if (p == null) return null;
  int? best;
  double bestScore = -1;
  for (final t in p.tokens) {
    if (t.position == kHomeBasePosition || t.finished) continue;
    if (m.isShielded(p.color, t.index)) continue;
    var score = progressOf(p.color, t.position);
    final exposed = t.onTrack && !kSafeSquares.contains(t.position);
    if (exposed) score += 20; // prioritise the exposed runner
    if (score > bestScore) {
      bestScore = score;
      best = t.index;
    }
  }
  return best;
}

/// The most dangerous OPPONENT seat (closest to winning): most finished pawns,
/// then highest total progress. Skips teammates in 2v2. Returns seat or null.
int? mostDangerousOpponent(LudoState s, int mySeat) {
  final me = s.playerBySeat(mySeat);
  if (me == null) return null;
  int? best;
  double bestScore = -1;
  for (final p in s.players) {
    if (p.seat == mySeat) continue;
    if (s.mode == LudoMode.team2v2 && teamOf(p.color) == teamOf(me.color)) {
      continue;
    }
    if (p.finished) continue;
    final finished =
        p.tokens.where((t) => t.position == kFinishedPosition).length;
    final total = p.tokens.fold<double>(
        0, (a, t) => a + progressOf(p.color, t.position));
    final score = finished * 1000 + total;
    if (score > bestScore) {
      bestScore = score;
      best = p.seat;
    }
  }
  return best;
}

/// Nearest safe square strictly BEHIND [cell] (for the Mystery curse).
int nearestSafeBehind(int cell) {
  for (var d = 1; d <= kTrackLength; d++) {
    var c = (cell - d) % kTrackLength;
    if (c < 0) c += kTrackLength;
    if (kSafeSquares.contains(c)) return c;
  }
  return cell;
}

/// Resolve board nodes when [token] (owned by [seat]) lands: Wormhole then
/// Mystery Box. Every effect is automatic and self-targeting. Mutates state +
/// [m]; [grantExtraRoll] is called when the box rolls an extra turn.
List<MagicEvent> resolveLanding(
  LudoState s,
  MagicState m,
  int seat,
  LudoToken token,
  Random rng, {
  required void Function() grantExtraRoll,
}) {
  final out = <MagicEvent>[];
  if (!token.onTrack) return out;

  // Quantum Wormhole — teleport (1 fluid step).
  if (kWormholes.containsKey(token.position)) {
    final from = token.position;
    token.position = kWormholes[from]!;
    out.add(MagicEvent('wormhole', detail: '$from→${token.position}'));
  }

  // Mystery Box — auto loot, self-targeting.
  if (kMysteryTiles.contains(token.position)) {
    final roll = rng.nextInt(100);
    if (roll < 35) {
      // Shield → auto-applied to the pawn that needs it most.
      final idx = bestShieldTarget(s, m, seat) ?? token.index;
      final color = s.playerBySeat(seat)!.color;
      m.shields[tokenKey(color, idx)] = kShieldTurns;
      out.add(MagicEvent('mystery', detail: 'shield'));
      out.add(MagicEvent('shield', detail: tokenKey(color, idx)));
    } else if (roll < 60) {
      // Freeze → auto-hits the opponent closest to winning.
      final target = mostDangerousOpponent(s, seat);
      if (target != null) {
        m.frozenTurns[target] = kFreezeTurns;
        out.add(MagicEvent('mystery', detail: 'freeze'));
        out.add(MagicEvent('freeze', detail: '$target'));
      } else {
        grantExtraRoll();
        out.add(MagicEvent('mystery', detail: 'extraRoll'));
      }
    } else if (roll < 85) {
      grantExtraRoll();
      out.add(MagicEvent('mystery', detail: 'extraRoll'));
    } else {
      token.position = nearestSafeBehind(token.position);
      out.add(MagicEvent('mystery', detail: 'curse'));
    }
  }
  return out;
}
