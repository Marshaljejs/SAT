import 'package:flutter/material.dart';

class ProductColor {
  const ProductColor({required this.name, required this.color});

  final String name;
  final Color color;

  static const ProductColor fallback = ProductColor(name: 'Қара', color: Color(0xFF20231F));

  Map<String, dynamic> toJson() => {'name': name, 'value': color.toARGB32()};

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      name: json['name'] as String,
      color: Color((json['value'] as num).toInt()),
    );
  }
}

class ProductSpec {
  const ProductSpec(this.label, this.value);

  final String label;
  final String value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(json['label'] as String, json['value'] as String);
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tagline,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.colors,
    required this.description,
    required this.specs,
    required this.cartInfo,
    required this.deliveryTime,
    required this.rating,
    required this.reviews,
    required this.popularity,
    required this.keywords,
    required this.createdAt,
    this.isNew = false,
    this.inStock = true,
    this.remoteId,
  });

  final String id;
  final String name;
  final String subtitle;
  final String tagline;
  final int price;
  final List<String> images;
  final String categoryId;
  final List<ProductColor> colors;
  final String description;
  final List<ProductSpec> specs;
  final String cartInfo;
  final String deliveryTime;
  final double rating;
  final int reviews;
  final int popularity;
  final List<String> keywords;
  final int createdAt;
  final bool isNew;
  final bool inStock;
  final int? remoteId;

  bool get isRemote => remoteId != null;

  List<String> get gallery => images.isEmpty ? const [''] : images;

  String get image => gallery.first;

  String get shortName => name.split(' ').take(2).join(' ');

  bool matches(String query) {
    final q = query.toLowerCase();
    if (name.toLowerCase().contains(q) || subtitle.toLowerCase().contains(q)) {
      return true;
    }
    return keywords.any((keyword) => keyword.toLowerCase().contains(q));
  }

  Product copyWith({
    String? name,
    String? subtitle,
    String? tagline,
    int? price,
    List<String>? images,
    String? categoryId,
    String? description,
    List<String>? keywords,
    bool? isNew,
    bool? inStock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      tagline: tagline ?? this.tagline,
      price: price ?? this.price,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      colors: colors,
      description: description ?? this.description,
      specs: specs,
      cartInfo: cartInfo,
      deliveryTime: deliveryTime,
      rating: rating,
      reviews: reviews,
      popularity: popularity,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt,
      isNew: isNew ?? this.isNew,
      inStock: inStock ?? this.inStock,
      remoteId: remoteId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'tagline': tagline,
      'price': price,
      'images': images,
      'categoryId': categoryId,
      'colors': colors.map((color) => color.toJson()).toList(),
      'description': description,
      'specs': specs.map((spec) => spec.toJson()).toList(),
      'cartInfo': cartInfo,
      'deliveryTime': deliveryTime,
      'rating': rating,
      'reviews': reviews,
      'popularity': popularity,
      'keywords': keywords,
      'createdAt': createdAt,
      'isNew': isNew,
      'inStock': inStock,
      'remoteId': remoteId,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final colors = ((json['colors'] as List?) ?? const [])
        .map((item) => ProductColor.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: (json['subtitle'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      price: (json['price'] as num).toInt(),
      images: ((json['images'] as List?) ?? const []).map((item) => item.toString()).toList(),
      categoryId: (json['categoryId'] as String?) ?? '',
      colors: colors.isEmpty ? const [ProductColor.fallback] : colors,
      description: (json['description'] as String?) ?? '',
      specs: ((json['specs'] as List?) ?? const [])
          .map((item) => ProductSpec.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      cartInfo: (json['cartInfo'] as String?) ?? '',
      deliveryTime: (json['deliveryTime'] as String?) ?? '1–3 жұмыс күні',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      popularity: (json['popularity'] as num?)?.toInt() ?? 0,
      keywords: ((json['keywords'] as List?) ?? const []).map((item) => item.toString()).toList(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      isNew: (json['isNew'] as bool?) ?? false,
      inStock: (json['inStock'] as bool?) ?? true,
      remoteId: (json['remoteId'] as num?)?.toInt(),
    );
  }
}
