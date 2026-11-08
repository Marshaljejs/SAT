import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../data/state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), _next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    if (!mounted) {
      return;
    }
    final loggedIn = context.read<AppState>().isLoggedIn;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRoutes.main : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Opacity(opacity: value, child: child),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('КҮНДЕЛІКТІ ТАҢДАУ', style: AppText.overline),
                      Text('2026', style: AppText.overline),
                    ],
                  ),
                  const Spacer(flex: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('SÄT.', style: AppText.display),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.citrus,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Әр күніңізге\nерекше бір сәт.',
                    style: AppText.h2.copyWith(fontWeight: FontWeight.w400, height: 1.35),
                  ),
                  const Spacer(flex: 2),
                  Container(width: 72, height: 3, color: AppColors.cobalt),
                  const SizedBox(height: 12),
                  Text('Жақсы заттар. Ойластырылған таңдау.', style: AppText.caption),
                  const SizedBox(height: 4),
                  Text('01 / ТАНЫСУ', style: AppText.overline.copyWith(fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
