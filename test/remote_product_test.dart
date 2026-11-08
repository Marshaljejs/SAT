import 'package:flutter_test/flutter_test.dart';
import 'package:sat_store_app/data/models/product.dart';
import 'package:sat_store_app/data/remote/models/remote_product.dart';
import 'package:sat_store_app/data/remote/remote_product_mapper.dart';

void main() {
  const remote = RemoteProduct(
    id: 7,
    title: 'Leather Bag',
    description: 'Nice bag',
    category: 'womens-bags',
    price: 20,
    rating: 4.5,
    stock: 4,
    brand: 'Acme',
    images: ['https://example.com/a.png'],
    tags: ['Bag', 'Leather'],
    reviewCount: 3,
  );

  test('RemoteProduct JSON round trip', () {
    final restored = RemoteProduct.fromJson(remote.toJson());
    expect(restored.id, 7);
    expect(restored.title, 'Leather Bag');
    expect(restored.reviewCount, 3);
    expect(restored.tags, ['Bag', 'Leather']);
  });

  test('Mapper links remote product to local model', () {
    final local = RemoteProductMapper.toLocal(remote, 'bags');
    expect(local.id, 'r7');
    expect(local.remoteId, 7);
    expect(local.isRemote, isTrue);
    expect(local.categoryId, 'bags');
    expect(local.price, 9600);
    expect(local.inStock, isTrue);
    expect(local.matches('leather'), isTrue);
    final restored = Product.fromJson(local.toJson());
    expect(restored.remoteId, 7);
  });

  test('Category helpers', () {
    expect(RemoteProductMapper.localCategoryId('furniture'), 'home');
    expect(RemoteProductMapper.localCategoryId('beauty'), isNull);
    expect(RemoteProductMapper.categoryTitle('home-decoration'), 'Home Decoration');
  });
}
