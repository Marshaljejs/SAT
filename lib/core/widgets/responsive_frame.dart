import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= AppDimens.maxContentWidth) {
      return child;
    }
    return ColoredBox(
      color: AppColors.divider,
      child: Center(
        child: SizedBox(
          width: AppDimens.maxContentWidth,
          height: media.size.height,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(AppDimens.maxContentWidth, media.size.height),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 24)],
              ),
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
