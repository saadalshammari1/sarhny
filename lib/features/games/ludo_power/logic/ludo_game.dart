import 'dart:math';

/// هندسة اللوحة 15×15 ومنطق اللعب.
/// منقول من نسخة مختبرة (هندسة سليمة، بلا حلقات).

/// مسار 52 خانة بإحداثيات الشبكة (col,row).
const List<List<int>> kPath = [
  [1, 6], [2, 6], [3, 6], [4, 6], [5, 6],
  [6, 5], [6, 4], [6, 3], [6, 2], [6, 1], [6, 0],
  [7, 0],
  [8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5],
  [9, 6], [10, 6], [11, 6], [12, 6], [13, 6], [14, 6],
  [14, 7],
  [14, 8], [13, 8], [12, 8], [11, 8], [10, 8], [9, 8],
  [8, 9], [8, 10], [8, 11], [8, 12], [8, 13], [8, 14],
  [7, 14],
  [6, 14], [6, 13], [6, 12], [6, 11], [6, 10], [6, 9],
  [5, 8], [4, 8], [3, 8], [2, 8], [1, 8], [0, 8],
  [0, 7],
  [0, 6],
];

/// نقاط انطلاق اللاعبين (يخرج كل لون قرب بيته).
const List<int> kStart = [12, 25, 38, 51];

/// ممرات البيت (6 خانات تؤدي للمركز) لكل لاعب.
const List<List<List<int>>> kHome = [
  [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6]], // ذهبي من الأعلى
  [[13, 7], [12, 7], [11, 7], [10, 7], [9, 7], [8, 7]], // أزرق من اليمين
  [[7, 13], [7, 12], [7, 11], [7, 10], [7, 9], [7, 8]], // بنفسجي من الأسفل
  [[1, 7], [2, 7], [3, 7], [4, 7], [5, 7], [6, 7]], // أخضر من اليسار
];

/// مواقع الإيواء داخل البيوت (4 مواقع لكل لاعب).
const List<List<List<double>>> kYard = [
  [[1.7, 1.7], [3.3, 1.7], [1.7, 3.3], [3.3, 3.3]], // ذهبي TL
  [[10.3, 1.7], [11.9, 1.7], [10.3, 3.3], [11.9, 3.3]], // أزرق TR
  [[10.3, 10.3], [11.9, 10.3], [10.3, 11.9], [11.9, 11.9]], // بنفسجي BR
  [[1.7, 10.3], [3.3, 10.3], [1.7, 11.9], [3.3, 11.9]], // أخضر BL
];

const Set<int> kSafe = {12, 25, 38, 51, 8, 21, 34, 47};

enum PowerType { rocket, freeze, portal, tornado }

class Special {
  final PowerType type;
  final int pairId; // للبوابات
  Special(this.type, [this.pairId = 0]);
}

class Move {
  final int piece, from, to;
  Move(this.piece, this.from, this.to);
}

/// أحداث تُبلَّغ لطبقة العرض لتشغيل التأثيرات/الرسائل.
class GameEvent {
  final String kind; // 'rocket','freeze','portal','capture','tornado','shuffle','win','turn'
  final String? message;
  final int? player;
  final int? value; // numeric payload (e.g. rocket/portal delta), localized in UI
  GameEvent(this.kind, {this.message, this.player, this.value});
}

class LudoGame {
  final Random _rng = Random();

  /// اللاعب البشري = 3 (الأخضر، أسفل-يسار).
  static const int humanPlayer = 3;
  static const int shuffleEvery = 3;

  /// تقدّم كل قطعة: 0=البيت، 1..51=المسار، 52..57=ممر البيت، 57=المركز.
  late List<List<int>> pieces;
  late List<int> frozen; // أدوار التجميد المتبقية لكل لاعب
  late Map<int, Special> specials;
  late int current;
  int dice = 0;
  bool rolled = false;
  bool gameOver = false;
  int _rollsSinceShuffle = 0;

  /// تشغيل القدرات الخاصة على اللوحة (لودو قدرات) أو إيقافها (لودو عادي).
  final bool withPowers;

