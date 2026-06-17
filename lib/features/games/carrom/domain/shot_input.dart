/// مدخل تصويب — يُرسل عبر الـ WebSocket.
class CarromShotInput {
  const CarromShotInput({
    required this.strikerX,
    required this.strikerY,
    required this.angleRad,
    required this.power,
  });

  /// إحداثيات الستراكر بالـ virtual units (0..600).
  final double strikerX;
  final double strikerY;
  /// الزاوية بالراديان — 0 = يمين، π/2 = أسفل.
  final double angleRad;
  /// قوة التصويب (0..1) — السيرفر يضربها بـ max impulse.
  final double power;

  Map<String, dynamic> toJson() => {
        'type': 'shoot',
        'striker_x': strikerX,
        'striker_y': strikerY,
        'angle_rad': angleRad,
        'power': power.clamp(0.0, 1.0),
      };
}
