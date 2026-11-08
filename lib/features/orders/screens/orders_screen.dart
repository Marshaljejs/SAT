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
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/order_item_tile.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/order.dart';
import '../../../data/state/app_state.dart';

enum _OrderFilter { all, active, done }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _OrderFilter _filter = _OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.orders;
    final visible = all.where((order) {
      switch (_filter) {
        case _OrderFilter.all:
          return true;
        case _OrderFilter.active:
          return order.status.isActive;
        case _OrderFilter.done:
          return !order.status.isActive;
      }
    }).toList();

    return Scaffold(
      appBar: const AppTopBar(title: 'Тапсырыстарым'),
      body: all.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Тапсырыстар әзірге жоқ',
              message: 'Бірінші тапсырысыңызды рәсімдегеннен кейін ол осында көрінеді.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 28),
              children: [
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChipButton(
                          label: 'Барлығы · ${all.length}',
                          selected: _filter == _OrderFilter.all,
                          onTap: () => setState(() => _filter = _OrderFilter.all),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChipButton(
                          label: 'Белсенді',
                          selected: _filter == _OrderFilter.active,
                          onTap: () => setState(() => _filter = _OrderFilter.active),
                        ),
                      ),
                      FilterChipButton(
                        label: 'Аяқталған',
                        selected: _filter == _OrderFilter.done,
                        onTap: () => setState(() => _filter = _OrderFilter.done),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: EmptyState(
                      icon: Icons.filter_list,
                      title: 'Бұл санатта тапсырыс жоқ',
                      message: 'Басқа сүзгіні таңдап көріңіз.',
                    ),
                  )
                else
                  for (final order in visible) ...[
                    _OrderCard(order: order),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final active = order.status.isActive;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('№ ${order.id}', style: AppText.bodyStrong)),
              if (active) AppBadge(order.status.label) else AppBadge.success(order.status.label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${Formatters.dayYear(order.createdAt)} · ${order.itemCount} тауар',
            style: AppText.caption,
          ),
          const SizedBox(height: 14),
          OrderItemTile(item: order.items.first),
          if (active) ...[
            const SizedBox(height: 10),
            Text(
              'Жеткізу: ${Formatters.range(order.deliveryFrom, order.deliveryTo)}',
              style: AppText.link.copyWith(color: AppColors.cobalt),
            ),
          ],
          const SizedBox(height: 14),
          SecondaryButton(
            label: active ? 'Тапсырысты қарау' : 'Толығырақ',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.orderStatus,
              arguments: order.id,
            ),
          ),
        ],
      ),
    );
  }
}
