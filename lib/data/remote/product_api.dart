import 'api_client.dart';
import 'api_exceptions.dart';
import 'models/remote_product.dart';

class ApiEndpoints {
  const ApiEndpoints._();

  static const String products = '/products';
  static const String search = '/products/search';
  static const String add = '/products/add';

  static String byId(int id) => '/products/$id';
}

class ProductApi {
  ProductApi(this._client);

  final ApiClient _client;

  Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map) {
      return Map<String, dynamic>.from(json);
    }
    throw const ParseException();
  }

  RemotePage _asPage(dynamic json) {
    try {
      final map = _asMap(json);
      final list = (map['products'] as List)
          .map((item) => RemoteProduct.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      return RemotePage(items: list, total: (map['total'] as num?)?.toInt() ?? list.length);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  RemoteProduct _asProduct(dynamic json) {
    try {
      return RemoteProduct.fromJson(_asMap(json));
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<RemotePage> fetchProducts({required int limit, required int skip}) async {
    final json = await _client.get(
      ApiEndpoints.products,
      query: {'limit': '$limit', 'skip': '$skip'},
    );
    return _asPage(json);
  }

  Future<RemotePage> searchProducts(String query, {required int limit, required int skip}) async {
    final json = await _client.get(
      ApiEndpoints.search,
      query: {'q': query, 'limit': '$limit', 'skip': '$skip'},
    );
    return _asPage(json);
  }

  Future<RemoteProduct> getProduct(int id) async {
    final json = await _client.get(ApiEndpoints.byId(id));
    return _asProduct(json);
  }

  Future<RemoteProduct> createProduct(RemoteProductDraft draft) async {
    final json = await _client.post(ApiEndpoints.add, draft.toJson());
    return _asProduct(json);
  }

  Future<RemoteProduct> updateProduct(int id, RemoteProductDraft draft) async {
    final json = await _client.patch(ApiEndpoints.byId(id), draft.toJson());
    return _asProduct(json);
  }

  Future<RemoteProduct> replaceProduct(int id, RemoteProductDraft draft) async {
    final json = await _client.put(ApiEndpoints.byId(id), draft.toJson());
    return _asProduct(json);
  }

  Future<void> deleteProduct(int id) async {
    await _client.delete(ApiEndpoints.byId(id));
  }

  Future<void> slowRequest() async {
    await _client.get(ApiEndpoints.products, query: {'limit': '1', 'delay': '15000'});
  }

  Future<void> missingRequest() async {
    await _client.get(ApiEndpoints.byId(999999));
  }
}
