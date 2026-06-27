import 'package:flutter/material.dart';

import '../engine/ludo_ai.dart';
import '../engine/ludo_models.dart';
import 'ludo3_cosmetics_page.dart';
import 'ludo3_local_match_page.dart';
import 'ludo3_magic_match_page.dart';

/// Ludo lobby — pick the variant (classic / magic), the table size (1v1 / 2v2 /
/// 4-player) and the difficulty, then start. Online + magic land in later
/// phases; their options show a "soon" state until wired.
class Ludo3LobbyPage extends StatefulWidget {
  const Ludo3LobbyPage({super.key});

  @override
  State<Ludo3LobbyPage> createState() => _Ludo3LobbyPageState();
}

class _Ludo3LobbyPageState extends State<Ludo3LobbyPage> {
  LudoMode _mode = LudoMode.p2;
  LudoDifficulty _difficulty = LudoDifficulty.normal;
  bool _magic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12161E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12161E),
        foregroundColor: Colors.white,
        title: const Text('لودو'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _hero(),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const Ludo3CosmeticsPage(),
              )),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2330),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF7B3FE4), width: 1.2),
                ),
                child: Row(
                  children: const [
                    Text('🎨', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('الطاولات والفرسان — خصّص شكلك',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Icon(Icons.chevron_left_rounded, color: Colors.white54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _label('النوع'),
            const SizedBox(height: 10),
            _segment<bool>(
              value: _magic,
              onChanged: (m) => setState(() => _magic = m),
              options: const [
                (false, 'كلاسيكي', Icons.casino_rounded),
                (true, 'سحري ✨', Icons.auto_awesome_rounded),
              ],
            ),
            const SizedBox(height: 22),
            _label('عدد اللاعبين'),
            const SizedBox(height: 10),
            _segment<LudoMode>(
              value: _mode,
              onChanged: (m) => setState(() => _mode = m),
              options: const [
                (LudoMode.p2, '١ ضد ١', Icons.person_rounded),
                (LudoMode.team2v2, '٢ ضد ٢', Icons.groups_rounded),
                (LudoMode.p4, '٤ لاعبين', Icons.grid_view_rounded),
              ],
            ),
            const SizedBox(height: 22),
            _label('مستوى الذكاء'),
            const SizedBox(height: 10),
            _segment<LudoDifficulty>(
              value: _difficulty,
              onChanged: (d) => setState(() => _difficulty = d),
              options: const [
                (LudoDifficulty.easy, 'سهل', Icons.sentiment_satisfied_rounded),
                (LudoDifficulty.normal, 'عادي', Icons.psychology_rounded),
                (LudoDifficulty.hard, 'صعب', Icons.local_fire_department_rounded),
              ],
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2FA84F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.smart_toy_rounded),
              label: const Text('العب ضد الذكاء',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _startLocal,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.public_rounded),
              label: const Text('أونلاين — قريباً'),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اللعب أونلاين قيد التجهيز')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2475E0), Color(0xFF2FA84F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.casino_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لودو',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('ارمِ النرد، اطلع قطعك، وكُل خصومك قبل ما توصل البيت.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold));

  Widget _segment<T>({
    required T value,
    required ValueChanged<T> onChanged,
    required List<(T, String, IconData)> options,
  }) {
    return Row(
      children: [
        for (final (i, opt) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: value == opt.$1
                      ? const Color(0xFF2475E0)
                      : const Color(0xFF1B2330),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: value == opt.$1 ? Colors.white : Colors.white12,
                    width: value == opt.$1 ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(opt.$3,
                        color: value == opt.$1 ? Colors.white : Colors.white54,
                        size: 22),
                    const SizedBox(height: 6),
                    Text(opt.$2,
                        style: TextStyle(
                            color:
                                value == opt.$1 ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _startLocal() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _magic
          ? Ludo3MagicMatchPage(mode: _mode, difficulty: _difficulty)
          : Ludo3LocalMatchPage(mode: _mode, difficulty: _difficulty),
    ));
  }
}
