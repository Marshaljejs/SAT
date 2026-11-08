import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/color_swatch_picker.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/net_image.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/product.dart';
import '../../../data/state/app_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _imageIndex = 0;
  int _colorIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _share(Product product) async {
    await Clipboard.setData(
      ClipboardData(text: '${product.name} · ${Formatters.price(product.price)} · SÄT'),
    );
    if (!mounted) {
      return;
    }
    showAppSnack(context, 'Тауар сілтемесі көшірілді');
  }

  void _addToCart(Product product) {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    state.addToCart(product, _colorIndex);
    showAppSnack(
      context,
      'Себетке қосылды',
      actionLabel: 'Себетке өту',
      onAction: () {
        navigator.popUntil((route) => route.settings.name == AppRoutes.main);
        state.setTab(3);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final product = state.products.byId(widget.productId);
    if (product == null) {
      return const Scaffold(
        appBar: AppTopBar(title: 'Тауар туралы'),
        body: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Тауар табылмады',
          message: 'Бұл тауар қолжетімсіз немесе жойылған.',
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Тауар туралы',
        trailingText: 'Бөлісу',
        onTrailingTap: () => _share(product),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 24),
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: product.gallery.length,
              onPageChanged: (value) => setState(() => _imageIndex = value),
              itemBuilder: (context, index) => NetImage(
                url: product.gallery[index],
                borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
              ),
            ),
          ),
          if (product.gallery.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < product.gallery.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _imageIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _imageIndex ? AppColors.cobalt : AppColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (product.isNew) ...[
                const AppBadge.citrus('ЖАҢА'),
                const SizedBox(width: 12),
              ],
              if (product.reviews > 0) ...[
                const Icon(Icons.star_rounded, size: 18, color: AppColors.citrus),
                const SizedBox(width: 4),
                Text(
                  '${Formatters.rating(product.rating)} · ${product.reviews} пікір',
                  style: AppText.caption.copyWith(color: AppColors.ink),
                ),
              ],
              const Spacer(),
              FavoriteButton(
                isFavorite: state.isFavorite(product.id),
                onPressed: () => state.toggleFavorite(product.id),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(product.name, style: AppText.h1),
          const SizedBox(height: 4),
          Text(product.tagline, style: AppText.bodyGrey),
          const SizedBox(height: 10),
          Text(Formatters.price(product.price), style: AppText.price),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Түсі: ',
              style: AppText.label,
              children: [
                TextSpan(
                  text: product.colors[_colorIndex].name,
                  style: AppText.label.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ColorSwatchPicker(
            colors: product.colors,
            selectedIndex: _colorIndex,
            onSelected: (value) => setState(() => _colorIndex = value),
          ),
          const SizedBox(height: 16),
          if (product.description.isNotEmpty) ...[
            Text(product.description, style: AppText.bodyGrey),
            const SizedBox(height: 20),
          ],
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final spec in product.specs) ...[
                  _SpecRow(label: spec.label, value: spec.value),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                ],
                _SpecRow(label: 'Жеткізу', value: product.deliveryTime),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                product.inStock ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: product.inStock ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product.inStock
                      ? 'Қоймада бар · 14 күн ішінде қайтару'
                      : 'Қазір қоймада жоқ',
                  style: AppText.caption.copyWith(
                    color: product.inStock ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 8, AppDimens.pagePadding, 12),
          child: PrimaryButton(
            label: 'Себетке қосу · ${Formatters.price(product.price)}',
            onPressed: product.inStock ? () => _addToCart(product) : null,
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppText.bodyGrey)),
          const SizedBox(width: 12),
          Text(value, style: AppText.bodyStrong),
        ],
      ),
    );
  }
}
