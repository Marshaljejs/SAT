import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/utils/formatters.dart';
import '../local/json_store.dart';
import '../models/user_profile.dart';

class UserRepository {
  UserRepository(this._store);

  final JsonStore _store;

  static String _hash(String id, String password) {
    return sha256.convert(utf8.encode('sat|$id|$password')).toString();
  }

  UserProfile _toProfile(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] as String?) ?? '',
    );
  }

  UserProfile? byId(String id) {
    final json = _store.get(id);
    return json == null ? null : _toProfile(json);
  }

  UserProfile? byEmail(String email) {
    final key = email.trim().toLowerCase();
    for (final json in _store.all()) {
      if ((json['email'] as String).toLowerCase() == key) {
        return _toProfile(json);
      }
    }
    return null;
  }

  UserProfile? byPhone(String phone) {
    final digits = Formatters.localPhoneDigits(phone);
    for (final json in _store.all()) {
      if (Formatters.localPhoneDigits((json['phone'] as String?) ?? '') == digits) {
        return _toProfile(json);
      }
    }
    return null;
  }

  bool verify(String id, String password) {
    final json = _store.get(id);
    if (json == null) {
      return false;
    }
    return json['passwordHash'] == _hash(id, password);
  }

  Future<void> create(UserProfile profile, String password) {
    return _store.put(profile.id, {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'passwordHash': _hash(profile.id, password),
    });
  }

  Future<void> update(UserProfile profile) async {
    final json = _store.get(profile.id);
    if (json == null) {
      return;
    }
    json['name'] = profile.name;
    json['email'] = profile.email;
    json['phone'] = profile.phone;
    await _store.put(profile.id, json);
  }

  Future<void> setPassword(String id, String password) async {
    final json = _store.get(id);
    if (json == null) {
      return;
    }
    json['passwordHash'] = _hash(id, password);
    await _store.put(id, json);
  }
}
