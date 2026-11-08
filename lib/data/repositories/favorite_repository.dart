import '../local/json_store.dart';

class FavoriteRepository {
  FavoriteRepository(this._store);

  final JsonStore _store;

  String _key(String userId, String productId) => '$userId|$productId';

  Set<String> productIds(String userId) {
    return _store
        .all()
        .where((json) => json['userId'] == userId)
        .map((json) => json['productId'] as String)
        .toSet();
  }

  Future<void> add(String userId, String productId) {
    return _store.put(_key(userId, productId), {
      'userId': userId,
      'productId': productId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> remove(String userId, String productId) {
    return _store.delete(_key(userId, productId));
  }

  Future<void> removeProduct(String productId) {
    final keys = _store.keys.where((key) => key.endsWith('|$productId')).toList();
    return _store.deleteAll(keys);
  }
}
