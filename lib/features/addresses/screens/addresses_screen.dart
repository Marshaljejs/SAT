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
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/address.dart';
import '../../../data/state/app_state.dart';

Future<bool> confirmDeleteAddress(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Мекенжайды жою'),
      content: const Text('Бұл мекенжай тізімнен жойылады.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Бас тарту'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Жою', style: AppText.link.copyWith(color: AppColors.error)),
        ),
      ],
    ),
  );
  return result == true;
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final addresses = state.addresses;

    return Scaffold(
      appBar: const AppTopBar(title: 'Мекенжайлар'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 28),
        children: [
          Text(
            'Жеткізу мекенжайларын басқарыңыз. Негізгі мекенжай рәсімдеу кезінде ұсынылады.',
            style: AppText.bodyGrey,
          ),
          const SizedBox(height: 16),
          if (addresses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EmptyState(
                icon: Icons.location_off_outlined,
                title: 'Мекенжайлар жоқ',
                message: 'Тапсырысты жылдам рәсімдеу үшін мекенжай қосыңыз.',
              ),
            )
          else
            for (final address in addresses) ...[
              _AddressCard(address: address),
              const SizedBox(height: 12),
            ],
          SecondaryButton(
            label: '+ Жаңа мекенжай қосу',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addressForm),
          ),
          const SizedBox(height: 16),
          const InfoBanner(
            icon: Icons.shield_outlined,
            text: 'Мекенжайыңыз тек тапсырысты жеткізу үшін пайдаланылады.',
            background: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.isDefault) const AppBadge('Негізгі мекенжай'),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.addressForm,
                  arguments: address,
                ),
                child: const Icon(Icons.edit_outlined, size: 20, color: AppColors.cobalt),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(address.label, style: AppText.h3),
          const SizedBox(height: 8),
          Text(address.firstLine, style: AppText.body),
          if (address.secondLine.isNotEmpty) Text(address.secondLine, style: AppText.body),
          const SizedBox(height: 10),
          Text(address.fullName, style: AppText.caption),
          Text(Formatters.prettyPhone(address.phone), style: AppText.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.addressForm,
                  arguments: address,
                ),
                child: Text('Өңдеу', style: AppText.link),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final ok = await confirmDeleteAddress(context);
                  if (ok) {
                    state.deleteAddress(address.id);
                  }
                },
                child: const Icon(Icons.delete_outline, size: 20, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
