import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_text.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return AppBar(
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      titleSpacing: canPop ? 0 : AppDimens.pagePadding,
      title: Text(title),
      actions: [
        if (trailingText != null)
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.pagePadding),
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTrailingTap,
                child: Text(trailingText!, style: AppText.link),
              ),
            ),
          ),
      ],
    );
  }
}
