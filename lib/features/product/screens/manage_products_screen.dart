import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/net_image.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/state/app_state.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final TextEditingController _search = TextEditingController();
  String? _categoryId;
  ProductSort _sort = ProductSort.newest;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openSort() async {
    final result = await showAppSheet<ProductSort>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Реттеу', style: AppText.h2),
          const SizedBox(height: 8),
          for (final option in ProductSort.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.label, style: AppText.body),
              trailing: option == _sort
                  ? const Icon(Icons.check, color: AppColors.cobalt)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(option),
            ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _sort = result);
    }
  }

  Future<void> _delete(Product product) async {
    final state = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Тауарды жою'),
        content: Text('«${product.name}» каталогтан, себеттен және таңдаулылардан жойылады.'),
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
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final products = state.products.filter(
      categoryId: _categoryId,
      query: _search.text,
      sort: _sort,
    );
    final total = state.products.count;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Тауарларды басқару',
        trailingText: 'Қосу',
        onTrailingTap: () => Navigator.of(context).pushNamed(AppRoutes.productForm),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 28),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: AppText.input,
            decoration: InputDecoration(
              hintText: 'Атауы бойынша іздеу',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChipButton(
                    label: 'Барлығы · $total',
                    selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                ),
                for (final category in state.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipButton(
                      label: category.name,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('${products.length} тауар', style: AppText.caption)),
              GestureDetector(
                onTap: _openSort,
                child: Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 18, color: AppColors.cobalt),
                    const SizedBox(width: 4),
                    Text(_sort.label, style: AppText.link),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Тауарлар жоқ',
                message: 'Каталогқа алғашқы тауарды қосыңыз.',
                actionLabel: 'Тауар қосу',
                onAction: () => Navigator.of(context).pushNamed(AppRoutes.productForm),
              ),
            )
          else if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.search_off,
                title: 'Ештеңе табылмады',
                message: 'Іздеу сөзін немесе санатты өзгертіп көріңіз.',
              ),
            )
          else
            for (final product in products) ...[
              _ProductTile(
                product: product,
                categoryName: state.categoryName(product.categoryId),
                onEdit: () => Navigator.of(context).pushNamed(
                  AppRoutes.productForm,
                  arguments: product,
                ),
                onDelete: () => _delete(product),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: NetImage(
              url: product.image,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong,
                ),
                const SizedBox(height: 2),
                Text(
                  '$categoryName · ${Formatters.price(product.price)}',
                  style: AppText.caption,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (product.inStock)
                      const AppBadge.success('Қоймада бар')
                    else
                      const AppBadge(
                        'Қоймада жоқ',
                        background: AppColors.softError,
                        foreground: AppColors.error,
                      ),
                    if (product.isRemote) const AppBadge('Сервер'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.cobalt),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
