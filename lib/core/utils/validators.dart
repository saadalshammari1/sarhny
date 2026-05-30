class Validators {
  Validators._();

  static String? required(String? v, {String? msg}) {
    if (v == null || v.trim().isEmpty) return msg ?? 'هذا الحقل مطلوب';
    return null;
  }

  static String? minLength(String? v, int min, {String? msg}) {
    if (v == null || v.length < min) return msg ?? 'يجب أن يحتوي على $min أحرف على الأقل';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return null;
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v);
    return ok ? null : 'بريد إلكتروني غير صالح';
  }

  static String? username(String? v) {
    if (v == null || v.isEmpty) return 'اسم المستخدم مطلوب';
    final ok = RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(v);
    return ok ? null : 'يجب أن يكون بين 3-20 حرفاً (أحرف لاتينية وأرقام و _)';
  }
}
