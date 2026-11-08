import '../local/json_store.dart';
import '../remote/models/remote_product.dart';

class RemoteCacheRepository {
  RemoteCacheRepository(this._store);

  static const String _key = 'products';

  final JsonStore _store;

  List<RemoteProduct>? read() {
    final json = _store.get(_key);
    if (json == null) {
      return null;
    }
    try {
      return (json['items'] as List)
          .map((item) => RemoteProduct.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<RemoteProduct> items) {
    return _store.put(_key, {
      'savedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    });
  }
}
