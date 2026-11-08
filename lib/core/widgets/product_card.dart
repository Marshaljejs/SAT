import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/formatters.dart';
import 'favorite_button.dart';
import 'net_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  static double heightFor(BuildContext context, double width) {
    return width + MediaQuery.textScalerOf(context).scale(80);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppDimens.radiusLarge);
    return Material(
      color: AppColors.white,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: NetImage(
                        url: product.image,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(isFavorite: isFavorite, onPressed: onFavorite),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                product.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption,
              ),
              const SizedBox(height: 6),
              Text(Formatters.price(product.price), style: AppText.cardPrice),
            ],
          ),
        ),
      ),
    );
  }
}
