import 'package:flutter/material.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../logic/ludo_game.dart';
import '../theme/cosmetics.dart';
import '../theme/ludo_theme.dart';
import '../widgets/board_painter.dart';
import '../widgets/pawn_widget.dart';
import 'ludo_power_screen.dart';

const _bgTop = Color(0xFF1B1740);
const _bgBottom = Color(0xFF0A0A1E);
const _accent = Color(0xFF7B3FE4);
const _panel = Color(0xFF14102E);

/// لوبي لودو — اختيار نوع اللعب + الطاولات والفرسان، ثم العب.
class LudoPowerLobby extends StatefulWidget {
  const LudoPowerLobby({super.key});
  @override
  State<LudoPowerLobby> createState() => _LudoPowerLobbyState();
}

class _LudoPowerLobbyState extends State<LudoPowerLobby> {
  bool _withPowers = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -0.8), radius: 1.3, colors: [_bgTop, _bgBottom]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  Text(l.ludoTitle, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              _hero(l),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LudoPowerCosmeticsPage())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accent, width: 1.2),
                  ),
                  child: Row(children: [
                    const Text('🎨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.ludoCustomizeSub,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    const Icon(Icons.chevron_left_rounded, color: Colors.white54),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Text(l.ludoPlayType,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(children: [
                _typeCard(l.ludoClassic, '🎲', l.ludoClassicSub, !_withPowers, () => setState(() => _withPowers = false)),
                const SizedBox(width: 12),
                _typeCard(l.ludoPowers, '🚀', l.ludoPowersSub, _withPowers, () => setState(() => _withPowers = true)),
              ]),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l.ludoPlay, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => LudoPowerPage(withPowers: _withPowers))),
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(AppLocalizations l) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFC59B41), Color(0xFF7A531A)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          const Icon(Icons.casino_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(child: Text(l.ludoRoyalSub,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
        ]),
      );

  Widget _typeCard(String title, String emoji, String sub, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? _accent : _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? Colors.white : Colors.white12, width: selected ? 1.6 : 1),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ]),
        ),
      ),
    );
  }
}

/// صفحة اختيار الطاولة (٣) والفارس (٤) مع معاينة حيّة.
class LudoPowerCosmeticsPage extends StatefulWidget {
  const LudoPowerCosmeticsPage({super.key});
  @override
  State<LudoPowerCosmeticsPage> createState() => _LudoPowerCosmeticsPageState();
}

class _LudoPowerCosmeticsPageState extends State<LudoPowerCosmeticsPage> {
  LudoPowerPrefs? _prefs;
  PowerSkin _skin = PowerSkin.royal;
  KnightStyle _knight = KnightStyle.classic;
  final _previewGame = LudoGame(withPowers: false);

  @override
  void initState() {
    super.initState();
    LudoPowerPrefs.instance().then((p) {
      setState(() {
        _prefs = p;
        _skin = p.skin;
        _knight = p.knight;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: _bgBottom,
        foregroundColor: Colors.white,
        title: Text(l.ludoBoardsKnights),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(l.ludoPickBoard, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: PowerSkin.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _skinCard(PowerSkin.values[i], l),
            ),
          ),
          const SizedBox(height: 26),
          Text(l.ludoPickKnight, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [for (final k in KnightStyle.values) _knightCard(k, l)],
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _skinCard(PowerSkin skin, AppLocalizations l) {
    final selected = _skin == skin;
    return GestureDetector(
      onTap: () {
        setState(() => _skin = skin);
        _prefs?.setSkin(skin);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _accent : Colors.white12, width: selected ? 2.4 : 1),
          boxShadow: selected ? [BoxShadow(color: _accent.withValues(alpha: 0.5), blurRadius: 14)] : null,
        ),
        child: Column(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: SkinPalette.of(skin).frame),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: BoardPainter(_previewGame, skin: skin),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (selected) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_circle, color: _accent, size: 16)),
            Flexible(child: Text(_skinName(skin, l), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
          ]),
        ]),
      ),
    );
  }

  Widget _knightCard(KnightStyle style, AppLocalizations l) {
    final selected = _knight == style;
    return GestureDetector(
      onTap: () {
        setState(() => _knight = style);
        _prefs?.setKnight(style);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _accent : Colors.white12, width: selected ? 2.4 : 1),
          boxShadow: selected ? [BoxShadow(color: _accent.withValues(alpha: 0.5), blurRadius: 14)] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final c in BoardScheme.playerColors)
                SizedBox(width: 30, child: PawnWidget(colorKey: c, size: 28, style: style)),
            ],
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (selected) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_circle, color: _accent, size: 16)),
            Text(_knightName(style, l), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ]),
      ),
    );
  }

  String _skinName(PowerSkin s, AppLocalizations l) {
    switch (s) {
      case PowerSkin.royal:
        return l.ludoSkinRoyal;
      case PowerSkin.neon:
        return l.ludoSkinNeon;
      case PowerSkin.arabian:
        return l.ludoSkinArabian;
    }
  }

  String _knightName(KnightStyle s, AppLocalizations l) {
    switch (s) {
      case KnightStyle.classic:
        return l.ludoKnightClassic;
      case KnightStyle.knight:
        return l.ludoKnightKnight;
      case KnightStyle.sorcerer:
        return l.ludoKnightSorcerer;
      case KnightStyle.crown:
        return l.ludoKnightCrown;
    }
  }
}
