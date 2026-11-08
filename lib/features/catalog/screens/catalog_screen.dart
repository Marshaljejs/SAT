import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/product_grid.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/state/app_state.dart';

class CatalogFilter {
  const CatalogFilter({required this.range, required this.onlyInStock});

  final RangeValues? range;
  final bool onlyInStock;
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.initialCategory});

  final Category? initialCategory;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late String? _categoryId = widget.initialCategory?.id;
  ProductSort _sort = ProductSort.popular;
  RangeValues? _range;
  bool _onlyInStock = false;

  bool get _hasFilter => _range != null || _onlyInStock;

  Future<void> _openFilter(double ceiling) async {
    final result = await showAppSheet<CatalogFilter>(
      context,
      builder: (context) => _FilterSheet(
        bounds: RangeValues(0, ceiling),
        initialRange: _range ?? RangeValues(0, ceiling),
        initialOnlyInStock: _onlyInStock,
      ),
    );
    if (result != null) {
      setState(() {
        _range = result.range;
        _onlyInStock = result.onlyInStock;
      });
    }
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

  void _reset() {
    setState(() {
      _categoryId = null;
      _range = null;
      _onlyInStock = false;
      _sort = ProductSort.popular;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ceiling = state.products.priceCeiling().toDouble();
    final range = _range ?? RangeValues(0, ceiling);
    final products = state.products.filter(
      categoryId: _categoryId,
      minPrice: range.start.round(),
      maxPrice: _range == null ? 100000000 : range.end.round(),
      onlyInStock: _onlyInStock,
      sort: _sort,
    );

    return Scaffold(
      appBar: const AppTopBar(title: 'Күнделікті топтама'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 4, AppDimens.pagePadding, 28),
        children: [
          Text('Аз зат. Көбірек мән. Сіз үшін таңдадық.', style: AppText.bodyGrey),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChipButton(
                    label: 'Барлығы',
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
              Expanded(
                child: _ToolButton(
                  icon: Icons.tune,
                  label: _hasFilter ? 'Сүзгі · белсенді' : 'Сүзгі',
                  onTap: () => _openFilter(ceiling),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ToolButton(
                  icon: Icons.swap_vert,
                  label: _sort.label,
                  onTap: _openSort,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.products.count == 0)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Каталог бос',
                message: 'Әзірге бірде-бір тауар қосылмаған.',
                actionLabel: 'Тауар қосу',
                onAction: () => Navigator.of(context).pushNamed(AppRoutes.productForm),
              ),
            )
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.search_off,
                title: 'Тауар табылмады',
                message: 'Сүзгі параметрлерін өзгертіп көріңіз.',
                actionLabel: 'Сүзгіні тазалау',
                onAction: _reset,
              ),
            )
          else ...[
            Text('${products.length} тауар табылды', style: AppText.caption),
            const SizedBox(height: 12),
            ProductGrid(products: products),
            const SizedBox(height: 20),
            Center(child: Text('Барлық тауар көрсетілді', style: AppText.caption)),
          ],
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.bounds,
    required this.initialRange,
    required this.initialOnlyInStock,
  });

  final RangeValues bounds;
  final RangeValues initialRange;
  final bool initialOnlyInStock;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _values = widget.initialRange;
  late bool _onlyInStock = widget.initialOnlyInStock;

  @override
  Widget build(BuildContext context) {
    final divisions = (widget.bounds.end / 1000).round().clamp(1, 200);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сүзгі', style: AppText.h2),
        const SizedBox(height: 16),
        Text('Баға бойынша', style: AppText.label),
        const SizedBox(height: 4),
        Text(
          '${Formatters.price(_values.start.round())} – ${Formatters.price(_values.end.round())}',
          style: AppText.bodyStrong,
        ),
        RangeSlider(
          values: _values,
          min: widget.bounds.start,
          max: widget.bounds.end,
          divisions: divisions,
          onChanged: (value) => setState(() => _values = value),
        ),
        MenuCard(
          children: [
            SwitchTile(
              title: 'Тек қоймада бар',
              value: _onlyInStock,
              onChanged: (value) => setState(() => _onlyInStock = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Қолдану',
          onPressed: () {
            final isFull = _values.start <= widget.bounds.start && _values.end >= widget.bounds.end;
            Navigator.of(context).pop(
              CatalogFilter(range: isFull ? null : _values, onlyInStock: _onlyInStock),
            );
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Тазалау',
          onPressed: () => Navigator.of(context).pop(
            const CatalogFilter(range: null, onlyInStock: false),
          ),
        ),
      ],
    );
  }
}
