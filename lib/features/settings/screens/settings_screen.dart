import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../data/state/app_state.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: AppText.overline),
    );
  }

  void _openLegal(BuildContext context, LegalArgs args) {
    Navigator.of(context).pushNamed(AppRoutes.legal, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: const AppTopBar(title: 'Баптаулар'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 0, AppDimens.pagePadding, 28),
        children: [
          _section('ҚОЛДАНБА'),
          const MenuCard(
            children: [
              ValueTile(title: 'Тіл', value: 'Қазақша'),
              ValueTile(title: 'Валюта', value: 'Теңге · ₸'),
              ValueTile(title: 'Көрініс', value: 'Ашық'),
            ],
          ),
          _section('ХАБАРЛАНДЫРУЛАР'),
          MenuCard(
            children: [
              SwitchTile(
                title: 'Тапсырыс мәртебесі',
                subtitle: 'Жеткізу туралы маңызды жаңалықтар.',
                value: state.notifyOrders,
                onChanged: state.setNotifyOrders,
              ),
              SwitchTile(
                title: 'Жаңа топтамалар',
                value: state.notifyCollections,
                onChanged: state.setNotifyCollections,
              ),
              SwitchTile(
                title: 'Арнайы ұсыныстар',
                value: state.notifyOffers,
                onChanged: state.setNotifyOffers,
              ),
            ],
          ),
          _section('ҚҰПИЯЛЫЛЫҚ ЖӘНЕ КӨМЕК'),
          MenuCard(
            children: [
              MenuTile(
                title: 'Құпиясөзді өзгерту',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.changePassword),
              ),
              MenuTile(
                title: 'Құпиялық саясаты',
                onTap: () => _openLegal(context, LegalArgs.privacy),
              ),
              MenuTile(
                title: 'Пайдалану шарттары',
                onTap: () => _openLegal(context, LegalArgs.terms),
              ),
              MenuTile(
                title: 'Қолданба туралы',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'SÄT',
                  applicationVersion: AppConfig.appVersion,
                  applicationLegalese: '© 2026 SÄT',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(child: Text('SÄT · ${AppConfig.appVersion} нұсқасы', style: AppText.caption)),
        ],
      ),
    );
  }
}
