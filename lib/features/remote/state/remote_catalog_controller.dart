import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/constants/app_config.dart';
import '../../../data/remote/api_exceptions.dart';
import '../../../data/remote/models/remote_product.dart';
import '../../../data/remote/product_api.dart';
import '../../../data/repositories/remote_cache_repository.dart';

enum LoadStatus { idle, loading, success, error }

class ActionResult {
  const ActionResult.ok(this.message, [this.product]) : ok = true;

  const ActionResult.fail(this.message)
      : ok = false,
        product = null;

  final bool ok;
  final String message;
  final RemoteProduct? product;
}

class RemoteCatalogController extends ChangeNotifier {
  RemoteCatalogController({required this.api, required this.cache});

  final ProductApi api;
  final RemoteCacheRepository cache;

  LoadStatus _status = LoadStatus.idle;
  List<RemoteProduct> _items = [];
  ApiException? _error;
  bool _fromCache = false;
  bool _busy = false;
  bool _loadingMore = false;
  bool _disposed = false;
  String _query = '';
  int _total = 0;
  int _serverCount = 0;
  int _nextSimulatedId = 100000;

  LoadStatus get status => _status;
  List<RemoteProduct> get items => List.unmodifiable(_items);
  ApiException? get error => _error;
  bool get fromCache => _fromCache;
  bool get busy => _busy;
  bool get loadingMore => _loadingMore;
  String get query => _query;
  int get total => _total;
  bool get hasMore => !_fromCache && _serverCount < _total;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<RemotePage> _request(int skip) {
    if (_query.isEmpty) {
      return api.fetchProducts(limit: AppConfig.remotePageSize, skip: skip);
    }
    return api.searchProducts(_query, limit: AppConfig.remotePageSize, skip: skip);
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _notify();
    try {
      final page = await _request(0);
      _items = page.items;
      _total = page.total;
      _serverCount = page.items.length;
      _fromCache = false;
      _status = LoadStatus.success;
      if (_query.isEmpty) {
        try {
          await cache.write(page.items);
        } catch (_) {
          _fromCache = false;
        }
      }
    } on ApiException catch (error) {
      _error = error;
      final cached = _query.isEmpty ? cache.read() : null;
      if (cached != null && cached.isNotEmpty) {
        _items = cached;
        _total = cached.length;
        _serverCount = cached.length;
        _fromCache = true;
        _status = LoadStatus.success;
      } else {
        _items = [];
        _status = LoadStatus.error;
      }
    }
    _notify();
  }

  Future<void> loadMore() async {
    if (!hasMore || _loadingMore) {
      return;
    }
    _loadingMore = true;
    _notify();
    try {
      final page = await _request(_serverCount);
      _items = [..._items, ...page.items];
      _serverCount += page.items.length;
      _total = page.total;
    } on ApiException catch (error) {
      _error = error;
    }
    _loadingMore = false;
    _notify();
  }

  Future<void> search(String value) {
    _query = value.trim();
    return load();
  }

  Future<ActionResult> _run(Future<ActionResult> Function() action) async {
    _busy = true;
    _notify();
    ActionResult result;
    try {
      result = await action();
    } on ApiException catch (error) {
      result = ActionResult.fail(error.message);
    } catch (_) {
      result = const ActionResult.fail('Күтпеген қате орын алды. Қайталап көріңіз.');
    }
    _busy = false;
    _notify();
    return result;
  }

  Future<ActionResult> create(RemoteProductDraft draft) {
    return _run(() async {
      final created = await api.createProduct(draft);
      final item = created.copyWith(
        id: _nextSimulatedId++,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        price: draft.price,
        stock: created.stock > 0 ? created.stock : 10,
        isSimulated: true,
      );
      _items = [item, ..._items];
      _total += 1;
      return ActionResult.ok('POST орындалды: тауар серверге жіберілді (id ${created.id})', item);
    });
  }

  Future<ActionResult> update(RemoteProduct item, RemoteProductDraft draft) {
    return _run(() async {
      final String message;
      if (item.isSimulated) {
        message = 'Демо-сервер жаңа жазбаны сақтамайды: өзгеріс қосымшада жаңартылды';
      } else {
        await api.updateProduct(item.id, draft);
        message = 'PATCH орындалды: тауар серверде өзгертілді';
      }
      final updated = item.copyWith(
        title: draft.title,
        description: draft.description,
        category: draft.category,
        price: draft.price,
      );
      _items = _items.map((entry) => entry.id == item.id ? updated : entry).toList();
      return ActionResult.ok(message, updated);
    });
  }

  Future<ActionResult> remove(RemoteProduct item) {
    return _run(() async {
      final String message;
      if (item.isSimulated) {
        message = 'Демо-сервер жаңа жазбаны сақтамайды: тауар тізімнен өшірілді';
      } else {
        await api.deleteProduct(item.id);
        message = 'DELETE орындалды: тауар серверден өшірілді';
        _total = _total > 0 ? _total - 1 : 0;
        _serverCount = _serverCount > 0 ? _serverCount - 1 : 0;
      }
      _items = _items.where((entry) => entry.id != item.id).toList();
      return ActionResult.ok(message, item);
    });
  }

  Future<ActionResult> testTimeout() {
    return _run(() async {
      await api.slowRequest();
      return const ActionResult.ok('Сервер жауап берді');
    });
  }

  Future<ActionResult> testServerError() {
    return _run(() async {
      await api.missingRequest();
      return const ActionResult.ok('Сервер жауап берді');
    });
  }
}
