import '../local/json_store.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._store);

  final JsonStore _store;

  List<Category> all() {
    final list = <Category>[];
    for (final json in _store.all()) {
      try {
        list.add(Category.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<void> save(Category category) => _store.put(category.id, category.toJson());
}
