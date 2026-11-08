import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/state/app_state.dart';
import '../widgets/single_field_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.notice,
    this.redirectTo,
    this.redirectArguments,
  });

  final String? notice;
  final String? redirectTo;
  final Object? redirectArguments;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController(text: AppConfig.demoEmail);
  final TextEditingController _password = TextEditingController(text: AppConfig.demoPassword);
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _openMain() {
    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    final target = widget.redirectTo;
    if (target != null && target != AppRoutes.main) {
      navigator.pushNamed(target, arguments: widget.redirectArguments);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    final state = context.read<AppState>();
    final result = await state.auth.login(_email.text.trim(), _password.text);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final user = result.user;
    if (user == null) {
      setState(() => _error = result.error);
      return;
    }
    await state.startSession(user);
    if (!mounted) {
      return;
    }
    _openMain();
  }

  Future<void> _loginWithPhone() async {
    final phone = await showAppSheet<String>(
      context,
      builder: (context) => const SingleFieldSheet(
        title: 'Телефон нөмірімен кіру',
        description: 'Тіркелген телефон нөміріңізді енгізіңіз.',
        label: 'Телефон нөмірі',
        hint: '+7 (___) ___ __ __',
        buttonLabel: 'Жалғастыру',
        initialValue: AppConfig.demoPhone,
        keyboardType: TextInputType.phone,
        inputFormatters: [PhoneInputFormatter()],
        validator: Validators.phone,
      ),
    );
    if (!mounted || phone == null) {
      return;
    }
    setState(() => _loading = true);
    final state = context.read<AppState>();
    final result = await state.auth.loginWithPhone(phone);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final user = result.user;
    if (user == null) {
      setState(() => _error = result.error);
      return;
    }
    await state.startSession(user);
    if (!mounted) {
      return;
    }
    _openMain();
  }

  Future<void> _forgotPassword() async {
    final email = await showAppSheet<String>(
      context,
      builder: (context) => SingleFieldSheet(
        title: 'Құпиясөзді қалпына келтіру',
        description: 'Электрондық поштаңызға қалпына келтіру нұсқаулығын жібереміз.',
        label: 'Электрондық пошта',
        hint: 'example@mail.kz',
        buttonLabel: 'Нұсқаулық жіберу',
        initialValue: _email.text.trim(),
        keyboardType: TextInputType.emailAddress,
        validator: Validators.email,
      ),
    );
    if (!mounted || email == null) {
      return;
    }
    showAppSnack(context, 'Нұсқаулық $email мекенжайына жіберілді');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Қош келдіңіз'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                16,
                AppDimens.pagePadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.notice != null) ...[
                        InfoBanner(
                          icon: Icons.lock_outline,
                          text: widget.notice!,
                          background: AppColors.softCitrus,
                          iconColor: AppColors.ink,
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text('SÄT.', style: AppText.logoLarge),
                      const SizedBox(height: 28),
                      Text('Қайта көргенімізге қуаныштымыз.', style: AppText.h1),
                      const SizedBox(height: 12),
                      Text(
                        'Таңдаулыларыңыз бен тапсырыстарыңызға кіру үшін аккаунтыңызға кіріңіз.',
                        style: AppText.bodyGrey,
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: 'Электрондық пошта',
                        hint: 'example@mail.kz',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Құпиясөз',
                        hint: 'Құпиясөзді енгізіңіз',
                        controller: _password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.loginPassword,
                        onSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Құпиясөзді ұмыттыңыз ба?', style: AppText.link),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.softError,
                            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                          ),
                          child: Text(
                            _error!,
                            style: AppText.caption.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      PrimaryButton(label: 'Кіру', onPressed: _submit, isLoading: _loading),
                      const SizedBox(height: 14),
                      Center(child: Text('немесе', style: AppText.caption)),
                      const SizedBox(height: 14),
                      SecondaryButton(
                        label: 'Телефон нөмірімен кіру',
                        onPressed: _loading ? null : _loginWithPhone,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Аккаунтыңыз жоқ па?', style: AppText.caption),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Тіркелу', style: AppText.link.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Жалғастыру арқылы пайдалану шарттары мен құпиялық саясатымен келісесіз.',
                        textAlign: TextAlign.center,
                        style: AppText.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
