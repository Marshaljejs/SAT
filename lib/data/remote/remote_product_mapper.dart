import '../../core/constants/app_config.dart';
import '../models/product.dart';
import 'models/remote_product.dart';

class RemoteProductMapper {
  const RemoteProductMapper._();

  static const Map<String, String> _categoryMap = {
    'womens-bags': 'bags',
    'mobile-accessories': 'audio',
    'home-decoration': 'home',
    'furniture': 'home',
    'kitchen-accessories': 'home',
  };

  static const List<String> formCategories = [
    'womens-bags',
    'mobile-accessories',
    'home-decoration',
    'furniture',
    'kitchen-accessories',
  ];

  static String? localCategoryId(String slug) => _categoryMap[slug];

  static String categoryTitle(String slug) {
    if (slug.isEmpty) {
      return 'Басқа';
    }
    return slug
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static int toKzt(double usd) {
    final value = ((usd * AppConfig.usdToKzt) / 100).round() * 100;
    return value < 100 ? 100 : value;
  }

  static String localId(int remoteId) => 'r$remoteId';

  static Product toLocal(RemoteProduct remote, String categoryId, {Product? existing}) {
    final title = categoryTitle(remote.category);
    final brand = remote.brand;
    final subtitle = (brand == null || brand.isEmpty) ? title : '$brand · $title';
    final images = remote.images.isNotEmpty
        ? remote.images
        : (remote.thumbnail.isEmpty ? <String>[] : [remote.thumbnail]);
    final words = remote.title
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1);
    return Product(
      id: localId(remote.id),
      name: remote.title,
      subtitle: subtitle,
      tagline: subtitle,
      price: toKzt(remote.price),
      images: images,
      categoryId: categoryId,
      colors: existing?.colors ?? const [ProductColor.fallback],
      description: remote.description,
      specs: [
        ProductSpec('Санат', title),
        ProductSpec('Қоймада', '${remote.stock} дана'),
      ],
      cartInfo: '',
      deliveryTime: '1–3 жұмыс күні',
      rating: remote.rating,
      reviews: remote.reviewCount,
      popularity: (remote.rating * 20).round(),
      keywords: [...remote.tags.map((tag) => tag.toLowerCase()), ...words],
      createdAt: existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      isNew: false,
      inStock: remote.stock > 0,
      remoteId: remote.id,
    );
  }
}
