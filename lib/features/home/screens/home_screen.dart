import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../data/location/location_service.dart';
import '../../location/location_dialogs.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/net_image.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/state/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCatalog(BuildContext context, [Category? category]) {
    Navigator.of(context).pushNamed(AppRoutes.catalog, arguments: category);
  }

  Future<void> _detectCity(BuildContext context) async {
    final state = context.read<AppState>();
    final service = LocationService();
    final result = await service.detect();
    if (!context.mounted) {
      return;
    }
    final found = result.location;
    if (found == null) {
      await showLocationFailure(
        context,
        result.failure ?? LocationFailure.unavailable,
        service: service,
        onRetry: () => _detectCity(context),
      );
      return;
    }
    if (found.city.isEmpty) {
      showAppSnack(context, 'Қала анықталмады. Тізімнен таңдаңыз.', isError: true);
      return;
    }
    if (!AppConfig.cities.contains(found.city)) {
      showAppSnack(context, '«${found.city}» қаласына жеткізу әзірге жоқ.', isError: true);
      return;
    }
    await state.setCity(found.city);
    if (!context.mounted) {
      return;
    }
    showAppSnack(context, 'Жеткізу қаласы: ${found.city}');
  }

  Future<void> _pickCity(BuildContext context) async {
    final state = context.read<AppState>();
    final city = await showAppSheet<String>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Жеткізу қаласы', style: AppText.h2),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location, color: AppColors.cobalt),
            title: Text('Орынды автоматты анықтау', style: AppText.link),
            onTap: () => Navigator.of(sheetContext).pop('__auto__'),
          ),
          for (final item in AppConfig.cities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item, style: AppText.body),
              trailing: item == state.city
                  ? const Icon(Icons.check, color: AppColors.cobalt)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(item),
            ),
        ],
      ),
    );
    if (city == '__auto__') {
      if (!context.mounted) {
        return;
      }
      await _detectCity(context);
      return;
    }
    if (city != null) {
      state.setCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final popular = state.products.popular();
    final featured = popular.isEmpty ? null : popular.first;
    const itemWidth = 164.0;
    final listHeight = ProductCard.heightFor(context, itemWidth);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 12, AppDimens.pagePadding, 24),
          children: [
            Row(
              children: [
                Text('SÄT.', style: AppText.logo),
                const SizedBox(width: 18),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pickCity(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ЖЕТКІЗУ ҚАЛАСЫ', style: AppText.overline.copyWith(fontSize: 9)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                state.city,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.captionStrong,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => showAppSnack(context, 'Жаңа хабарландырулар жоқ'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                onTap: () => state.setTab(1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text('Нені іздеп жүрсіз?', style: AppText.hint),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (featured != null) ...[
              _PromoBanner(
                product: featured,
                onTap: () => _openCatalog(context),
              ),
              const SizedBox(height: 24),
            ],
            Text('Өз санатыңызды табыңыз', style: AppText.h3),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipButton(
                      label: 'Барлығы',
                      selected: true,
                      onTap: () => _openCatalog(context),
                    ),
                  ),
                  for (final category in state.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChipButton(
                        label: category.name,
                        selected: false,
                        onTap: () => _openCatalog(context, category),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Көптің таңдауы',
              actionLabel: 'Барлығын көру',
              onAction: () => _openCatalog(context),
            ),
            const SizedBox(height: 12),
            if (popular.isEmpty)
              const InfoBanner(
                icon: Icons.inventory_2_outlined,
                text: 'Каталог әзірге бос. Профиль бөлімінен тауар қосуға болады.',
              )
            else
              SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: popular.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppDimens.gridSpacing),
                itemBuilder: (context, index) {
                  final product = popular[index];
                  return SizedBox(
                    width: itemWidth,
                    child: ProductCard(
                      product: product,
                      isFavorite: state.isFavorite(product.id),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.productDetail,
                        arguments: product.id,
                      ),
                      onFavorite: () => state.toggleFavorite(product.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            InfoBanner(
              icon: Icons.local_shipping_outlined,
              text:
                  '${Formatters.price(AppConfig.freeDeliveryFrom)} бастап жеткізу тегін. Қазақстанның барлық аймағына.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
        child: SizedBox(
          height: 236,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(url: product.gallery.last),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.ink.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBadge.citrus('ЖАҢА ТОПТАМА'),
                    const SizedBox(height: 10),
                    Text(
                      'Күн ырғағына\nілесіңіз.',
                      style: AppText.h1.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.shortName} · ${Formatters.price(product.price)}',
                      style: AppText.caption.copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Топтаманы көру →',
                      style: AppText.link.copyWith(color: AppColors.citrus),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
