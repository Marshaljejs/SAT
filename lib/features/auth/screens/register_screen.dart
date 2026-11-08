import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_checkbox_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/state/app_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _accepted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    final state = context.read<AppState>();
    final result = await state.auth.register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
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
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
  }

  void _openLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Аккаунт ашу'),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 16, AppDimens.pagePadding, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Өз сәтіңізді табыңыз.', style: AppText.h1),
                const SizedBox(height: 12),
                Text(
                  'Бір аккаунт — барлық таңдаулыңыз бен тапсырыстарыңыз бір жерде.',
                  style: AppText.bodyGrey,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Аты-жөніңіз',
                  hint: 'Аты-жөніңізді енгізіңіз',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  validator: Validators.fullName,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 16),
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
                  label: 'Телефон нөмірі',
                  hint: '+7 (___) ___ __ __',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [PhoneInputFormatter()],
                  validator: Validators.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Құпиясөз',
                  hint: 'Кемінде 8 таңба',
                  helper: 'Латын әріптері мен кемінде бір сан қолданыңыз.',
                  controller: _password,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.newPassword,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Құпиясөзді қайталаңыз',
                  hint: 'Құпиясөзді қайта енгізіңіз',
                  controller: _confirm,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(() => _password.text),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                AppCheckboxField(
                  label: 'Пайдалану шарттары мен құпиялық саясатына қабылдаймын.',
                  value: _accepted,
                  onChanged: (value) => _accepted = value,
                  validator: Validators.acceptTerms,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
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
                const SizedBox(height: 20),
                PrimaryButton(label: 'Тіркелу', onPressed: _submit, isLoading: _loading),
                const SizedBox(height: 12),
                SecondaryButton(label: 'Аккаунтым бар · Кіру', onPressed: _openLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
