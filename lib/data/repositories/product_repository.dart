import '../local/json_store.dart';
import '../models/product.dart';

enum ProductSort {
  popular('Танымалдары'),
  priceAsc('Бағасы: өсу бойынша'),
  priceDesc('Бағасы: кему бойынша'),
  nameAsc('Атауы: А–Я'),
  newest('Жаңалары алдымен');

  const ProductSort(this.label);

  final String label;
}

class ProductRepository {
  ProductRepository(this._store);

  final JsonStore _store;

  int get count => _store.length;

  String newId() => 'p${DateTime.now().microsecondsSinceEpoch}';

  List<Product> all() {
    final list = <Product>[];
    for (final json in _store.all()) {
      try {
        list.add(Product.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    return list;
  }

  Product? byId(String id) {
    final json = _store.get(id);
    if (json == null) {
      return null;
    }
    try {
      return Product.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Product product) => _store.put(product.id, product.toJson());

  Future<void> delete(String id) => _store.delete(id);

  List<Product> popular() {
    final list = all();
    list.sort((a, b) => b.popularity.compareTo(a.popularity));
    return list;
  }

  int priceCeiling() {
    var max = 50000;
    for (final product in all()) {
      if (product.price > max) {
        max = product.price;
      }
    }
    return ((max / 5000).ceil()) * 5000;
  }

  List<Product> filter({
    String? categoryId,
    String query = '',
    int minPrice = 0,
    int maxPrice = 100000000,
    bool onlyInStock = false,
    ProductSort sort = ProductSort.popular,
  }) {
    final q = query.trim().toLowerCase();
    final list = all().where((product) {
      final categoryOk = categoryId == null || product.categoryId == categoryId;
      final priceOk = product.price >= minPrice && product.price <= maxPrice;
      final stockOk = !onlyInStock || product.inStock;
      final queryOk = q.isEmpty || product.matches(q);
      return categoryOk && priceOk && stockOk && queryOk;
    }).toList();
    switch (sort) {
      case ProductSort.popular:
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
      case ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case ProductSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<Product> search(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return const [];
    }
    return filter(query: q);
  }

  List<Product> suggestions({Iterable<String> excludeIds = const [], int limit = 2}) {
    final excluded = excludeIds.toSet();
    return popular().where((product) => !excluded.contains(product.id)).take(limit).toList();
  }
}
