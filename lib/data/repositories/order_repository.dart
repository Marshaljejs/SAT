import '../local/json_store.dart';
import '../models/order.dart';

class OrderRepository {
  OrderRepository(this._store);

  final JsonStore _store;

  List<Order> forUser(String userId) {
    final list = <Order>[];
    for (final json in _store.all()) {
      if (json['userId'] != userId) {
        continue;
      }
      try {
        list.add(Order.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> save(String userId, Order order) {
    return _store.put('$userId|${order.id}', {...order.toJson(), 'userId': userId});
  }
}
