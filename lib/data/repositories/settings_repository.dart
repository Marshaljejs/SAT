import '../../core/constants/app_config.dart';
import '../local/json_store.dart';

class SettingsRepository {
  SettingsRepository(this._store);

  static const String _key = 'app';

  final JsonStore _store;

  Map<String, dynamic> _read() => _store.get(_key) ?? <String, dynamic>{};

  Future<void> _set(String name, Object? value) {
    final data = Map<String, dynamic>.from(_read());
    if (value == null) {
      data.remove(name);
    } else {
      data[name] = value;
    }
    return _store.put(_key, data);
  }

  String? get sessionUserId => _read()['sessionUserId'] as String?;
  String get city => (_read()['city'] as String?) ?? AppConfig.cities.first;
  bool get notifyOrders => (_read()['notifyOrders'] as bool?) ?? true;
  bool get notifyCollections => (_read()['notifyCollections'] as bool?) ?? true;
  bool get notifyOffers => (_read()['notifyOffers'] as bool?) ?? false;
  int get orderSequence => (_read()['orderSequence'] as num?)?.toInt() ?? 1025;
  bool get isSeeded => (_read()['seeded'] as bool?) ?? false;

  Future<void> setSessionUserId(String? id) => _set('sessionUserId', id);
  Future<void> setCity(String value) => _set('city', value);
  Future<void> setNotifyOrders(bool value) => _set('notifyOrders', value);
  Future<void> setNotifyCollections(bool value) => _set('notifyCollections', value);
  Future<void> setNotifyOffers(bool value) => _set('notifyOffers', value);
  Future<void> setOrderSequence(int value) => _set('orderSequence', value);
  Future<void> markSeeded() => _set('seeded', true);
}
