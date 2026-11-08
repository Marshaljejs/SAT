import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_checkbox_field.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/location/location_service.dart';
import '../../location/location_dialogs.dart';
import '../../../data/models/address.dart';
import '../../../data/state/app_state.dart';
import 'addresses_screen.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.address?.fullName ?? '');
  late final TextEditingController _phone = TextEditingController(
    text: Formatters.formatPhone(widget.address?.phone ?? ''),
  );
  late final TextEditingController _city = TextEditingController(text: widget.address?.city ?? '');
  late final TextEditingController _street = TextEditingController(text: widget.address?.street ?? '');
  late final TextEditingController _apartment = TextEditingController(text: widget.address?.apartment ?? '');
  late final TextEditingController _postal = TextEditingController(text: widget.address?.postalCode ?? '');
  late bool _isDefault = widget.address?.isDefault ?? false;
  late double? _latitude = widget.address?.latitude;
  late double? _longitude = widget.address?.longitude;
  final LocationService _location = LocationService();
  bool _locating = false;
  String? _zoneWarning;

  bool get _isEdit => widget.address != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _street.dispose();
    _apartment.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final state = context.read<AppState>();
    final existing = widget.address;
    final base = Address(
      id: existing?.id ?? state.newAddressId(),
      label: existing?.label ?? (state.addresses.isEmpty ? 'Үй' : 'Мекенжай ${state.addresses.length + 1}'),
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
      street: _street.text.trim(),
      apartment: _apartment.text.trim(),
      postalCode: _postal.text.trim(),
      isDefault: _isDefault,
      latitude: _latitude,
      longitude: _longitude,
    );
    final saved = await state.saveAddress(base);
    if (!mounted || saved == null) {
      return;
    }
    showAppSnack(context, _isEdit ? 'Мекенжай жаңартылды' : 'Мекенжай сақталды');
    Navigator.of(context).pop(saved);
  }

  Future<void> _detectLocation() async {
    FocusScope.of(context).unfocus();
    setState(() => _locating = true);
    final result = await _location.detect();
    if (!mounted) {
      return;
    }
    setState(() => _locating = false);
    final found = result.location;
    if (found == null) {
      await showLocationFailure(
        context,
        result.failure ?? LocationFailure.unavailable,
        service: _location,
        onRetry: _detectLocation,
      );
      return;
    }
    setState(() {
      _latitude = found.latitude;
      _longitude = found.longitude;
      if (found.city.isNotEmpty) {
        _city.text = found.city;
      }
      if (found.street.isNotEmpty) {
        _street.text = found.street;
      }
      if (found.postalCode.isNotEmpty) {
        _postal.text = found.postalCode;
      }
      _zoneWarning = found.city.isNotEmpty && !AppConfig.cities.contains(found.city)
          ? '«${found.city}» қаласына жеткізу әзірге қолжетімсіз. Қолжетімді қалалар: ${AppConfig.cities.join(', ')}.'
          : null;
    });
    showAppSnack(
      context,
      found.hasAddress
          ? 'Орын анықталды: ${found.city}'
          : 'Координаттар анықталды. Мекенжайды қолмен толтырыңыз.',
    );
  }

  Future<void> _delete() async {
    final ok = await confirmDeleteAddress(context);
    if (!mounted || !ok) {
      return;
    }
    final deleted = await context.read<AppState>().deleteAddress(widget.address!.id);
    if (!mounted || !deleted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: _isEdit ? 'Мекенжайды өңдеу' : 'Мекенжай қосу'),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(_isEdit ? 'Мекенжайды жаңарту' : 'Жаңа мекенжай'),
                const SizedBox(height: 10),
                Text('* белгісі бар өрістерді толтыру міндетті.', style: AppText.caption),
                const SizedBox(height: 18),
                SecondaryButton(
                  label: _locating ? 'Орын анықталуда...' : 'Қазіргі орынды қолдану',
                  onPressed: _locating ? null : _detectLocation,
                ),
                if (_latitude != null && _longitude != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'GPS: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                    style: AppText.caption,
                  ),
                ],
                if (_zoneWarning != null) ...[
                  const SizedBox(height: 10),
                  InfoBanner(
                    icon: Icons.info_outline,
                    text: _zoneWarning!,
                    background: AppColors.softCitrus,
                    iconColor: AppColors.ink,
                  ),
                ],
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Алушының аты-жөні *',
                  controller: _name,
                  hint: 'Аты-жөнін енгізіңіз',
                  textInputAction: TextInputAction.next,
                  validator: Validators.fullName,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Телефон нөмірі *',
                  controller: _phone,
                  hint: '+7 (___) ___ __ __',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: const [PhoneInputFormatter()],
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Қала *',
                  controller: _city,
                  hint: 'Алматы',
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, 'Қаланы енгізіңіз'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Көше, үй *',
                  controller: _street,
                  hint: 'Төле би көшесі, 101',
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, 'Көше мен үйді енгізіңіз'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Пәтер',
                        controller: _apartment,
                        hint: '12',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Пошта индексі',
                        controller: _postal,
                        hint: '050000',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: Validators.postalCode,
                        onSubmitted: (_) => _save(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppCheckboxField(
                  label: 'Негізгі жеткізу мекенжайы ретінде сақтау',
                  value: _isDefault,
                  onChanged: (value) => _isDefault = value,
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Мекенжайды сақтау', onPressed: _save),
                if (_isEdit) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _delete,
                      child: Text(
                        'Мекенжайды жою',
                        style: AppText.link.copyWith(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
