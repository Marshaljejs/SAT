class RemoteProduct {
  const RemoteProduct({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.price = 0,
    this.rating = 0,
    this.stock = 0,
    this.brand,
    this.thumbnail = '',
    this.images = const [],
    this.tags = const [],
    this.reviewCount = 0,
    this.isSimulated = false,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final int reviewCount;
  final bool isSimulated;

  String get image {
    if (images.isNotEmpty) {
      return images.first;
    }
    return thumbnail;
  }

  RemoteProduct copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    int? stock,
    bool? isSimulated,
  }) {
    return RemoteProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating,
      stock: stock ?? this.stock,
      brand: brand,
      thumbnail: thumbnail,
      images: images,
      tags: tags,
      reviewCount: reviewCount,
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'tags': tags,
      'reviewCount': reviewCount,
    };
  }

  factory RemoteProduct.fromJson(Map<String, dynamic> json) {
    final reviews = json['reviews'];
    return RemoteProduct(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: (json['thumbnail'] as String?) ?? '',
      images: ((json['images'] as List?) ?? const []).map((item) => item.toString()).toList(),
      tags: ((json['tags'] as List?) ?? const []).map((item) => item.toString()).toList(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? (reviews is List ? reviews.length : 0),
    );
  }
}

class RemoteProductDraft {
  const RemoteProductDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
  });

  final String title;
  final String description;
  final String category;
  final double price;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
    };
  }
}

class RemotePage {
  const RemotePage({required this.items, required this.total});

  final List<RemoteProduct> items;
  final int total;
}
