import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';
import 'api_exceptions.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    String baseUrl = AppConfig.apiBaseUrl,
    Duration timeout = AppConfig.apiTimeout,
    Map<String, String> headers = const {},
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl,
        _timeout = timeout,
        _headers = {..._jsonHeaders, ...headers};

  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;
  final Map<String, String> _headers;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send(() => _client.get(_uri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send(
      () => _client.post(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) {
    return _send(
      () => _client.put(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) {
    return _send(
      () => _client.patch(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> delete(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } catch (_) {
      throw const NoInternetException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(response.statusCode, _detail(response));
    }
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ParseException();
    }
  }

  String? _detail(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void close() => _client.close();
}
