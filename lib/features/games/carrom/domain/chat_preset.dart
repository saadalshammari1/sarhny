/// Quick-chat preset كما يبعثها السيرفر — مفتاح + ترجمات + إيموجي.
class CarromChatPreset {
  const CarromChatPreset({
    required this.key,
    required this.ar,
    required this.en,
    required this.emoji,
  });

  final String key;
  final String ar;
  final String en;
  final String emoji;

  /// يختار النص حسب اللغة الحالية.
  String label(String langCode) => langCode.startsWith('ar') ? ar : en;

  factory CarromChatPreset.fromJson(String key, Map<String, dynamic> j) =>
      CarromChatPreset(
        key: key,
        ar: '${j['ar'] ?? ''}',
        en: '${j['en'] ?? key}',
        emoji: '${j['emoji'] ?? '💬'}',
      );
}

/// محفظة Lifetime من السيرفر — النقاط + رسم الدخول + الجائزة.
class CarromWallet {
  const CarromWallet({
    required this.points,
    required this.entryFee,
    required this.pot,
  });
  final int points;
  final int entryFee;
  final int pot;

  factory CarromWallet.fromJson(Map<String, dynamic> j) => CarromWallet(
        points: (j['points'] as num?)?.toInt() ?? 0,
        entryFee: (j['entry_fee'] as num?)?.toInt() ?? 300,
        pot: (j['pot'] as num?)?.toInt() ?? 600,
      );
}