  final void Function(GameEvent)? onEvent;
  LudoGame({this.onEvent, this.withPowers = true}) {
    reset();
  }

  void reset() {
    pieces = List.generate(4, (_) => [0, 0, 0, 0]);
    frozen = [0, 0, 0, 0];
    current = humanPlayer;
    dice = 0;
    rolled = false;
    gameOver = false;
    _rollsSinceShuffle = 0;
    _shuffleSpecials();
  }

  // ---------- الخانات الخاصة ----------
  void _shuffleSpecials() {
    specials = {};
    if (!withPowers) return; // الوضع العادي: بلا قدرات
    final pool = <int>[];
    for (int i = 0; i < 52; i++) {
      if (!kSafe.contains(i)) pool.add(i);
    }
    pool.shuffle(_rng);
    int k = 0;
    specials[pool[k++]] = Special(PowerType.portal, 0);
    specials[pool[k++]] = Special(PowerType.portal, 0);
    specials[pool[k++]] = Special(PowerType.rocket);
    specials[pool[k++]] = Special(PowerType.rocket);
    specials[pool[k++]] = Special(PowerType.freeze);
    specials[pool[k++]] = Special(PowerType.tornado);
  }

  // ---------- تحويلات ----------
  int? mainCellOf(int player, int prog) {
    if (prog >= 1 && prog <= 51) return (kStart[player] + (prog - 1)) % 52;
    return null;
  }

  int? progFromMain(int player, int cellIdx) {
    for (int pr = 1; pr <= 51; pr++) {
      if ((kStart[player] + (pr - 1)) % 52 == cellIdx) return pr;
    }
    return null;
  }

  /// إحداثيات الشبكة (col,row مركز الخلية) لقطعة.
  List<double> gridOf(int player, int prog, int slot) {
    if (prog == 0) {
      final y = kYard[player][slot];
      return [y[0], y[1]];
    }
    if (prog >= 1 && prog <= 51) {
      final idx = (kStart[player] + (prog - 1)) % 52;
      final g = kPath[idx];
      return [g[0] + 0.5, g[1] + 0.5];
    }
    if (prog >= 52 && prog <= 57) {
      final hi = prog - 52;
      if (hi < 6) {
        final g = kHome[player][hi];
        return [g[0] + 0.5, g[1] + 0.5];
      }
    }
    return [7.5, 7.5];
  }

  // ---------- الحركة ----------
  List<Move> legalMoves(int player, int d) {
    final moves = <Move>[];
    for (int i = 0; i < 4; i++) {
      final pr = pieces[player][i];
      if (pr == 0) {
        if (d == 6) moves.add(Move(i, 0, 1));
        continue;
      }
      if (pr == 57) continue;
      final t = pr + d;
      if (t > 57) continue;
      moves.add(Move(i, pr, t));
    }
    return moves;
  }

  bool isMovable(int player, int i) {
    if (player != current || !rolled || gameOver) return false;
    return legalMoves(player, dice).any((m) => m.piece == i);
  }

  int rollDice() {
    dice = 1 + _rng.nextInt(6);
    rolled = true;
    return dice;
  }

  /// يطبّق الحركة ويعالج القدرة والأكل. يرجّع true إذا حصل اللاعب على دور إضافي.
  bool applyMove(int player, Move m) {
    pieces[player][m.piece] = m.to;
    _resolveSpecial(player, m.piece);

    // الأكل بعد الاستقرار
    bool captured = false;
    final prog = pieces[player][m.piece];
    final mc = mainCellOf(player, prog);
    if (mc != null && !kSafe.contains(mc)) {
      for (int p = 0; p < 4; p++) {
        if (p == player) continue;
        for (int i = 0; i < 4; i++) {
          if (mainCellOf(p, pieces[p][i]) == mc) {
            pieces[p][i] = 0;
            captured = true;
          }
        }
      }
    }
    if (captured) onEvent?.call(GameEvent('capture'));

    if (pieces[player].every((x) => x == 57)) {
      gameOver = true;
      onEvent?.call(GameEvent('win', player: player));
      return false;
    }

    final reachedCenter = (prog == 57);
    return (dice == 6) || captured || reachedCenter;
  }

