import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/constants/app_config.dart';
import '../local/app_database.dart';
import '../local/database_exception.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../repositories/address_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/user_repository.dart';
import '../remote/models/remote_product.dart';
import '../remote/remote_product_mapper.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.database) {
    _city = _settingsRepo.city;
    _notifyOrders = _settingsRepo.notifyOrders;
    _notifyCollections = _settingsRepo.notifyCollections;
    _notifyOffers = _settingsRepo.notifyOffers;
    _orderSequence = _settingsRepo.orderSequence;
    _categories = _categoryRepo.all();
    final sessionId = _settingsRepo.sessionUserId;
    if (sessionId != null) {
      _user = _userRepo.byId(sessionId);
      _loadUserData();
    }
  }

  final AppDatabase database;

  late final SettingsRepository _settingsRepo = SettingsRepository(database.settings);
  late final CategoryRepository _categoryRepo = CategoryRepository(database.categories);
  late final UserRepository _userRepo = UserRepository(database.users);
  late final AddressRepository _addressRepo = AddressRepository(database.addresses);
  late final OrderRepository _orderRepo = OrderRepository(database.orders);
  late final FavoriteRepository _favoriteRepo = FavoriteRepository(database.favorites);
  late final CartRepository _cartRepo = CartRepository(database.cart);
  late final ProductRepository products = ProductRepository(database.products);
  late final AuthService auth = AuthService(_userRepo);

  UserProfile? _user;
  int _tab = 0;
  String _city = AppConfig.cities.first;
  String? _promoCode;
  String? _error;
  int _orderSequence = 1025;
  bool _notifyOrders = true;
  bool _notifyCollections = true;
  bool _notifyOffers = false;
  List<Category> _categories = [];

  final Set<String> _favorites = <String>{};
  final List<CartItem> _cart = <CartItem>[];
  final List<Address> _addresses = <Address>[];
  final List<Order> _orders = <Order>[];

  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;
  int get currentTab => _tab;
  String get city => _city;
  String? get promoCode => _promoCode;
  bool get notifyOrders => _notifyOrders;
  bool get notifyCollections => _notifyCollections;
  bool get notifyOffers => _notifyOffers;
  List<Category> get categories => List.unmodifiable(_categories);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Address> get addresses => List.unmodifiable(_addresses);
  List<Order> get orders => List.unmodifiable(_orders);

  String? takeError() {
    final value = _error;
    _error = null;
    return value;
  }

  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on DatabaseException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Деректер қорымен жұмыс кезінде қате болды. Қайталап көріңіз.';
    }
    notifyListeners();
    return false;
  }

  void _loadUserData() {
    final profile = _user;
    _favorites.clear();
    _cart.clear();
    _addresses.clear();
    _orders.clear();
    if (profile == null) {
      return;
    }
    _favorites.addAll(
      _favoriteRepo.productIds(profile.id).where((id) => products.byId(id) != null),
    );
    _cart.addAll(_cartRepo.items(profile.id, products));
    _addresses.addAll(_addressRepo.forUser(profile.id));
    _orders.addAll(_orderRepo.forUser(profile.id));
  }

  Future<void> startSession(UserProfile profile) async {
    await _guard(() => _settingsRepo.setSessionUserId(profile.id));
    _user = profile;
    _tab = 0;
    _promoCode = null;
    _loadUserData();
    notifyListeners();
  }

  Future<void> endSession() async {
    await _guard(() => _settingsRepo.setSessionUserId(null));
    _user = null;
    _tab = 0;
    _promoCode = null;
    _loadUserData();
    notifyListeners();
  }

  void setTab(int index) {
    if (_tab == index) {
      return;
    }
    _tab = index;
    notifyListeners();
  }

  Future<void> setCity(String value) async {
    if (!await _guard(() => _settingsRepo.setCity(value))) {
      return;
    }
    _city = value;
    notifyListeners();
  }

  Future<void> setNotifyOrders(bool value) async {
    if (!await _guard(() => _settingsRepo.setNotifyOrders(value))) {
      return;
    }
    _notifyOrders = value;
    notifyListeners();
  }

  Future<void> setNotifyCollections(bool value) async {
    if (!await _guard(() => _settingsRepo.setNotifyCollections(value))) {
      return;
    }
    _notifyCollections = value;
    notifyListeners();
  }

  Future<void> setNotifyOffers(bool value) async {
    if (!await _guard(() => _settingsRepo.setNotifyOffers(value))) {
      return;
    }
    _notifyOffers = value;
    notifyListeners();
  }

  Future<String?> updateProfile(UserProfile profile) async {
    final error = await auth.updateProfile(profile);
    if (error != null) {
      return error;
    }
    _user = profile;
    notifyListeners();
    return null;
  }

  Future<String?> changePassword(String current, String next) async {
    final profile = _user;
    if (profile == null) {
      return 'Аккаунт табылмады';
    }
    return auth.changePassword(profile.id, current, next);
  }

  List<Category> searchCategories(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const [];
    }
    final all = products.all();
    return _categories.where((category) {
      if (category.name.toLowerCase().contains(q)) {
        return true;
      }
      return all.any((product) => product.categoryId == category.id && product.matches(q));
    }).toList();
  }

  String categoryName(String id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return '—';
  }

  Future<bool> saveProduct(Product product) async {
    final ok = await _guard(() => products.save(product));
    if (!ok) {
      return false;
    }
    _cart
      ..clear()
      ..addAll(_user == null ? const <CartItem>[] : _cartRepo.items(_user!.id, products));
    notifyListeners();
    return true;
  }

  Future<bool> deleteProduct(String id) async {
    final ok = await _guard(() async {
      await products.delete(id);
      await _favoriteRepo.removeProduct(id);
      await _cartRepo.removeProduct(id);
    });
    if (!ok) {
      return false;
    }
    _favorites.remove(id);
    _cart.removeWhere((item) => item.product.id == id);
    notifyListeners();
    return true;
  }

  bool isLinked(int remoteId) => products.byId(RemoteProductMapper.localId(remoteId)) != null;

  Future<String?> _ensureCategory(String slug) async {
    final mapped = RemoteProductMapper.localCategoryId(slug);
    final id = mapped ?? (slug.isEmpty ? 'other' : slug);
    if (_categories.any((category) => category.id == id)) {
      return id;
    }
    final category = Category(
      id: id,
      name: RemoteProductMapper.categoryTitle(slug),
      order: 100 + _categories.length,
    );
    final ok = await _guard(() => _categoryRepo.save(category));
    if (!ok) {
      return null;
    }
    _categories = [..._categories, category];
    notifyListeners();
    return id;
  }

  Future<bool> importRemoteProduct(RemoteProduct remote) async {
    final categoryId = await _ensureCategory(remote.category);
    if (categoryId == null) {
      return false;
    }
    final existing = products.byId(RemoteProductMapper.localId(remote.id));
    final product = RemoteProductMapper.toLocal(remote, categoryId, existing: existing);
    return saveProduct(product);
  }

  Future<void> removeLinkedProduct(int remoteId) async {
    final id = RemoteProductMapper.localId(remoteId);
    if (products.byId(id) != null) {
      await deleteProduct(id);
    }
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  int get favoritesCount => _favorites.length;

  List<Product> get favoriteProducts {
    final list = <Product>[];
    for (final id in _favorites) {
      final product = products.byId(id);
      if (product != null) {
        list.add(product);
      }
    }
    return list;
  }

  Future<void> toggleFavorite(String productId) async {
    final profile = _user;
    if (profile == null) {
      return;
    }
    final adding = !_favorites.contains(productId);
    final ok = await _guard(
      () => adding
          ? _favoriteRepo.add(profile.id, productId)
          : _favoriteRepo.remove(profile.id, productId),
    );
    if (!ok) {
      return;
    }
    if (adding) {
      _favorites.add(productId);
    } else {
      _favorites.remove(productId);
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product, int colorIndex) async {
    final profile = _user;
    if (profile == null) {
      return;
    }
    final index = _cart.indexWhere(
      (item) => item.product.id == product.id && item.colorIndex == colorIndex,
    );
    final CartItem item;
    if (index == -1) {
      item = CartItem(product: product, colorIndex: colorIndex);
    } else {
      final current = _cart[index];
      item = current.copyWith(quantity: (current.quantity + 1).clamp(1, 10));
    }
    final ok = await _guard(() => _cartRepo.save(profile.id, item));
    if (!ok) {
      return;
    }
    if (index == -1) {
      _cart.add(item);
    } else {
      _cart[index] = item;
    }
    notifyListeners();
  }

  Future<void> changeQuantity(CartItem item, int delta) async {
    final profile = _user;
    final index = _cart.indexWhere((entry) => entry.key == item.key);
    if (profile == null || index == -1) {
      return;
    }
    final next = _cart[index].quantity + delta;
    if (next < 1 || next > 10) {
      return;
    }
    final updated = _cart[index].copyWith(quantity: next);
    final ok = await _guard(() => _cartRepo.save(profile.id, updated));
    if (!ok) {
      return;
    }
    _cart[index] = updated;
    notifyListeners();
  }

  Future<void> removeFromCart(CartItem item) async {
    final profile = _user;
    if (profile == null) {
      return;
    }
    final ok = await _guard(() => _cartRepo.remove(profile.id, item));
    if (!ok) {
      return;
    }
    _cart.removeWhere((entry) => entry.key == item.key);
    notifyListeners();
  }

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _cart.fold(0, (sum, item) => sum + item.lineTotal);

  int get discount {
    if (_promoCode == null) {
      return 0;
    }
    return (subtotal * AppConfig.promoPercent / 100).round();
  }

  int get deliveryFee {
    if (_cart.isEmpty || subtotal >= AppConfig.freeDeliveryFrom) {
      return 0;
    }
    return AppConfig.deliveryFee;
  }

  int get total => subtotal - discount + deliveryFee;

  int get remainingForFreeDelivery {
    final remaining = AppConfig.freeDeliveryFrom - subtotal;
    return remaining < 0 ? 0 : remaining;
  }

  bool applyPromo(String code) {
    if (code.trim().toUpperCase() == AppConfig.promoCode) {
      _promoCode = AppConfig.promoCode;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromo() {
    _promoCode = null;
    notifyListeners();
  }

  Address? get defaultAddress {
    if (_addresses.isEmpty) {
      return null;
    }
    return _addresses.firstWhere((address) => address.isDefault, orElse: () => _addresses.first);
  }

  Address? addressById(String? id) {
    if (id == null) {
      return null;
    }
    for (final address in _addresses) {
      if (address.id == id) {
        return address;
      }
    }
    return null;
  }

  String newAddressId() => 'a${DateTime.now().microsecondsSinceEpoch}';

  void _ensureDefault(List<Address> list) {
    if (list.isEmpty || list.any((address) => address.isDefault)) {
      return;
    }
    list[0] = list[0].copyWith(isDefault: true);
  }

  Future<Address?> saveAddress(Address address) async {
    final profile = _user;
    if (profile == null) {
      return null;
    }
    var value = address;
    if (_addresses.isEmpty) {
      value = value.copyWith(isDefault: true);
    }
    final next = List<Address>.from(_addresses);
    if (value.isDefault) {
      for (var i = 0; i < next.length; i++) {
        if (next[i].id != value.id && next[i].isDefault) {
          next[i] = next[i].copyWith(isDefault: false);
        }
      }
    }
    final index = next.indexWhere((entry) => entry.id == value.id);
    if (index == -1) {
      next.add(value);
    } else {
      next[index] = value;
    }
    _ensureDefault(next);
    final ok = await _guard(() => _addressRepo.replaceAll(profile.id, next));
    if (!ok) {
      return null;
    }
    _addresses
      ..clear()
      ..addAll(next);
    notifyListeners();
    return next.firstWhere((entry) => entry.id == value.id);
  }

  Future<bool> deleteAddress(String id) async {
    final profile = _user;
    if (profile == null) {
      return false;
    }
    final next = _addresses.where((address) => address.id != id).toList();
    _ensureDefault(next);
    final ok = await _guard(() => _addressRepo.replaceAll(profile.id, next));
    if (!ok) {
      return false;
    }
    _addresses
      ..clear()
      ..addAll(next);
    notifyListeners();
    return true;
  }

  Future<Order?> placeOrder({required Address address, required bool payByCard}) async {
    final profile = _user;
    if (profile == null || _cart.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    final order = Order(
      id: 'SÄT-$_orderSequence',
      items: List<CartItem>.from(_cart),
      address: address,
      status: OrderStatus.preparing,
      createdAt: now,
      deliveryFrom: now.add(const Duration(days: 1)),
      deliveryTo: now.add(const Duration(days: 3)),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      paymentLabel: payByCard ? AppConfig.paymentCardLabel : AppConfig.paymentCashLabel,
      isPaid: payByCard,
    );
    final ok = await _guard(() async {
      await _orderRepo.save(profile.id, order);
      await _cartRepo.clear(profile.id);
      await _settingsRepo.setOrderSequence(_orderSequence + 1);
    });
    if (!ok) {
      return null;
    }
    _orderSequence += 1;
    _orders.insert(0, order);
    _cart.clear();
    _promoCode = null;
    notifyListeners();
    return order;
  }

  Order? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) {
        return order;
      }
    }
    return null;
  }
}
