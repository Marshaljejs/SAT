import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/filter_chip_button.dart';
import '../../../core/widgets/product_grid.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _popularQueries = ['құлаққап', 'шам', 'бөтелке', 'сөмке'];

  final TextEditingController _controller = TextEditingController();
  bool _categoriesMode = false;

  String get _query => _controller.text.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final service = state.products;
    final query = _query;
    final results = service.search(query);
    final categories = state.searchCategories(query);
    final suggestions = service.suggestions(
      excludeIds: results.map((product) => product.id),
      limit: query.isEmpty ? 4 : 2,
    );

    return Scaffold(
      appBar: const AppTopBar(title: 'Іздеу'),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, 8, AppDimens.pagePadding, 28),
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            style: AppText.input,
            decoration: InputDecoration(
              hintText: 'Нені іздеп жүрсіз?',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _setQuery(''),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FilterChipButton(
                label: 'Тауарлар',
                selected: !_categoriesMode,
                onTap: () => setState(() => _categoriesMode = false),
              ),
              const SizedBox(width: 8),
              FilterChipButton(
                label: 'Санаттар',
                selected: _categoriesMode,
                onTap: () => setState(() => _categoriesMode = true),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (query.isEmpty) ...[
            Text('Танымал іздеулер', style: AppText.h3),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _popularQueries)
                  FilterChipButton(
                    label: item,
                    selected: false,
                    onTap: () => _setQuery(item),
                  ),
              ],
            ),
          ] else if (_categoriesMode)
            _CategoryResults(query: query, categories: categories)
          else
            _ProductResults(query: query, results: results),
          const SizedBox(height: 28),
          Text('Сізге ұнауы мүмкін', style: AppText.h2),
          const SizedBox(height: 12),
          ProductGrid(products: suggestions),
          const SizedBox(height: 16),
          Text(
            'Танымал іздеулер: құлаққап, шам, бөтелке',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({required this.query, required this.results});

  final String query;
  final List<Product> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: '«$query» бойынша ештеңе табылмады',
        message: 'Басқа сөз енгізіп көріңіз немесе санаттарды қараңыз.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('«$query» нәтижесі', style: AppText.h2),
        const SizedBox(height: 4),
        Text('${results.length} тауар табылды', style: AppText.caption),
        const SizedBox(height: 14),
        ProductGrid(products: results),
      ],
    );
  }
}

class _CategoryResults extends StatelessWidget {
  const _CategoryResults({required this.query, required this.categories});

  final String query;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: '«$query» бойынша санат табылмады',
        message: 'Басқа сөз енгізіп көріңіз.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('«$query» санаттары', style: AppText.h2),
        const SizedBox(height: 12),
        for (final category in categories) ...[
          AppCard(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.catalog, arguments: category),
            child: Row(
              children: [
                Expanded(child: Text(category.name, style: AppText.bodyStrong)),
                const Icon(Icons.chevron_right, color: AppColors.hint),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
