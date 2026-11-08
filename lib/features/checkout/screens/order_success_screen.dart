import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/order_item_tile.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/state/app_state.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final order = state.orderById(orderId);
    final user = state.user;
    if (order == null || user == null) {
      return const Scaffold(
        appBar: AppTopBar(title: 'Тапсырыс қабылданды'),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Тапсырыс табылмады',
          message: 'Тапсырыстар тізімін профильден қарай аласыз.',
        ),
      );
    }

    void goHome() {
      state.setTab(0);
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    }

    void track() {
      final navigator = Navigator.of(context);
      state.setTab(0);
      navigator.pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
      navigator.pushNamed(AppRoutes.orderStatus, arguments: order.id);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          goHome();
        }
      },
      child: Scaffold(
        appBar: const AppTopBar(title: 'Тапсырыс қабылданды'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 12, AppDimens.pagePadding, 24),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.softSuccess,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 34, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Жақсы таңдау,\n${user.firstName}!',
              textAlign: TextAlign.center,
              style: AppText.h1,
            ),
            const SizedBox(height: 10),
            Text(
              'Тапсырысыңыз қабылданды.\nҚалғанын бізге сеніп тапсырыңыз.',
              textAlign: TextAlign.center,
              style: AppText.bodyGrey,
            ),
            const SizedBox(height: 14),
            Center(child: AppBadge('№ ${order.id}')),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < order.items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    OrderItemTile(item: order.items[i]),
                  ],
                  const Divider(height: 28),
                  _InfoRow(
                    label: order.isPaid ? 'Төленді' : 'Төлем',
                    value: Formatters.price(order.total),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Жеткізу күні',
                    value: Formatters.rangeShort(order.deliveryFrom, order.deliveryTo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Растау хатын ${user.email} мекенжайына жібердік.',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Тапсырысты бақылау', onPressed: track),
            const SizedBox(height: 12),
            SecondaryButton(label: 'Басты бетке оралу', onPressed: goHome),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.caption.copyWith(color: AppColors.ink)),
        Text(value, style: AppText.bodyStrong),
      ],
    );
  }
}
