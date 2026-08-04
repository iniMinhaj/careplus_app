import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  static TextStyle get f57w400 => TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      );

  static TextStyle get f45w400 =>
      TextStyle(fontSize: 45.sp, fontWeight: FontWeight.w400, height: 1.16);

  static TextStyle get f32w600 =>
      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w600, height: 1.25);

  static TextStyle get f28w600 =>
      TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600, height: 1.29);

  static TextStyle get f24w600 =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600, height: 1.33);

  static TextStyle get f22w500 =>
      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500, height: 1.27);

  static TextStyle get f16w500 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get f14w500 => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  static TextStyle get f16w400 => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get f14w400 => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      );

  static TextStyle get f12w400 => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );

  static TextStyle get f12w500 => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );

  static TextStyle get f11w500 => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      );
}
