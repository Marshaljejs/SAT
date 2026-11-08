import '../local/json_store.dart';
import '../models/address.dart';

class AddressRepository {
  AddressRepository(this._store);

  final JsonStore _store;

  List<Address> forUser(String userId) {
    final list = <Address>[];
    for (final json in _store.all()) {
      if (json['userId'] != userId) {
        continue;
      }
      try {
        list.add(Address.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      return a.id.compareTo(b.id);
    });
    return list;
  }

  Future<void> replaceAll(String userId, List<Address> addresses) async {
    final keep = addresses.map((address) => address.id).toSet();
    final stale = _store
        .all()
        .where((json) => json['userId'] == userId && !keep.contains(json['id']))
        .map((json) => json['id'] as String)
        .toList();
    await _store.deleteAll(stale);
    await _store.putAll({
      for (final address in addresses) address.id: {...address.toJson(), 'userId': userId},
    });
  }
}
