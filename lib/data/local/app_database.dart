import 'package:hive_flutter/hive_flutter.dart';

import 'database_exception.dart';
import 'database_seeder.dart';
import 'json_store.dart';

class AppDatabase {
  late JsonStore users;
  late JsonStore categories;
  late JsonStore products;
  late JsonStore addresses;
  late JsonStore orders;
  late JsonStore favorites;
  late JsonStore cart;
  late JsonStore settings;
  late JsonStore remoteCache;

  Future<JsonStore> _open(String name) async {
    final box = await Hive.openBox<String>(name);
    return JsonStore(box);
  }

  Future<void> init() async {
    try {
      await Hive.initFlutter('sat_db');
      users = await _open('users');
      categories = await _open('categories');
      products = await _open('products');
      addresses = await _open('addresses');
      orders = await _open('orders');
      favorites = await _open('favorites');
      cart = await _open('cart');
      settings = await _open('settings');
      remoteCache = await _open('remote_cache');
      await DatabaseSeeder(this).run();
    } on DatabaseException {
      rethrow;
    } catch (error) {
      throw DatabaseException('Деректер қорын ашу мүмкін болмады: $error');
    }
  }
}
