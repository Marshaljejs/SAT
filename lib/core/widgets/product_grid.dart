import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../data/state/app_state.dart';
import '../constants/app_dimens.dart';
import '../routes/app_routes.dart';
import '../utils/responsive.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.gridColumns(constraints.maxWidth);
        const spacing = AppDimens.gridSpacing;
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: ProductCard.heightFor(context, tileWidth),
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              isFavorite: state.isFavorite(product.id),
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.productDetail,
                arguments: product.id,
              ),
              onFavorite: () => state.toggleFavorite(product.id),
            );
          },
        );
      },
    );
  }
}
