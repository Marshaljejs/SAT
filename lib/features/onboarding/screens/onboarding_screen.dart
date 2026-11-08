import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/net_image.dart';
import '../../../core/widgets/primary_button.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.button,
  });

  final String image;
  final String title;
  final String description;
  final String button;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=900&auto=format&fit=crop',
      title: 'Өзіңізге жақын заттарды табыңыз.',
      description: 'Сөмкеден шамға дейін — күнделікті өміріңізге үйлесетін, мұқият таңдалған топтама.',
      button: 'Келесі',
    ),
    _OnboardingPage(
      image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?q=80&w=900&auto=format&fit=crop',
      title: 'Ұнағанын сақтап қойыңыз.',
      description: 'Таңдаулы заттарыңызды бір жерге жинаңыз. Дәл өзіңізге керегін асықпай таңдаңыз.',
      button: 'Келесі',
    ),
    _OnboardingPage(
      image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=900&auto=format&fit=crop',
      title: 'Таңдауыңыз есігіңізге дейін.',
      description: 'Қазақстан бойынша жеткіземіз. Тапсырысты рәсімдеп, әр қадамын қолданбадан бақылаңыз.',
      button: 'Бастайық',
    ),
  ];

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 12, AppDimens.pagePadding, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SÄT.', style: AppText.logo),
                  TextButton(
                    onPressed: _finish,
                    child: Text('Өткізіп жіберу', style: AppText.caption),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NetImage(
                            url: item.image,
                            borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(item.title, style: AppText.h1),
                        const SizedBox(height: 12),
                        Text(item.description, style: AppText.bodyGrey),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _index ? 28 : 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index ? AppColors.cobalt : AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: page.button, onPressed: _next),
              const SizedBox(height: 12),
              Text('Танысу · ${_index + 1} / ${_pages.length}', style: AppText.caption),
            ],
          ),
        ),
      ),
    );
  }
}
