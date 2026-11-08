import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/utils/validators.dart';
import '../../../data/remote/models/remote_product.dart';
import '../../../data/remote/remote_product_mapper.dart';
import '../state/remote_catalog_controller.dart';

class RemoteProductFormSheet extends StatefulWidget {
  const RemoteProductFormSheet({super.key, required this.onSubmit, this.initial});

  final RemoteProduct? initial;
  final Future<ActionResult> Function(RemoteProductDraft draft) onSubmit;

  @override
  State<RemoteProductFormSheet> createState() => _RemoteProductFormSheetState();
}

class _RemoteProductFormSheetState extends State<RemoteProductFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _price = TextEditingController(
    text: widget.initial == null ? '' : widget.initial!.price.toString(),
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.initial?.description ?? '',
  );
  late String _category = _initialCategory();
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.initial != null;

  String _initialCategory() {
    final value = widget.initial?.category ?? '';
    if (value.isNotEmpty) {
      return value;
    }
    return RemoteProductMapper.formCategories.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Бағаны енгізіңіз';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Бағаны дұрыс енгізіңіз';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final draft = RemoteProductDraft(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category,
      price: double.parse(_price.text.trim().replaceAll(',', '.')),
    );
    setState(() => _saving = true);
    final result = await widget.onSubmit(draft);
    if (!mounted) {
      return;
    }
    if (result.ok) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() {
      _saving = false;
      _error = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = {
      ...RemoteProductMapper.formCategories,
      if (_category.isNotEmpty) _category,
    }.toList();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEdit ? 'Тауарды өзгерту (PATCH)' : 'Серверге тауар қосу (POST)', style: AppText.h2),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Атауы *',
            controller: _title,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.required(value, 'Тауар атауын енгізіңіз'),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Бағасы, USD *',
            hint: '49.99',
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: _validatePrice,
          ),
          const SizedBox(height: 14),
          Text('Санат', style: AppText.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slug in categories)
                FilterChipButton(
                  label: RemoteProductMapper.categoryTitle(slug),
                  selected: _category == slug,
                  onTap: () => setState(() => _category = slug),
                ),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Сипаттама',
            controller: _description,
            maxLines: 3,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softError,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: AppText.caption.copyWith(color: AppColors.error)),
            ),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: _isEdit ? 'Серверде өзгерту' : 'Серверге жіберу',
            onPressed: _submit,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }
}
