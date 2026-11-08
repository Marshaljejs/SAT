import 'product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.colorIndex,
    this.quantity = 1,
  });

  final Product product;
  final int colorIndex;
  final int quantity;

  String get key => '${product.id}_$colorIndex';

  int get _safeIndex => colorIndex.clamp(0, product.colors.length - 1);

  String get colorName => product.colors[_safeIndex].name;

  int get lineTotal => product.price * quantity;

  String get info => product.cartInfo.isEmpty ? colorName : '$colorName · ${product.cartInfo}';

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      colorIndex: colorIndex,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toSnapshotJson() {
    return {
      'product': product.toJson(),
      'colorIndex': colorIndex,
      'quantity': quantity,
    };
  }

  factory CartItem.fromSnapshotJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      colorIndex: (json['colorIndex'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}
