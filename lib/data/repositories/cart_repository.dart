import '../local/json_store.dart';
import '../models/cart_item.dart';
import 'product_repository.dart';

class CartRepository {
  CartRepository(this._store);

  final JsonStore _store;

  String _key(String userId, String productId, int colorIndex) {
    return '$userId|$productId|$colorIndex';
  }

  List<CartItem> items(String userId, ProductRepository products) {
    final records = _store.all().where((json) => json['userId'] == userId).toList();
    records.sort((a, b) {
      final first = (a['addedAt'] as num?)?.toInt() ?? 0;
      final second = (b['addedAt'] as num?)?.toInt() ?? 0;
      return first.compareTo(second);
    });
    final list = <CartItem>[];
    for (final json in records) {
      final product = products.byId(json['productId'] as String);
      if (product == null) {
        continue;
      }
      list.add(
        CartItem(
          product: product,
          colorIndex: (json['colorIndex'] as num).toInt(),
          quantity: (json['quantity'] as num).toInt(),
        ),
      );
    }
    return list;
  }

  Future<void> save(String userId, CartItem item) {
    return _store.put(_key(userId, item.product.id, item.colorIndex), {
      'userId': userId,
      'productId': item.product.id,
      'colorIndex': item.colorIndex,
      'quantity': item.quantity,
      'addedAt': DateTime.now().microsecondsSinceEpoch,
    });
  }

  Future<void> remove(String userId, CartItem item) {
    return _store.delete(_key(userId, item.product.id, item.colorIndex));
  }

  Future<void> clear(String userId) {
    final keys = _store.keys.where((key) => key.startsWith('$userId|')).toList();
    return _store.deleteAll(keys);
  }

  Future<void> removeProduct(String productId) {
    final keys = _store.keys.where((key) {
      final parts = key.split('|');
      return parts.length == 3 && parts[1] == productId;
    }).toList();
    return _store.deleteAll(keys);
  }
}
