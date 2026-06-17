/// نوع قطعة الكيرم — أبيض / أسود / ملكة / الستراكر.
enum CarromPieceColor { white, black, queen, striker }

extension CarromPieceColorParse on CarromPieceColor {
  static CarromPieceColor parse(String raw) {
    switch (raw.toLowerCase()) {
      case 'white':
        return CarromPieceColor.white;
      case 'black':
        return CarromPieceColor.black;
      case 'queen':
        return CarromPieceColor.queen;
      case 'striker':
        return CarromPieceColor.striker;
      default:
        return CarromPieceColor.white;
    }
  }

  String get wire {
    switch (this) {
      case CarromPieceColor.white:
        return 'white';
      case CarromPieceColor.black:
        return 'black';
      case CarromPieceColor.queen:
        return 'queen';
      case CarromPieceColor.striker:
        return 'striker';
    }
  }
}

/// قطعة على رقعة الكيرم. الإحداثيات بالـ virtual board units
/// (الخادم يستخدم 600×600 — الكليفر هو من يحوّل لـ pixels).
class CarromPiece {
  const CarromPiece({
    required this.id,
    required this.color,
    required this.x,
    required this.y,
    this.pocketed = false,
    this.vx = 0,
    this.vy = 0,
  });

  final int id;
  final CarromPieceColor color;
  final double x;
  final double y;
  final bool pocketed;
  final double vx;
  final double vy;

  CarromPiece copyWith({
    double? x,
    double? y,
    bool? pocketed,
    double? vx,
    double? vy,
  }) =>
      CarromPiece(
        id: id,
        color: color,
        x: x ?? this.x,
        y: y ?? this.y,
        pocketed: pocketed ?? this.pocketed,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
      );

  factory CarromPiece.fromJson(Map<String, dynamic> j) => CarromPiece(
        id: (j['id'] as num).toInt(),
        color: CarromPieceColorParse.parse('${j['color']}'),
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        pocketed: j['pocketed'] == true,
        vx: (j['vx'] as num?)?.toDouble() ?? 0,
        vy: (j['vy'] as num?)?.toDouble() ?? 0,
      );
}
