import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/net_image.dart';
import '../../../core/widgets/price_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/state/app_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promo = TextEditingController();
  String? _promoError;

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final state = context.read<AppState>();
    FocusScope.of(context).unfocus();
    final code = _promo.text.trim();
    if (code.isEmpty) {
      setState(() => _promoError = 'Промокодты енгізіңіз');
      return;
    }
    final ok = state.applyPromo(code);
    setState(() => _promoError = ok ? null : 'Промокод табылмады');
    if (ok) {
      _promo.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.cart;

    if (items.isEmpty) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Себет'),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Себетіңіз бос',
          message: 'Ұнаған тауарларды себетке қосыңыз — олар осында сақталады.',
          actionLabel: 'Каталогқа өту',
          onAction: () => Navigator.of(context).pushNamed(AppRoutes.catalog),
        ),
      );
    }

    final freeDelivery = state.remainingForFreeDelivery == 0;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Себет',
        trailingText: Formatters.itemsCount(state.cartCount),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 24),
        children: [
          for (final item in items) ...[
            _CartItemCard(item: item),
            const SizedBox(height: 12),
          ],
          _PromoCard(
            controller: _promo,
            appliedCode: state.promoCode,
            error: _promoError,
            onApply: _applyPromo,
            onClear: state.clearPromo,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                PriceRow(
                  label: 'Тауарлар (${state.cartCount})',
                  value: Formatters.price(state.subtotal),
                ),
                if (state.discount > 0)
                  PriceRow(
                    label: 'Жеңілдік (−${AppConfig.promoPercent}%)',
                    value: Formatters.price(-state.discount),
                  ),
                PriceRow(
                  label: 'Жеткізу',
                  value: state.deliveryFee == 0 ? 'Тегін' : Formatters.price(state.deliveryFee),
                ),
                const Divider(height: 20),
                PriceRow(
                  label: 'Барлығы',
                  value: Formatters.price(state.total),
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoBanner(
            icon: Icons.local_shipping_outlined,
            text: freeDelivery
                ? 'Жеткізу тегін! Жеткізу мерзімі: 1–3 жұмыс күні.'
                : 'Тегін жеткізуге дейін тағы ${Formatters.price(state.remainingForFreeDelivery)}. Жеткізу мерзімі: 1–3 жұмыс күні.',
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Рәсімдеуге өту · ${Formatters.price(state.total)}',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text('Қауіпсіз төлем · 14 күн ішінде қайтару', style: AppText.caption),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Сатып алуды жалғастыру',
            onPressed: () => state.setTab(0),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: NetImage(
              url: item.product.image,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: AppText.bodyStrong),
                const SizedBox(height: 2),
                Text(item.info, style: AppText.caption),
                const SizedBox(height: 4),
                Text(Formatters.price(item.lineTotal), style: AppText.bodyStrong),
                const SizedBox(height: 8),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      onDecrement: () => state.changeQuantity(item, -1),
                      onIncrement: () => state.changeQuantity(item, 1),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => state.removeFromCart(item),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline, size: 20, color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.controller,
    required this.appliedCode,
    required this.error,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? appliedCode;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (appliedCode != null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Промокод қолданылды: $appliedCode',
                style: AppText.label.copyWith(color: AppColors.success),
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('Алып тастау')),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onApply(),
                  style: AppText.input,
                  decoration: InputDecoration(
                    hintText: 'Промокод енгізіңіз',
                    hintStyle: AppText.hint.copyWith(fontSize: 14),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              TextButton(onPressed: onApply, child: const Text('Қолдану')),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(error!, style: AppText.caption.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}
