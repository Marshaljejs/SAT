import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../data/state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Аккаунттан шығу'),
        content: const Text('Шынымен аккаунттан шыққыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Бас тарту'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Шығу', style: AppText.link.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await state.endSession();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _openSupport(BuildContext context) {
    showAppSheet<void>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Көмек және қолдау', style: AppText.h2),
          const SizedBox(height: 8),
          Text('Сұрағыңыз болса, бізге жазыңыз — жұмыс күндері 9:00–20:00 жауап береміз.', style: AppText.bodyGrey),
          const SizedBox(height: 16),
          const MenuCard(
            children: [
              ValueTile(title: 'Электрондық пошта', value: 'support@sat.kz'),
              ValueTile(title: 'Телефон', value: '+7 727 000 00 00'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: const AppTopBar(title: 'Менің профилім'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 8, AppDimens.pagePadding, 28),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.citrus,
                child: Text(
                  user.initials,
                  style: AppText.h1.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 14),
              Text(user.name, style: AppText.h2, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(user.email, style: AppText.caption),
              const SizedBox(height: 10),
              const AppBadge('SÄT қауымдастығы'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Тапсырыс', value: state.orders.length)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Таңдаулы', value: state.favoritesCount)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Мекенжай', value: state.addresses.length)),
            ],
          ),
          const SizedBox(height: 20),
          MenuCard(
            children: [
              MenuTile(
                icon: Icons.inventory_2_outlined,
                title: 'Менің тапсырыстарым',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
              ),
              MenuTile(
                icon: Icons.favorite_border,
                title: 'Таңдаулы тауарлар',
                onTap: () => state.setTab(2),
              ),
              MenuTile(
                icon: Icons.location_on_outlined,
                title: 'Жеткізу мекенжайлары',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.addresses),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MenuCard(
            children: [
              MenuTile(
                icon: Icons.person_outline,
                title: 'Жеке деректер',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.personalData),
              ),
              MenuTile(
                icon: Icons.cloud_outlined,
                title: 'Сервер каталогы (API)',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.remoteCatalog),
              ),
              MenuTile(
                icon: Icons.storefront_outlined,
                title: 'Тауарларды басқару',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.manageProducts),
              ),
              MenuTile(
                icon: Icons.settings_outlined,
                title: 'Баптаулар',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
              MenuTile(
                icon: Icons.chat_bubble_outline,
                title: 'Көмек және қолдау',
                onTap: () => _openSupport(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.softCobalt,
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Өзіңізге бір сәт бөліңіз.', style: AppText.h3),
                const SizedBox(height: 6),
                Text(
                  'Жаңа топтамалар мен ойластырылған таңдаулар — әр айда SÄT-та.',
                  style: AppText.caption.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => _logout(context),
              child: Text('Аккаунттан шығу', style: AppText.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      child: Column(
        children: [
          Text('$value', style: AppText.h2),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}
