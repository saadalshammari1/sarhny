/// Quick-chat preset لـ Ludo — نفس صيغة Carrom.
class LudoChatPreset {
  const LudoChatPreset({
    required this.key,
    required this.ar,
    required this.en,
    required this.emoji,
  });

  final String key;
  final String ar;
  final String en;
  final String emoji;

  String label(String langCode) => langCode.startsWith('ar') ? ar : en;

  factory LudoChatPreset.fromJson(String key, Map<String, dynamic> j) =>
      LudoChatPreset(
        key: key,
        ar: '${j['ar'] ?? ''}',
        en: '${j['en'] ?? key}',
        emoji: '${j['emoji'] ?? '💬'}',
      );
}

/// محفظة Ludo — نقاط + entry fee + pot للوضع الحالي.
class LudoWallet {
  const LudoWallet({
    required this.points,
    required this.entryFee,
    required this.pot,
  });
  final int points;
  final int entryFee;
  final int pot;

  factory LudoWallet.fromJson(Map<String, dynamic> j) => LudoWallet(
        points: (j['points'] as num?)?.toInt() ?? 0,
        entryFee: (j['entry_fee'] as num?)?.toInt() ?? 150,
        pot: (j['pot'] as num?)?.toInt() ?? 600,
      );
}

/// نتيجة نهائية للمباراة — مرسلة في game_over event.
class LudoRankEntry {
  const LudoRankEntry({
    required this.userId,
    required this.seat,
    required this.rank,
    required this.payout,
  });
  final int userId;
  final int seat;
  final int rank;
  final int payout;

  factory LudoRankEntry.fromJson(Map<String, dynamic> j) => LudoRankEntry(
        userId: (j['user_id'] as num?)?.toInt() ?? 0,
        seat: (j['seat'] as num?)?.toInt() ?? 0,
        rank: (j['rank'] as num?)?.toInt() ?? 4,
        payout: (j['payout'] as num?)?.toInt() ?? 0,
      );
}
