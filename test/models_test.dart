import 'package:flutter_test/flutter_test.dart';
import 'package:sat_store_app/data/local/seed_data.dart';
import 'package:sat_store_app/data/models/order.dart';
import 'package:sat_store_app/data/models/product.dart';

void main() {
  test('Product JSON round trip', () {
    final original = SeedData.products.first;
    final restored = Product.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.price, original.price);
    expect(restored.colors.length, original.colors.length);
    expect(restored.colors.first.color, original.colors.first.color);
    expect(restored.specs.length, original.specs.length);
  });

  test('Order JSON round trip keeps product snapshot', () {
    final order = SeedData.orders(SeedData.address()).first;
    final restored = Order.fromJson(order.toJson());
    expect(restored.id, order.id);
    expect(restored.total, order.total);
    expect(restored.items.first.product.name, order.items.first.product.name);
    expect(restored.address.city, order.address.city);
    expect(restored.status, order.status);
  });

  test('Product filter helpers', () {
    final product = SeedData.products[1];
    expect(product.matches('құлаққап'), isTrue);
    expect(product.matches('шам'), isFalse);
  });
}