  /// تفعيل الخانة الخاصة مرة واحدة فقط (لا تسلسل/تأرجح).
  void _resolveSpecial(int player, int pieceIdx) {
    final prog = pieces[player][pieceIdx];
    final mc = mainCellOf(player, prog);
    if (mc == null || !specials.containsKey(mc)) return;
    final sp = specials[mc]!;

    switch (sp.type) {
      case PowerType.rocket:
        final boost = 2 + _rng.nextInt(4); // 2..5
        final t = min(prog + boost, 57);
        pieces[player][pieceIdx] = t;
        onEvent?.call(GameEvent('rocket', value: t - prog, player: player));
        break;
      case PowerType.freeze:
        frozen[player] = 2;
        onEvent?.call(GameEvent('freeze', player: player));
        break;
      case PowerType.portal:
        int? other;
        for (final e in specials.entries) {
          if (e.key != mc && e.value.type == PowerType.portal && e.value.pairId == sp.pairId) {
            other = e.key;
            break;
          }
        }
        if (other == null) return;
        final np = progFromMain(player, other);
        if (np == null) return;
        final diff = np - prog;
        pieces[player][pieceIdx] = np;
        onEvent?.call(GameEvent('portal', value: diff, player: player));
        break;
      case PowerType.tornado:
        final cell = mainCellOf(player, prog);
        // Respect safe squares like the normal capture rule above — a pawn on
        // a star (kSafe) cannot be sent home by the tornado.
        if (cell != null && !kSafe.contains(cell)) {
          for (int p = 0; p < 4; p++) {
            if (p == player) continue;
            for (int i = 0; i < 4; i++) {
              if (mainCellOf(p, pieces[p][i]) == cell) pieces[p][i] = 0;
            }
          }
        }
        onEvent?.call(GameEvent('tornado', player: player));
        break;
    }
  }

  /// إنهاء الدور والانتقال للاعب التالي (مع احترام التجميد وتبديل الخانات).
  void endTurn() {
    if (gameOver) return;
    rolled = false;
    dice = 0;
    _rollsSinceShuffle++;
    if (_rollsSinceShuffle >= shuffleEvery) {
      _rollsSinceShuffle = 0;
      _shuffleSpecials();
      onEvent?.call(GameEvent('shuffle'));
    }
    int guard = 0;
    do {
      current = (current + 1) % 4;
      guard++;
      if (frozen[current] > 0) {
        frozen[current]--;
      } else {
        break;
      }
    } while (guard < 8);
    onEvent?.call(GameEvent('turn', player: current));
  }

  /// منطق بوت بسيط لكن معقول.
  Move botChoose(List<Move> moves) {
    Move best = moves.first;
    double bestScore = -1e9;
    for (final m in moves) {
      double s = 0;
      if (m.from == 0) s += 30;
      if (m.to == 57) s += 60;
      if (m.to >= 52) s += 20;
      final mc = mainCellOf(current, m.to);
      if (mc != null && !kSafe.contains(mc)) {
        for (int p = 0; p < 4; p++) {
          if (p == current) continue;
          for (int i = 0; i < 4; i++) {
            if (mainCellOf(p, pieces[p][i]) == mc) s += 50;
          }
        }
      }
      if (mc != null && specials.containsKey(mc)) {
        switch (specials[mc]!.type) {
          case PowerType.freeze:
            s -= 25;
            break;
          case PowerType.rocket:
            s += 18;
            break;
          case PowerType.tornado:
            s += 14;
            break;
          case PowerType.portal:
            s += 6;
            break;
        }
      }
      if (mc != null && kSafe.contains(mc)) s += 8;
      s += m.to * 0.6 + _rng.nextDouble() * 3;
      if (s > bestScore) {
        bestScore = s;
        best = m;
      }
    }
    return best;
  }
}
