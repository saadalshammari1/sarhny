import 'package:flutter/material.dart';

import '../data/ludo3_prefs.dart';
import '../domain/ludo_cosmetics.dart';
import '../engine/ludo_models.dart';
import 'ludo3_board.dart';

/// Cosmetics picker — choose 1 of 3 board skins and 1 of 4 pawn ("knight")
/// styles. Live previews; selection persists via [Ludo3Prefs].
class Ludo3CosmeticsPage extends StatefulWidget {
  const Ludo3CosmeticsPage({super.key});

  @override
  State<Ludo3CosmeticsPage> createState() => _Ludo3CosmeticsPageState();
}

class _Ludo3CosmeticsPageState extends State<Ludo3CosmeticsPage> {
  Ludo3Prefs? _prefs;
  LudoBoardSkin _skin = LudoBoardSkin.royal;
  LudoPawnStyle _pawn = LudoPawnStyle.classic;

  @override
  void initState() {
    super.initState();
    Ludo3Prefs.instance().then((p) {
      setState(() {
        _prefs = p;
        _skin = p.boardSkin;
        _pawn = p.pawnStyle;
      });
    });
  }

  // A small populated board for previews.
  late final LudoState _previewState =
      LudoState.local(mode: LudoMode.p4, names: const ['', '', '', '']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1117),
        foregroundColor: Colors.white,
        title: const Text('الطاولات والفرسان'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _label('اختر الطاولة'),
          const SizedBox(height: 12),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LudoBoardSkin.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _boardCard(LudoBoardSkin.values[i]),
            ),
          ),
          const SizedBox(height: 26),
          _label('اختر الفرسان'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              for (final st in LudoPawnStyle.values) _pawnCard(st),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold));

  Widget _boardCard(LudoBoardSkin skin) {
    final selected = _skin == skin;
    return GestureDetector(
      onTap: () {
        setState(() => _skin = skin);
        _prefs?.setBoard(skin);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2330),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF7B3FE4) : Colors.white12,
            width: selected ? 2.4 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF7B3FE4).withValues(alpha: 0.5), blurRadius: 14)]
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: IgnorePointer(
                  child: Ludo3Board(
                    state: _previewState,
                    movable: const [],
                    activeSeat: -1,
                    interactive: false,
                    onTapToken: (_) {},
                    skin: skin,
                    pawnStyle: _pawn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.check_circle, color: Color(0xFF7B3FE4), size: 16),
                  ),
                Flexible(
                  child: Text(skin.nameAr,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pawnCard(LudoPawnStyle style) {
    final selected = _pawn == style;
    return GestureDetector(
      onTap: () {
        setState(() => _pawn = style);
        _prefs?.setPawn(style);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2330),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF7B3FE4) : Colors.white12,
            width: selected ? 2.4 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF7B3FE4).withValues(alpha: 0.5), blurRadius: 14)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final c in LudoColor.values)
                  LudoPawnPreview(color: c, style: style, size: 40),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.check_circle, color: Color(0xFF7B3FE4), size: 16),
                  ),
                Text(style.nameAr,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
