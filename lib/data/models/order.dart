import 'address.dart';
import 'cart_item.dart';

enum OrderStatus {
  preparing('Дайындалуда', 1),
  shipping('Жолда', 2),
  delivered('Жеткізілді', 3);

  const OrderStatus(this.label, this.stepIndex);

  final String label;
  final int stepIndex;

  bool get isActive => this != OrderStatus.delivered;
}

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.paymentLabel,
    required this.isPaid,
  });

  final String id;
  final List<CartItem> items;
  final Address address;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime deliveryFrom;
  final DateTime deliveryTo;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final String paymentLabel;
  final bool isPaid;

  int get total => subtotal - discount + deliveryFee;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'deliveryFrom': deliveryFrom.toIso8601String(),
      'deliveryTo': deliveryTo.toIso8601String(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'paymentLabel': paymentLabel,
      'isPaid': isPaid,
      'address': address.toJson(),
      'items': items.map((item) => item.toSnapshotJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: OrderStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OrderStatus.preparing,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveryFrom: DateTime.parse(json['deliveryFrom'] as String),
      deliveryTo: DateTime.parse(json['deliveryTo'] as String),
      subtotal: (json['subtotal'] as num).toInt(),
      deliveryFee: (json['deliveryFee'] as num).toInt(),
      discount: (json['discount'] as num).toInt(),
      paymentLabel: json['paymentLabel'] as String,
      isPaid: json['isPaid'] as bool,
      address: Address.fromJson(Map<String, dynamic>.from(json['address'] as Map)),
      items: (json['items'] as List)
          .map((item) => CartItem.fromSnapshotJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
