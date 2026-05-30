import 'package:flutter_screenutil/flutter_screenutil.dart';

/// نظام المسافات الموحّد — يستخدم flutter_screenutil للتجاوب.
class AppSpacing {
  AppSpacing._();

  // مسافات أساسية
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 48.w;

  // ارتفاعات
  static double get hxs => 4.h;
  static double get hsm => 8.h;
  static double get hmd => 12.h;
  static double get hlg => 16.h;
  static double get hxl => 20.h;
  static double get hxxl => 24.h;

  // نصف أقطار (border radius)
  static double get rSm => 6.r;
  static double get rMd => 10.r;
  static double get rLg => 14.r;
  static double get rXl => 18.r;
  static double get rXxl => 22.r;
  static double get rFull => 999.r;

  // ارتفاعات مكونات شائعة
  static double get buttonHeight => 50.h;
  static double get inputHeight => 52.h;
  static double get appBarHeight => 56.h;
  static double get bottomNavHeight => 64.h;
  static double get avatarSm => 32.r;
  static double get avatarMd => 44.r;
  static double get avatarLg => 80.r;
}
