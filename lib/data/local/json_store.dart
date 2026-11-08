import 'dart:convert';

import 'package:hive/hive.dart';

import 'database_exception.dart';

class JsonStore {
  JsonStore(this._box);

  final Box<String> _box;

  int get length => _box.length;

  bool get isEmpty => _box.isEmpty;

  List<String> get keys => _box.keys.map((key) => key.toString()).toList();

  static Map<String, dynamic>? _decode(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, dynamic>? get(String key) {
    final raw = _box.get(key);
    if (raw == null) {
      return null;
    }
    return _decode(raw);
  }

  List<Map<String, dynamic>> all() {
    final result = <Map<String, dynamic>>[];
    for (final raw in _box.values) {
      final decoded = _decode(raw);
      if (decoded != null) {
        result.add(decoded);
      }
    }
    return result;
  }

  Future<void> put(String key, Map<String, dynamic> value) async {
    try {
      await _box.put(key, jsonEncode(value));
    } catch (_) {
      throw const DatabaseException('Деректерді сақтау мүмкін болмады. Қайталап көріңіз.');
    }
  }

  Future<void> putAll(Map<String, Map<String, dynamic>> values) async {
    try {
      await _box.putAll(values.map((key, value) => MapEntry(key, jsonEncode(value))));
    } catch (_) {
      throw const DatabaseException('Деректерді сақтау мүмкін болмады. Қайталап көріңіз.');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (_) {
      throw const DatabaseException('Деректерді жою мүмкін болмады. Қайталап көріңіз.');
    }
  }

  Future<void> deleteAll(Iterable<String> keys) async {
    try {
      await _box.deleteAll(keys);
    } catch (_) {
      throw const DatabaseException('Деректерді жою мүмкін болмады. Қайталап көріңіз.');
    }
  }
}
