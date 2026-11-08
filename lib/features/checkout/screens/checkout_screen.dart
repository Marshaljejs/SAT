import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_checkbox_field.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/order_item_tile.dart';
import '../../../core/widgets/price_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/address.dart';
import '../../../data/state/app_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const String _newAddressKey = '__new__';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _addressId;
  bool _payByCard = true;
  bool _accepted = false;
  bool _loading = false;

  Address? _currentAddress() {
    final state = context.read<AppState>();
    return state.addressById(_addressId) ?? state.defaultAddress;
  }

  Future<void> _addAddress() async {
    final saved = await Navigator.of(context).pushNamed<Address>(AppRoutes.addressForm);
    if (!mounted || saved == null) {
      return;
    }
    setState(() => _addressId = saved.id);
  }

  Future<void> _chooseAddress() async {
    final state = context.read<AppState>();
    final selected = _currentAddress();
    final result = await showAppSheet<String>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Жеткізу мекенжайы', style: AppText.h2),
          const SizedBox(height: 12),
          for (final address in state.addresses)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(address.label, style: AppText.bodyStrong),
              subtitle: Text(address.firstLine, style: AppText.caption),
              trailing: address.id == selected?.id
                  ? const Icon(Icons.check, color: AppColors.cobalt)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(address.id),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add, color: AppColors.cobalt),
            title: Text('Жаңа мекенжай қосу', style: AppText.link),
            onTap: () => Navigator.of(sheetContext).pop(_newAddressKey),
          ),
        ],
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    if (result == _newAddressKey) {
      await _addAddress();
      return;
    }
    setState(() => _addressId = result);
  }

  Future<void> _pay() async {
    final state = context.read<AppState>();
    final address = _currentAddress();
    final valid = _formKey.currentState!.validate();
    if (address == null) {
      showAppSnack(context, 'Жеткізу мекенжайын қосыңыз', isError: true);
      return;
    }
    if (!valid) {
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    final order = await state.placeOrder(address: address, payByCard: _payByCard);
    if (!mounted) {
      return;
    }
    if (order == null) {
      setState(() => _loading = false);
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.orderSuccess, arguments: order.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final address = state.addressById(_addressId) ?? state.defaultAddress;
    final now = DateTime.now();
    final deliveryText = Formatters.range(
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 3)),
    );

    return Scaffold(
      appBar: const AppTopBar(title: 'Рәсімдеу'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 24),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AppBadge('СОҢҒЫ ҚАДАМ'),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < state.cart.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    OrderItemTile(item: state.cart[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Text('Жеткізу мекенжайы', style: AppText.h3)),
                GestureDetector(
                  onTap: address == null ? _addAddress : _chooseAddress,
                  child: Text(address == null ? 'Қосу' : 'Өзгерту', style: AppText.link),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (address == null)
              AppCard(
                onTap: _addAddress,
                child: Row(
                  children: [
                    const Icon(Icons.add_location_alt_outlined, color: AppColors.cobalt),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Мекенжай қосыңыз', style: AppText.bodyStrong)),
                  ],
                ),
              )
            else
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.cobalt, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.fullName, style: AppText.bodyStrong),
                          const SizedBox(height: 6),
                          Text(address.firstLine, style: AppText.body),
                          if (address.secondLine.isNotEmpty)
                            Text(address.secondLine, style: AppText.body),
                          const SizedBox(height: 6),
                          Text(Formatters.prettyPhone(address.phone), style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            AppCard(
              borderColor: AppColors.cobalt,
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: AppColors.cobalt, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Курьермен жеткізу', style: AppText.bodyStrong),
                        const SizedBox(height: 2),
                        Text(
                          '$deliveryText · ${Formatters.price(state.deliveryFee)}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_outline, color: AppColors.cobalt, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Төлем тәсілі', style: AppText.h3),
            const SizedBox(height: 12),
            _PaymentOption(
              icon: Icons.credit_card,
              label: AppConfig.paymentCardLabel,
              selected: _payByCard,
              onTap: () => setState(() => _payByCard = true),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              icon: Icons.payments_outlined,
              label: AppConfig.paymentCashLabel,
              selected: !_payByCard,
              onTap: () => setState(() => _payByCard = false),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                children: [
                  PriceRow(
                    label: 'Тауарлар (${state.cartCount})',
                    value: Formatters.price(state.subtotal),
                  ),
                  if (state.discount > 0)
                    PriceRow(label: 'Жеңілдік', value: Formatters.price(-state.discount)),
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
            const SizedBox(height: 16),
            AppCheckboxField(
              label: 'Тапсырыс шарттарымен және жеке деректерді өңдеуге келісемін.',
              value: _accepted,
              onChanged: (value) => _accepted = value,
              validator: Validators.acceptTerms,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Төлеу · ${Formatters.price(state.total)}',
              onPressed: state.cart.isEmpty ? null : _pay,
              isLoading: _loading,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('Төлем деректері шифрланған және қорғалған.', style: AppText.caption),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.softCobalt : AppColors.white,
      borderColor: selected ? AppColors.cobalt : null,
      child: Row(
        children: [
          Icon(icon, size: 20, color: selected ? AppColors.cobalt : AppColors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.bodyStrong)),
          Icon(
            selected ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 22,
            color: selected ? AppColors.cobalt : AppColors.hint,
          ),
        ],
      ),
    );
  }
}
