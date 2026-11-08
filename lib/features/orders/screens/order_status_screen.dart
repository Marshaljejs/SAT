import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/order_item_tile.dart';
import '../../../core/widgets/price_row.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/order.dart';
import '../../../data/state/app_state.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final order = state.orderById(orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppTopBar(title: '№ $orderId'),
        body: const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Тапсырыс табылмады',
          message: 'Тапсырыстар тізіміне оралып көріңіз.',
        ),
      );
    }

    final delivered = order.status == OrderStatus.delivered;
    final steps = <_StepData>[
      _StepData(
        'Қабылданды',
        '${Formatters.day(order.createdAt)} · ${Formatters.time(order.createdAt)}',
      ),
      const _StepData('Дайындалуда', 'Тапсырысыңыз жиналып жатыр'),
      const _StepData('Жолда', 'Курьерге тапсырылғанда хабарлаймыз'),
      _StepData(
        'Жеткізілді',
        delivered ? Formatters.day(order.deliveryTo) : 'Қолыңызға тиген кезде',
      ),
    ];

    return Scaffold(
      appBar: AppTopBar(title: '№ ${order.id}'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 28),
        children: [
          Row(
            children: [
              if (delivered) AppBadge.success(order.status.label) else AppBadge(order.status.label),
              const SizedBox(width: 10),
              Text(Formatters.dayYear(order.createdAt), style: AppText.caption),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            delivered ? 'Тапсырыс жеткізілді.' : 'Жақында қолыңызда болады.',
            style: AppText.h1,
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Жеткізу: ${Formatters.range(order.deliveryFrom, order.deliveryTo)}',
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < steps.length; i++)
                  _TimelineStep(
                    data: steps[i],
                    done: i <= order.status.stepIndex,
                    isLast: i == steps.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < order.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  OrderItemTile(item: order.items[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Жеткізу мекенжайы', style: AppText.bodyStrong),
                const SizedBox(height: 8),
                Text(
                  '${order.address.fullName} · ${Formatters.prettyPhone(order.address.phone)}',
                  style: AppText.caption.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  [order.address.firstLine, order.address.secondLine]
                      .where((part) => part.isNotEmpty)
                      .join(', '),
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                Text('Төлем', style: AppText.bodyStrong),
                const SizedBox(height: 8),
                Text(
                  '${order.paymentLabel} · ${order.isPaid ? 'Төленді' : 'Алу кезінде'}',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                PriceRow(
                  label: 'Тауарлар (${order.itemCount})',
                  value: Formatters.price(order.subtotal),
                ),
                if (order.discount > 0)
                  PriceRow(label: 'Жеңілдік', value: Formatters.price(-order.discount)),
                PriceRow(
                  label: 'Жеткізу',
                  value: order.deliveryFee == 0 ? 'Тегін' : Formatters.price(order.deliveryFee),
                ),
                const Divider(height: 20),
                PriceRow(label: 'Барлығы', value: Formatters.price(order.total), isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            label: 'Қолдау қызметіне жазу',
            onPressed: () => showAppSnack(context, 'Өтінішіңіз қолдау қызметіне жіберілді'),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.data, required this.done, required this.isLast});

  final _StepData data;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: done ? AppColors.cobalt : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? AppColors.cobalt : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 14, color: AppColors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done ? AppColors.cobalt : AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppText.bodyStrong.copyWith(
                      color: done ? AppColors.ink : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(data.subtitle, style: AppText.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
