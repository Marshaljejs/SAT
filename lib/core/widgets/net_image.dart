import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NetImage extends StatelessWidget {
  const NetImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: const _Placeholder(icon: Icons.image_outlined),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const _Placeholder(icon: Icons.image_outlined);
        },
        errorBuilder: (context, error, stackTrace) {
          return const _Placeholder(icon: Icons.image_not_supported_outlined);
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.hint),
    );
  }
}
