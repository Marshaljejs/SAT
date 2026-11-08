import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  const AppText._();

  static TextStyle _style(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get display => _style(96, FontWeight.w300, height: 1, letterSpacing: -3);
  static TextStyle get logo => _style(26, FontWeight.w500, letterSpacing: -0.6);
  static TextStyle get logoLarge => _style(40, FontWeight.w300, letterSpacing: -1);
  static TextStyle get h1 => _style(28, FontWeight.w600, height: 1.25, letterSpacing: -0.4);
  static TextStyle get h2 => _style(22, FontWeight.w600, height: 1.3, letterSpacing: -0.2);
  static TextStyle get h3 => _style(18, FontWeight.w600, height: 1.3);
  static TextStyle get title => _style(16, FontWeight.w600);
  static TextStyle get body => _style(14, FontWeight.w400, height: 1.45);
  static TextStyle get bodyGrey => _style(14, FontWeight.w400, color: AppColors.grey, height: 1.45);
  static TextStyle get bodyStrong => _style(14, FontWeight.w600);
  static TextStyle get caption => _style(12, FontWeight.w400, color: AppColors.grey, height: 1.4);
  static TextStyle get captionStrong => _style(12, FontWeight.w600);
  static TextStyle get label => _style(13, FontWeight.w500);
  static TextStyle get overline => _style(11, FontWeight.w500, color: AppColors.grey, letterSpacing: 0.9);
  static TextStyle get button => _style(15, FontWeight.w600, color: AppColors.white);
  static TextStyle get link => _style(13, FontWeight.w500, color: AppColors.cobalt);
  static TextStyle get price => _style(24, FontWeight.w600, letterSpacing: -0.3);
  static TextStyle get cardTitle => _style(13, FontWeight.w600, height: 1.3);
  static TextStyle get cardPrice => _style(14, FontWeight.w600, height: 1.3);
  static TextStyle get input => _style(15, FontWeight.w400);
  static TextStyle get hint => _style(15, FontWeight.w400, color: AppColors.hint);
}
