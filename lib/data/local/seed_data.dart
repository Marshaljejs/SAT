import 'package:flutter/material.dart';

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../../core/constants/app_config.dart';

class SeedData {
  const SeedData._();

  static const List<Category> categories = [
    Category(id: 'bags', name: 'Сөмкелер', order: 1),
    Category(id: 'audio', name: 'Аудио', order: 2),
    Category(id: 'home', name: 'Үйге', order: 3),
  ];

  static const List<Product> products = [
    Product(
      id: '1',
      name: 'SÄT Move сөмкесі',
      subtitle: 'Кросс-боди · Қара',
      tagline: 'Кросс-боди · Қайта өңделген нейлон',
      price: 24900,
      images: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=900&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=900&auto=format&fit=crop',
      ],
      categoryId: 'bags',
      colors: [
        ProductColor(name: 'Қара', color: Color(0xFF20231F)),
        ProductColor(name: 'Бежді', color: Color(0xFFC9BFA9)),
        ProductColor(name: 'Жасыл', color: Color(0xFF5E7A5F)),
      ],
      description:
          'Қалада да, сапарда да жеңіл жүрісіз. Су жұқтырмайтын мата, реттелетін бау және ақылды заттарға арналған ішкі қалта.',
      specs: [
        ProductSpec('Өлшемі', '24 × 16 × 7 см'),
        ProductSpec('Көлемі / салмағы', '2,7 л / 220 г'),
      ],
      cartInfo: '2,7 л',
      deliveryTime: '1–3 жұмыс күні',
      rating: 4.9,
      reviews: 48,
      popularity: 100,
      keywords: ['сөмке', 'кросс', 'bag'],
      createdAt: 4,
      isNew: true,
    ),
    Product(
      id: '2',
      name: 'SÄT Sound құлаққабы',
      subtitle: 'Сымсыз',
      tagline: 'Сымсыз · Шуды басу',
      price: 39900,
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=900&auto=format&fit=crop',
      ],
      categoryId: 'audio',
      colors: [
        ProductColor(name: 'Бежді', color: Color(0xFFD9CDB8)),
        ProductColor(name: 'Қара', color: Color(0xFF20231F)),
      ],
      description:
          'Шуды басатын сымсыз құлаққап. Бір зарядпен 40 сағатқа дейін жұмыс істейді, жұмсақ жастықшалары күні бойы ыңғайлы.',
      specs: [
        ProductSpec('Өлшемі', '19 × 17 × 8 см'),
        ProductSpec('Жұмыс уақыты / салмағы', '40 сағ / 250 г'),
      ],
      cartInfo: '40 сағ',
      deliveryTime: '1–3 жұмыс күні',
      rating: 4.8,
      reviews: 73,
      popularity: 90,
      keywords: ['құлаққап', 'наушник', 'аудио', 'headphones'],
      createdAt: 3,
    ),
    Product(
      id: '3',
      name: 'SÄT Light шамы',
      subtitle: 'Үстел шамы · Жылы жарық',
      tagline: 'Үстел шамы · Жылы жарық',
      price: 32900,
      images: [
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?q=80&w=900&auto=format&fit=crop',
      ],
      categoryId: 'home',
      colors: [
        ProductColor(name: 'Бежді', color: Color(0xFFD9CDB8)),
        ProductColor(name: 'Ақ', color: Color(0xFFF1EFEA)),
      ],
      description:
          'Жылы жарығы бар үстел шамы. Жұмсақ жарық кешкі уақытты жайлы етеді, түймені басқанда жарықтығы өзгереді.',
      specs: [
        ProductSpec('Биіктігі', '32 см'),
        ProductSpec('Жарық / қуаты', '3 режим / 8 Вт'),
      ],
      cartInfo: '32 см',
      deliveryTime: '1–3 жұмыс күні',
      rating: 4.8,
      reviews: 31,
      popularity: 70,
      keywords: ['шам', 'шәм', 'лампа', 'жарық'],
      createdAt: 2,
    ),
    Product(
      id: '4',
      name: 'SÄT Flow бөтелкесі',
      subtitle: '500 мл · Көк',
      tagline: 'Термобөтелке · Тот баспайтын болат',
      price: 12900,
      images: [
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?q=80&w=900&auto=format&fit=crop',
      ],
      categoryId: 'home',
      colors: [
        ProductColor(name: 'Көк', color: Color(0xFF2748C4)),
        ProductColor(name: 'Қара', color: Color(0xFF20231F)),
        ProductColor(name: 'Бежді', color: Color(0xFFD9CDB8)),
      ],
      description:
          'Ыстықты 12 сағат, суықты 24 сағат сақтайтын болат термобөтелке. Жабық қақпағы сөмкеде де ағып кетпейді.',
      specs: [
        ProductSpec('Өлшемі', '7 × 26 см'),
        ProductSpec('Көлемі / салмағы', '500 мл / 310 г'),
      ],
      cartInfo: '500 мл',
      deliveryTime: '1–3 жұмыс күні',
      rating: 4.7,
      reviews: 64,
      popularity: 60,
      keywords: ['бөтелке', 'термос', 'су', 'bottle'],
      createdAt: 1,
    ),
  ];

  static Address address() {
    return const Address(
      id: 'a1',
      label: 'Үй',
      fullName: 'Айдана Серікқызы',
      phone: '+7 (701) 234 56 78',
      city: 'Алматы',
      street: 'Абай даңғылы, 52',
      apartment: '24',
      postalCode: '050000',
      isDefault: true,
    );
  }

  static List<Order> orders(Address address) {
    final bag = products[0];
    final lamp = products[2];
    return [
      Order(
        id: 'SÄT-1024',
        items: [CartItem(product: bag, colorIndex: 0)],
        address: address,
        status: OrderStatus.preparing,
        createdAt: DateTime(2026, 10, 28, 15, 42),
        deliveryFrom: DateTime(2026, 10, 30),
        deliveryTo: DateTime(2026, 11, 1),
        subtotal: bag.price,
        deliveryFee: AppConfig.deliveryFee,
        discount: 0,
        paymentLabel: AppConfig.paymentCardLabel,
        isPaid: true,
      ),
      Order(
        id: 'SÄT-0981',
        items: [CartItem(product: lamp, colorIndex: 0)],
        address: address,
        status: OrderStatus.delivered,
        createdAt: DateTime(2026, 10, 12, 11, 20),
        deliveryFrom: DateTime(2026, 10, 13),
        deliveryTo: DateTime(2026, 10, 15),
        subtotal: lamp.price,
        deliveryFee: AppConfig.deliveryFee,
        discount: 0,
        paymentLabel: AppConfig.paymentCardLabel,
        isPaid: true,
      ),
    ];
  }
}
