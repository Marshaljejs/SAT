import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class AppBadge extends StatelessWidget {
  const AppBadge(
    this.text, {
    super.key,
    this.background = AppColors.softCobalt,
    this.foreground = AppColors.cobalt,
  });

  const AppBadge.success(this.text, {super.key})
      : background = AppColors.softSuccess,
        foreground = AppColors.success;

  const AppBadge.citrus(this.text, {super.key})
      : background = AppColors.citrus,
        foreground = AppColors.ink;

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppText.captionStrong.copyWith(color: foreground, fontSize: 11),
      ),
    );
  }
}
