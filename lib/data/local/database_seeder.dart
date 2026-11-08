import '../../core/constants/app_config.dart';
import '../models/cart_item.dart';
import '../models/user_profile.dart';
import '../repositories/address_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/user_repository.dart';
import 'app_database.dart';
import 'seed_data.dart';

class DatabaseSeeder {
  DatabaseSeeder(this._db);

  final AppDatabase _db;

  Future<void> run() async {
    final settings = SettingsRepository(_db.settings);
    if (settings.isSeeded) {
      return;
    }
    final categories = CategoryRepository(_db.categories);
    final products = ProductRepository(_db.products);
    final users = UserRepository(_db.users);
    final addresses = AddressRepository(_db.addresses);
    final orders = OrderRepository(_db.orders);
    final favorites = FavoriteRepository(_db.favorites);
    final cart = CartRepository(_db.cart);

    for (final category in SeedData.categories) {
      await categories.save(category);
    }
    for (final product in SeedData.products) {
      await products.save(product);
    }

    const demo = UserProfile(
      id: AppConfig.demoUserId,
      name: 'Айдана Серікқызы',
      email: AppConfig.demoEmail,
      phone: AppConfig.demoPhone,
    );
    await users.create(demo, AppConfig.demoPassword);

    final address = SeedData.address();
    await addresses.replaceAll(demo.id, [address]);
    for (final order in SeedData.orders(address)) {
      await orders.save(demo.id, order);
    }
    for (final id in const ['1', '2', '3']) {
      await favorites.add(demo.id, id);
    }
    await cart.save(demo.id, CartItem(product: SeedData.products.first, colorIndex: 0));
    await settings.markSeeded();
  }
}
