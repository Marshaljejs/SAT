import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/product_grid.dart';
import '../../../data/state/app_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _onlyInStock = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.favoriteProducts;

    if (all.isEmpty) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Таңдаулы'),
        body: EmptyState(
          icon: Icons.favorite_border,
          title: 'Таңдаулылар әзірге бос',
          message: 'Ұнаған тауарды жүрек белгісімен сақтаңыз — ол осы жерде тұрады.',
          actionLabel: 'Каталогқа өту',
          onAction: () => Navigator.of(context).pushNamed(AppRoutes.catalog),
        ),
      );
    }

    final visible = _onlyInStock ? all.where((product) => product.inStock).toList() : all;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Таңдаулы',
        trailingText: Formatters.itemsCount(all.length),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 8, AppDimens.pagePadding, 28),
        children: [
          Text('Көңіліңізден шыққан заттар.', style: AppText.h1),
          const SizedBox(height: 10),
          Text(
            'Жақсы таңдаулы жоғалтпай алманыз. Ұнаған тауарды жүрек белгісімен сақтаңыз.',
            style: AppText.bodyGrey,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilterChipButton(
                label: 'Барлығы · ${all.length}',
                selected: !_onlyInStock,
                onTap: () => setState(() => _onlyInStock = false),
              ),
              const SizedBox(width: 8),
              FilterChipButton(
                label: 'Қоймада бар',
                selected: _onlyInStock,
                onTap: () => setState(() => _onlyInStock = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProductGrid(products: visible),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: AppColors.cobalt),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Таңдаулыларыңыз аккаунтыңызда сақталады.',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
