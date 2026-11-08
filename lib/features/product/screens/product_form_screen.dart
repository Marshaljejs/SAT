import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/product.dart';
import '../../../data/state/app_state.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.product?.name ?? '');
  late final TextEditingController _subtitle = TextEditingController(text: widget.product?.subtitle ?? '');
  late final TextEditingController _price = TextEditingController(
    text: widget.product == null ? '' : widget.product!.price.toString(),
  );
  late final TextEditingController _description = TextEditingController(text: widget.product?.description ?? '');
  late final TextEditingController _image = TextEditingController(
    text: widget.product == null || widget.product!.images.isEmpty ? '' : widget.product!.images.first,
  );
  late bool _inStock = widget.product?.inStock ?? true;
  late bool _isNew = widget.product?.isNew ?? false;
  String? _categoryId;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final categories = context.read<AppState>().categories;
    _categoryId = widget.product?.categoryId ?? (categories.isEmpty ? null : categories.first.id);
  }

  @override
  void dispose() {
    _name.dispose();
    _subtitle.dispose();
    _price.dispose();
    _description.dispose();
    _image.dispose();
    super.dispose();
  }

  List<String> _keywords(String name) {
    return name
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1)
        .toList();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final state = context.read<AppState>();
    final categoryId = _categoryId;
    if (categoryId == null) {
      showAppSnack(context, 'Санатты таңдаңыз', isError: true);
      return;
    }
    final image = _image.text.trim();
    final existing = widget.product;
    final Product product;
    if (existing == null) {
      product = Product(
        id: state.products.newId(),
        name: _name.text.trim(),
        subtitle: _subtitle.text.trim(),
        tagline: _subtitle.text.trim(),
        price: int.parse(_price.text.trim()),
        images: image.isEmpty ? const [] : [image],
        categoryId: categoryId,
        colors: const [ProductColor.fallback],
        description: _description.text.trim(),
        specs: const [],
        cartInfo: '',
        deliveryTime: '1–3 жұмыс күні',
        rating: 0,
        reviews: 0,
        popularity: 50,
        keywords: _keywords(_name.text),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isNew: _isNew,
        inStock: _inStock,
      );
    } else {
      product = existing.copyWith(
        name: _name.text.trim(),
        subtitle: _subtitle.text.trim(),
        tagline: _subtitle.text.trim(),
        price: int.parse(_price.text.trim()),
        images: image.isEmpty ? const [] : [image],
        categoryId: categoryId,
        description: _description.text.trim(),
        keywords: _keywords(_name.text),
        isNew: _isNew,
        inStock: _inStock,
      );
    }
    setState(() => _saving = true);
    final ok = await state.saveProduct(product);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (!ok) {
      return;
    }
    showAppSnack(context, _isEdit ? 'Тауар жаңартылды' : 'Тауар қосылды');
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final state = context.read<AppState>();
    final product = widget.product;
    if (product == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Тауарды жою'),
        content: const Text('Тауар каталогтан, себеттен және таңдаулылардан жойылады.'),
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
    if (confirmed != true) {
      return;
    }
    final ok = await state.deleteProduct(product.id);
    if (!mounted || !ok) {
      return;
    }
    showAppSnack(context, 'Тауар жойылды');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppTopBar(title: _isEdit ? 'Тауарды өңдеу' : 'Тауар қосу'),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(_isEdit ? 'Тауарды жаңарту' : 'Жаңа тауар'),
                const SizedBox(height: 10),
                Text('* белгісі бар өрістерді толтыру міндетті.', style: AppText.caption),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Атауы *',
                  hint: 'Мысалы: SÄT Trail рюкзагы',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, 'Тауар атауын енгізіңіз'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Қысқаша сипаттама *',
                  hint: 'Мысалы: Рюкзак · Қара',
                  controller: _subtitle,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, 'Қысқаша сипаттаманы енгізіңіз'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Бағасы, ₸ *',
                  hint: '24900',
                  controller: _price,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validators.price,
                ),
                const SizedBox(height: 14),
                Text('Санат *', style: AppText.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in state.categories)
                      FilterChipButton(
                        label: category.name,
                        selected: _categoryId == category.id,
                        onTap: () => setState(() => _categoryId = category.id),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Толық сипаттама',
                  hint: 'Тауар туралы қысқаша жазыңыз',
                  controller: _description,
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Сурет сілтемесі',
                  hint: 'https://...',
                  controller: _image,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  validator: Validators.optionalUrl,
                ),
                const SizedBox(height: 16),
                MenuCard(
                  children: [
                    SwitchTile(
                      title: 'Қоймада бар',
                      value: _inStock,
                      onChanged: (value) => setState(() => _inStock = value),
                    ),
                    SwitchTile(
                      title: 'Жаңа деп белгілеу',
                      value: _isNew,
                      onChanged: (value) => setState(() => _isNew = value),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Сақтау', onPressed: _save, isLoading: _saving),
                if (_isEdit) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _delete,
                      child: Text(
                        'Тауарды жою',
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
