import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sat_store_app/data/remote/api_client.dart';
import 'package:sat_store_app/data/remote/api_exceptions.dart';
import 'package:sat_store_app/data/remote/models/remote_product.dart';
import 'package:sat_store_app/data/remote/product_api.dart';

ApiClient _client(Future<http.Response> Function(http.Request) handler, {Duration? timeout}) {
  return ApiClient(
    client: MockClient(handler),
    baseUrl: 'https://api.test',
    timeout: timeout ?? const Duration(seconds: 2),
  );
}

void main() {
  test('GET parses JSON on success', () async {
    final client = _client((request) async {
      expect(request.method, 'GET');
      return http.Response('{"value": 1}', 200);
    });
    final result = await client.get('/items');
    expect(result['value'], 1);
  });

  test('POST, PATCH, PUT and DELETE use the right HTTP methods', () async {
    final methods = <String>[];
    final client = _client((request) async {
      methods.add(request.method);
      return http.Response('{"ok": true}', 200);
    });
    await client.post('/items', {'a': 1});
    await client.patch('/items/1', {'a': 2});
    await client.put('/items/1', {'a': 3});
    await client.delete('/items/1');
    expect(methods, ['POST', 'PATCH', 'PUT', 'DELETE']);
  });

  test('server error becomes ServerException', () async {
    final client = _client((request) async => http.Response('{"message": "x"}', 500));
    expect(client.get('/items'), throwsA(isA<ServerException>()));
  });

  test('404 keeps status code', () async {
    final client = _client((request) async => http.Response('{}', 404));
    try {
      await client.get('/items/1');
      fail('must throw');
    } on ServerException catch (error) {
      expect(error.statusCode, 404);
    }
  });

  test('no connection becomes NoInternetException', () async {
    final client = _client((request) async => throw const SocketException('offline'));
    expect(client.get('/items'), throwsA(isA<NoInternetException>()));
  });

  test('slow response becomes RequestTimeoutException', () async {
    final client = _client(
      (request) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.Response('{}', 200);
      },
      timeout: const Duration(milliseconds: 50),
    );
    expect(client.get('/items'), throwsA(isA<RequestTimeoutException>()));
  });

  test('invalid JSON becomes ParseException', () async {
    final client = _client((request) async => http.Response('not json', 200));
    expect(client.get('/items'), throwsA(isA<ParseException>()));
  });

  test('ProductApi converts list response to models', () async {
    final api = ProductApi(
      _client((request) async {
        return http.Response(
          '{"products": [{"id": 1, "title": "Bag", "price": 10.5, "category": "womens-bags", "stock": 3, "images": ["a.png"], "reviews": [{}, {}]}], "total": 1}',
          200,
        );
      }),
    );
    final page = await api.fetchProducts(limit: 20, skip: 0);
    expect(page.total, 1);
    expect(page.items.first.title, 'Bag');
    expect(page.items.first.reviewCount, 2);
  });

  test('ProductApi sends draft on create', () async {
    String? body;
    final api = ProductApi(
      _client((request) async {
        body = request.body;
        expect(request.url.path, '/products/add');
        return http.Response('{"id": 195, "title": "New"}', 201);
      }),
    );
    final created = await api.createProduct(
      const RemoteProductDraft(title: 'New', description: '', category: 'furniture', price: 5),
    );
    expect(created.id, 195);
    expect(body, contains('"title":"New"'));
  });
}
