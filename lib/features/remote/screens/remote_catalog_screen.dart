import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/menu_card.dart';
import '../../../core/widgets/net_image.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/remote/api_exceptions.dart';
import '../../../data/remote/models/remote_product.dart';
import '../../../data/remote/product_api.dart';
import '../../../data/remote/remote_product_mapper.dart';
import '../../../data/repositories/remote_cache_repository.dart';
import '../../../data/state/app_state.dart';
import '../state/remote_catalog_controller.dart';
import 'remote_product_form_sheet.dart';

class RemoteCatalogScreen extends StatefulWidget {
  const RemoteCatalogScreen({super.key});

  @override
  State<RemoteCatalogScreen> createState() => _RemoteCatalogScreenState();
}

class _RemoteCatalogScreenState extends State<RemoteCatalogScreen> {
  final ApiClient _client = ApiClient();
  final TextEditingController _search = TextEditingController();
  late final RemoteCatalogController _controller;

  @override
  void initState() {
    super.initState();
    final database = context.read<AppState>().database;
    _controller = RemoteCatalogController(
      api: ProductApi(_client),
      cache: RemoteCacheRepository(database.remoteCache),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _openForm([RemoteProduct? item]) async {
    final result = await showAppSheet<ActionResult>(
      context,
      builder: (sheetContext) => RemoteProductFormSheet(
        initial: item,
        onSubmit: (draft) =>
            item == null ? _controller.create(draft) : _controller.update(item, draft),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    final state = context.read<AppState>();
    final updated = result.product;
    if (item != null && updated != null && state.isLinked(item.id)) {
      await state.importRemoteProduct(updated);
    }
    if (!mounted) {
      return;
    }
    showAppSnack(context, result.message);
  }

  Future<void> _delete(RemoteProduct item) async {
    final state = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Тауарды өшіру'),
        content: Text('«${item.title}» серверден өшіріледі (DELETE).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Бас тарту'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Өшіру', style: AppText.link.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final result = await _controller.remove(item);
    if (!mounted) {
      return;
    }
    if (result.ok) {
      await state.removeLinkedProduct(item.id);
    }
    if (!mounted) {
      return;
    }
    showAppSnack(context, result.message, isError: !result.ok);
  }

  Future<void> _link(RemoteProduct item) async {
    final ok = await context.read<AppState>().importRemoteProduct(item);
    if (!mounted || !ok) {
      return;
    }
    showAppSnack(context, 'Каталогқа сақталды: ${item.title}');
  }

  Future<void> _linkAll() async {
    final state = context.read<AppState>();
    var count = 0;
    for (final item in _controller.items) {
      final ok = await state.importRemoteProduct(item);
      if (!ok) {
        break;
      }
      count += 1;
    }
    if (!mounted || count == 0) {
      return;
    }
    showAppSnack(context, '$count тауар жергілікті каталогқа сақталды');
  }

  Future<void> _openDiagnostics() async {
    final choice = await showAppSheet<int>(
      context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API тексеру', style: AppText.h2),
          const SizedBox(height: 8),
          Text(
            'Қате жағдайлардың өңделуін тексеру үшін арнайы сұраулар.',
            style: AppText.bodyGrey,
          ),
          const SizedBox(height: 16),
          MenuCard(
            children: [
              MenuTile(
                icon: Icons.hourglass_bottom,
                title: 'Timeout (15 с кідіріс)',
                onTap: () => Navigator.of(sheetContext).pop(1),
              ),
              MenuTile(
                icon: Icons.cloud_off_outlined,
                title: 'Сервер қатесі (404)',
                onTap: () => Navigator.of(sheetContext).pop(2),
              ),
            ],
          ),
        ],
      ),
    );
    if (!mounted || choice == null) {
      return;
    }
    final result = choice == 1
        ? await _controller.testTimeout()
        : await _controller.testServerError();
    if (!mounted) {
      return;
    }
    showAppSnack(context, result.message, isError: !result.ok);
  }

  IconData _errorIcon(ApiException? error) {
    if (error is NoInternetException) {
      return Icons.wifi_off;
    }
    if (error is RequestTimeoutException) {
      return Icons.hourglass_bottom;
    }
    return Icons.cloud_off_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppTopBar(
        title: 'Сервер каталогы',
        trailingText: 'Қосу',
        onTrailingTap: _openForm,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final controller = _controller;
          final loadingFirst =
              controller.status == LoadStatus.loading && controller.items.isEmpty;
          return Column(
            children: [
              if (controller.busy || controller.status == LoadStatus.loading)
                const LinearProgressIndicator(minHeight: 3)
              else
                const SizedBox(height: 3),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePadding,
                      8,
                      AppDimens.pagePadding,
                      28,
                    ),
                    children: [
                      TextField(
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        onSubmitted: controller.search,
                        style: AppText.input,
                        decoration: InputDecoration(
                          hintText: 'Серверден іздеу',
                          prefixIcon: const Icon(Icons.search, size: 22),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    _search.clear();
                                    controller.search('');
                                  },
                                ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.status == LoadStatus.success
                                  ? '${controller.items.length} / ${controller.total} тауар'
                                  : 'Сервер: dummyjson.com',
                              style: AppText.caption,
                            ),
                          ),
                          IconButton(
                            tooltip: 'API тексеру',
                            icon: const Icon(Icons.science_outlined, size: 20),
                            onPressed: controller.busy ? null : _openDiagnostics,
                          ),
                        ],
                      ),
                      if (controller.fromCache) ...[
                        InfoBanner(
                          icon: Icons.cloud_off_outlined,
                          background: AppColors.softCitrus,
                          iconColor: AppColors.ink,
                          text:
                              '${controller.error?.message ?? 'Сервер қолжетімсіз.'} Соңғы сақталған деректер көрсетілуде.',
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (loadingFirst)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (controller.status == LoadStatus.error)
                        EmptyState(
                          icon: _errorIcon(controller.error),
                          title: 'Деректерді жүктеу мүмкін болмады',
                          message: controller.error?.message ?? 'Қате орын алды.',
                          actionLabel: 'Қайталау',
                          onAction: controller.load,
                        )
                      else if (controller.status == LoadStatus.success &&
                          controller.items.isEmpty)
                        const EmptyState(
                          icon: Icons.search_off,
                          title: 'Ештеңе табылмады',
                          message: 'Басқа сөз енгізіп көріңіз.',
                        )
                      else ...[
                        if (controller.items.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _linkAll,
                              icon: const Icon(Icons.download_outlined, size: 18),
                              label: const Text('Барлығын каталогқа сақтау'),
                            ),
                          ),
                        for (final item in controller.items) ...[
                          _RemoteProductCard(
                            item: item,
                            linked: state.isLinked(item.id),
                            enabled: !controller.busy,
                            onLink: () => _link(item),
                            onEdit: () => _openForm(item),
                            onDelete: () => _delete(item),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (controller.hasMore)
                          Center(
                            child: controller.loadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(),
                                  )
                                : TextButton(
                                    onPressed: controller.loadMore,
                                    child: const Text('Көбірек жүктеу'),
                                  ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RemoteProductCard extends StatelessWidget {
  const _RemoteProductCard({
    required this.item,
    required this.linked,
    required this.enabled,
    required this.onLink,
    required this.onEdit,
    required this.onDelete,
  });

  final RemoteProduct item;
  final bool linked;
  final bool enabled;
  final VoidCallback onLink;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: NetImage(
                  url: item.image,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyStrong,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      RemoteProductMapper.categoryTitle(item.category),
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.price(RemoteProductMapper.toKzt(item.price))} · \$${item.price.toStringAsFixed(2)}',
                      style: AppText.bodyStrong,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (linked) const AppBadge.success('Каталогта бар'),
              if (item.isSimulated)
                const AppBadge(
                  'Жаңа (симуляция)',
                  background: AppColors.softCitrus,
                  foreground: AppColors.ink,
                ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: enabled ? onLink : null,
                child: Text(linked ? 'Каталогты жаңарту' : 'Каталогқа сақтау'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.cobalt),
                onPressed: enabled ? onEdit : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.grey),
                onPressed: enabled ? onDelete : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
