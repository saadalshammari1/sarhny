import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// "منذ ٣ ساعات" (عربي)
  static String relativeArabic(DateTime utc) {
    final diff = DateTime.now().difference(utc);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${_arDigits(diff.inMinutes)} د';
    if (diff.inHours < 24) return 'منذ ${_arDigits(diff.inHours)} س';
    if (diff.inDays < 7) return 'منذ ${_arDigits(diff.inDays)} ي';
    return DateFormat('d MMM y', 'ar').format(utc);
  }

  static String compactNumber(int n) {
    if (n < 1000) return _arDigits(n);
    if (n < 1_000_000) return '${_arDigits((n / 1000).floor())}ك';
    return '${_arDigits((n / 1_000_000).floor())}م';
  }

  static String _arDigits(int n) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : ar[d];
    }).join();
  }
}
