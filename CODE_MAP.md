# Карта кода: что где находится

Каждый блок: пункт задания, файл, номер строки и сам код. Откройте файл и перейдите на указанную строку (в VS Code: Ctrl+G).

Общая схема: `экран (features/)` → `AppState (data/state)` → `репозиторий (data/repositories)` → `Hive (data/local)`; сеть: `экран` → `контроллер` → `ProductApi` → `ApiClient`.

---

# Практикалық жұмыс №6 — Auth, Provider, геолокация

### 1. Registration формасы
`lib/features/auth/screens/register_screen.dart` — строка 45

```dart
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    final state = context.read<AppState>();
    final result = await state.auth.register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final user = result.user;
    if (user == null) {
      setState(() => _error = result.error);
      return;
    }
    await state.startSession(user);
```

### 2. Міндетті өрістер validation
`lib/core/utils/validators.dart` — строка 35

```dart
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Құпиясөзді енгізіңіз';
    }
    if (value.length < 8) {
      return 'Құпиясөз кемінде 8 таңбадан тұруы керек';
    }
    if (!_letter.hasMatch(value) || !_digit.hasMatch(value)) {
      return 'Латын әріптері мен кемінде бір санды қолданыңыз';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
```

### 3. Login функциясы
`lib/features/auth/screens/login_screen.dart` — строка 60

```dart
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    final state = context.read<AppState>();
    final result = await state.auth.login(_email.text.trim(), _password.text);
    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
    final user = result.user;
    if (user == null) {
      setState(() => _error = result.error);
      return;
    }
    await state.startSession(user);
    if (!mounted) {
      return;
    }
    _openMain();
  }

  Future<void> _loginWithPhone() async {
    final phone = await showAppSheet<String>(
      context,
```

### 4. Қате логин/пароль хабарламасы
`lib/data/services/auth_service.dart` — строка 22

```dart
  Future<AuthResult> login(String email, String password) async {
    try {
      final user = _users.byEmail(email);
      if (user == null || !_users.verify(user.id, password)) {
        return const AuthResult.failure('Электрондық пошта немесе құпиясөз қате');
      }
      return AuthResult.success(user);
    } catch (_) {
      return const AuthResult.failure(_dbError);
    }
  }
```

### 5. Сессияны сақтау
`lib/data/state/app_state.dart` — строка 116

```dart
  Future<void> startSession(UserProfile profile) async {
    await _guard(() => _settingsRepo.setSessionUserId(profile.id));
    _user = profile;
    _tab = 0;
    _promoCode = null;
    _loadUserData();
    notifyListeners();
  }
```

### 6. Қайта іске қосқанда сессияны тексеру
`lib/data/state/app_state.dart` — строка 25

```dart
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
```

### 6. Splash: сессия болса негізгі экранға
`lib/features/splash/screens/splash_screen.dart` — строка 33

```dart
  void _next() {
    if (!mounted) {
      return;
    }
    final loggedIn = context.read<AppState>().isLoggedIn;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRoutes.main : AppRoutes.onboarding,
    );
```

### 7. Logout (күйді тазалау)
`lib/data/state/app_state.dart` — строка 125

```dart
  Future<void> endSession() async {
    await _guard(() => _settingsRepo.setSessionUserId(null));
    _user = null;
    _tab = 0;
    _promoCode = null;
    _loadUserData();
    notifyListeners();
  }
```

### 7. Logout (растау диалогы)
`lib/features/profile/screens/profile_screen.dart` — строка 17

```dart
  Future<void> _logout(BuildContext context) async {
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Аккаунттан шығу'),
        content: const Text('Шынымен аккаунттан шыққыңыз келе ме?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Бас тарту'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Шығу', style: AppText.link.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await state.endSession();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _openSupport(BuildContext context) {
```

### 8. Profile — локалды деректермен байланыс
`lib/features/profile/screens/profile_screen.dart` — строка 99

```dart
              Expanded(child: _StatTile(label: 'Тапсырыс', value: state.orders.length)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Таңдаулы', value: state.favoritesCount)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Мекенжай', value: state.addresses.length)),
            ],
```

### 9–10. State Management: Provider (түбір)
`lib/app.dart` — строка 53

```dart
    return ChangeNotifierProvider<AppState>.value(
      value: _state,
      child: MaterialApp(
        title: 'SÄT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scaffoldMessengerKey: _messengerKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _router.onGenerateRoute,
        builder: (context, child) => ResponsiveFrame(child: child ?? const SizedBox.shrink()),
      ),
    );
```

### 9–10. Provider: watch / read / select
`lib/features/main/screens/main_shell.dart` — строка 25

```dart
    final tab = context.select<AppState, int>((state) => state.currentTab);
    final cartCount = context.select<AppState, int>((state) => state.cartCount);
    final state = context.read<AppState>();
    return PopScope(
      canPop: tab == 0,
```

### 9–10. Provider кітапханасы
`pubspec.yaml` — строка 18

```yaml
  provider: ^6.1.2
  geolocator: ^13.0.2
```

### 11–12. Геолокация кітапханасы
`pubspec.yaml` — строка 19

```yaml
  geolocator: ^13.0.2
```

### 13. Permission сұрау (геолокация)
`lib/data/location/location_service.dart` — строка 74

```dart
  Future<LocationResult> detect() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationResult.failure(LocationFailure.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(LocationFailure.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(LocationFailure.deniedForever);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final location = await _reverse(position.latitude, position.longitude);
      return LocationResult.success(location);
    } on TimeoutException {
      return const LocationResult.failure(LocationFailure.timeout);
    } catch (_) {
      return const LocationResult.failure(LocationFailure.unavailable);
    }
  }

  Future<DetectedLocation> _reverse(double latitude, double longitude) async {
    try {
      final json = await _geocoder.get(
        '/reverse',
        query: {
```

### 14. Бизнес-логикамен байланыс: мекенжайды GPS арқылы толтыру
`lib/features/addresses/screens/address_form_screen.dart` — строка 91

```dart
  Future<void> _detectLocation() async {
    FocusScope.of(context).unfocus();
    setState(() => _locating = true);
    final result = await _location.detect();
    if (!mounted) {
      return;
    }
    setState(() => _locating = false);
    final found = result.location;
    if (found == null) {
      await showLocationFailure(
        context,
        result.failure ?? LocationFailure.unavailable,
        service: _location,
        onRetry: _detectLocation,
      );
      return;
    }
    setState(() {
      _latitude = found.latitude;
      _longitude = found.longitude;
      if (found.city.isNotEmpty) {
        _city.text = found.city;
      }
      if (found.street.isNotEmpty) {
        _street.text = found.street;
      }
      if (found.postalCode.isNotEmpty) {
        _postal.text = found.postalCode;
      }
      _zoneWarning = found.city.isNotEmpty && !AppConfig.cities.contains(found.city)
          ? '«${found.city}» қаласына жеткізу әзірге қолжетімсіз. Қолжетімді қалалар: ${AppConfig.cities.join(', ')}.'
          : null;
    });
    showAppSnack(
      context,
      found.hasAddress
          ? 'Орын анықталды: ${found.city}'
          : 'Координаттар анықталды. Мекенжайды қолмен толтырыңыз.',
    );
  }

  Future<void> _delete() async {
    final ok = await confirmDeleteAddress(context);
    if (!mounted || !ok) {
      return;
    }
    final deleted = await context.read<AppState>().deleteAddress(widget.address!.id);
```

### 14. Бизнес-логика: жеткізу қаласын анықтау
`lib/features/home/screens/home_screen.dart` — строка 31

```dart
  Future<void> _detectCity(BuildContext context) async {
    final state = context.read<AppState>();
    final service = LocationService();
    final result = await service.detect();
    if (!context.mounted) {
      return;
    }
    final found = result.location;
    if (found == null) {
      await showLocationFailure(
        context,
        result.failure ?? LocationFailure.unavailable,
        service: service,
        onRetry: () => _detectCity(context),
      );
      return;
    }
    if (found.city.isEmpty) {
      showAppSnack(context, 'Қала анықталмады. Тізімнен таңдаңыз.', isError: true);
      return;
    }
    if (!AppConfig.cities.contains(found.city)) {
      showAppSnack(context, '«${found.city}» қаласына жеткізу әзірге жоқ.', isError: true);
      return;
    }
    await state.setCity(found.city);
    if (!context.mounted) {
      return;
    }
    showAppSnack(context, 'Жеткізу қаласы: ${found.city}');
  }

  Future<void> _pickCity(BuildContext context) async {
    final state = context.read<AppState>();
```

### 15. Permission берілген/берілмеген жағдайлар
`lib/features/location/location_dialogs.dart` — строка 6

```dart
Future<void> showLocationFailure(
  BuildContext context,
  LocationFailure failure, {
  required LocationService service,
  required VoidCallback onRetry,
}) {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback action;
  switch (failure) {
    case LocationFailure.serviceDisabled:
      title = 'Орынды анықтау өшірулі';
      message = 'Құрылғыда геолокацияны қосыңыз да, қайталап көріңіз.';
      actionLabel = 'Орынды қосу';
      action = () => service.openLocationSettings();
    case LocationFailure.denied:
      title = 'Рұқсат берілмеді';
      message = 'Мекенжайды автоматты анықтау үшін орынға рұқсат қажет. Қолмен де толтыруға болады.';
      actionLabel = 'Қайта сұрау';
      action = onRetry;
    case LocationFailure.deniedForever:
      title = 'Рұқсат бұғатталған';
      message = 'Орынға рұқсат толық өшірілген. Оны қосымша баптауларынан қосыңыз.';
      actionLabel = 'Баптауларды ашу';
      action = () => service.openAppSettings();
    case LocationFailure.timeout:
      title = 'Орын анықталмады';
      message = 'Құрылғы орынды уақытында анықтай алмады. Ашық жерде қайталап көріңіз.';
      actionLabel = 'Қайталау';
      action = onRetry;
    case LocationFailure.unavailable:
      title = 'Орынды анықтау мүмкін болмады';
      message = 'Бұл құрылғыда геолокация қолжетімсіз. Мекенжайды қолмен енгізіңіз.';
      actionLabel = 'Қайталау';
      action = onRetry;
  }
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
```

### 16. Экрандарға қолжетімділік (route guard)
`lib/core/routes/app_router.dart` — строка 34

```dart
  static const Set<String> publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
  };

  static bool isProtected(String? name) => !publicRoutes.contains(name);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    if (isProtected(settings.name) && !_state.isLoggedIn) {
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: AppRoutes.login),
        builder: (context) => LoginScreen(
          notice: 'Бұл бөлімді көру үшін жүйеге кіріңіз.',
          redirectTo: settings.name,
          redirectArguments: args,
        ),
      );
    }
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.onboarding => const OnboardingScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.main => const MainShell(),
      AppRoutes.catalog => CatalogScreen(initialCategory: args is Category ? args : null),
```

### 16. Guard: login-ге бағыттау және оралу
`lib/features/auth/screens/login_screen.dart` — строка 51

```dart
  void _openMain() {
    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    final target = widget.redirectTo;
    if (target != null && target != AppRoutes.main) {
      navigator.pushNamed(target, arguments: widget.redirectArguments);
    }
  }
```

### 13. Android permission
`android/app/src/main/AndroidManifest.xml` — строка 3

```dart
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

### 13. iOS permission
`ios/Runner/Info.plist` — строка 69

```dart
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Жеткізу мекенжайын автоматты анықтау үшін орынға рұқсат қажет.</string>
```

### 16–17. Guard тесттері
`test/auth_guard_test.dart` — строка 14

```dart
  test('all other routes require authorization', () {
    for (final route in [
      AppRoutes.main,
      AppRoutes.orders,
      AppRoutes.addresses,
      AppRoutes.addressForm,
      AppRoutes.settings,
      AppRoutes.checkout,
      AppRoutes.remoteCatalog,
      AppRoutes.manageProducts,
    ]) {
      expect(AppRouter.isProtected(route), isTrue, reason: route);
    }
  });

  test('password confirmation validator', () {
```

---

# Практикалық жұмыс №5 — REST API

### 1. REST API таңдау
`lib/core/constants/app_config.dart` — строка 4

```dart
  static const String apiBaseUrl = 'https://dummyjson.com';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const int usdToKzt = 480;
  static const int remotePageSize = 20;
  static const int deliveryFee = 1500;
```

### 2–3. Endpoint тізімі және HTTP әдістері
`lib/data/remote/product_api.dart` — строка 5

```dart
class ApiEndpoints {
  const ApiEndpoints._();

  static const String products = '/products';
  static const String search = '/products/search';
  static const String add = '/products/add';

  static String byId(int id) => '/products/$id';
}
```

### 3. GET/POST/PUT/PATCH/DELETE әдістері (клиент)
`lib/data/remote/api_client.dart` — строка 34

```dart
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
```

### 4. HTTP кітапханасы
`pubspec.yaml` — строка 17

```yaml
  http: ^1.2.0
```

### 5. GET сұрауы
`lib/data/remote/product_api.dart` — строка 51

```dart
  Future<RemotePage> fetchProducts({required int limit, required int skip}) async {
    final json = await _client.get(
      ApiEndpoints.products,
      query: {'limit': '$limit', 'skip': '$skip'},
    );
    return _asPage(json);
  }
```

### 6. JSON → Dart Model
`lib/data/remote/models/remote_product.dart` — строка 82

```dart
  factory RemoteProduct.fromJson(Map<String, dynamic> json) {
    final reviews = json['reviews'];
    return RemoteProduct(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String?,
      thumbnail: (json['thumbnail'] as String?) ?? '',
      images: ((json['images'] as List?) ?? const []).map((item) => item.toString()).toList(),
      tags: ((json['tags'] as List?) ?? const []).map((item) => item.toString()).toList(),
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? (reviews is List ? reviews.length : 0),
    );
  }
}

class RemoteProductDraft {
```

### 7. Интерфейсте көрсету (карточка)
`lib/features/remote/screens/remote_catalog_screen.dart` — строка 340

```dart
class _RemoteProductCard extends StatelessWidget {
  const _RemoteProductCard({
    required this.item,
    required this.linked,
    required this.enabled,
    required this.onLink,
    required this.onEdit,
    required this.onDelete,
  });

  final RemoteProduct item;
  final bool linked;
  final bool enabled;
  final VoidCallback onLink;
```

### 8. POST сұрауы
`lib/data/remote/product_api.dart` — строка 72

```dart
  Future<RemoteProduct> createProduct(RemoteProductDraft draft) async {
    final json = await _client.post(ApiEndpoints.add, draft.toJson());
    return _asProduct(json);
  }
```

### 8. POST — контроллерде
`lib/features/remote/state/remote_catalog_controller.dart` — строка 144

```dart
  Future<ActionResult> create(RemoteProductDraft draft) {
    return _run(() async {
      final created = await api.createProduct(draft);
      final item = created.copyWith(
        id: _nextSimulatedId++,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        price: draft.price,
        stock: created.stock > 0 ? created.stock : 10,
        isSimulated: true,
      );
      _items = [item, ..._items];
      _total += 1;
      return ActionResult.ok('POST орындалды: тауар серверге жіберілді (id ${created.id})', item);
    });
  }
```

### 9. PATCH сұрауы
`lib/data/remote/product_api.dart` — строка 77

```dart
  Future<RemoteProduct> updateProduct(int id, RemoteProductDraft draft) async {
    final json = await _client.patch(ApiEndpoints.byId(id), draft.toJson());
    return _asProduct(json);
  }
```

### 9. PATCH — контроллерде
`lib/features/remote/state/remote_catalog_controller.dart` — строка 162

```dart
  Future<ActionResult> update(RemoteProduct item, RemoteProductDraft draft) {
    return _run(() async {
      final String message;
      if (item.isSimulated) {
        message = 'Демо-сервер жаңа жазбаны сақтамайды: өзгеріс қосымшада жаңартылды';
      } else {
        await api.updateProduct(item.id, draft);
        message = 'PATCH орындалды: тауар серверде өзгертілді';
      }
      final updated = item.copyWith(
        title: draft.title,
        description: draft.description,
        category: draft.category,
        price: draft.price,
      );
      _items = _items.map((entry) => entry.id == item.id ? updated : entry).toList();
      return ActionResult.ok(message, updated);
    });
  }

  Future<ActionResult> remove(RemoteProduct item) {
    return _run(() async {
```

### 9. PUT сұрауы (қосымша)
`lib/data/remote/product_api.dart` — строка 82

```dart
  Future<RemoteProduct> replaceProduct(int id, RemoteProductDraft draft) async {
    final json = await _client.put(ApiEndpoints.byId(id), draft.toJson());
    return _asProduct(json);
  }
```

### 10. DELETE сұрауы
`lib/data/remote/product_api.dart` — строка 87

```dart
  Future<void> deleteProduct(int id) async {
    await _client.delete(ApiEndpoints.byId(id));
  }
```

### 10. DELETE — контроллерде
`lib/features/remote/state/remote_catalog_controller.dart` — строка 182

```dart
  Future<ActionResult> remove(RemoteProduct item) {
    return _run(() async {
      final String message;
      if (item.isSimulated) {
        message = 'Демо-сервер жаңа жазбаны сақтамайды: тауар тізімнен өшірілді';
      } else {
        await api.deleteProduct(item.id);
        message = 'DELETE орындалды: тауар серверден өшірілді';
        _total = _total > 0 ? _total - 1 : 0;
        _serverCount = _serverCount > 0 ? _serverCount - 1 : 0;
      }
      _items = _items.where((entry) => entry.id != item.id).toList();
      return ActionResult.ok(message, item);
    });
  }

  Future<ActionResult> testTimeout() {
    return _run(() async {
```

### 11. async/await — жүктеу
`lib/features/remote/state/remote_catalog_controller.dart` — строка 70

```dart
  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    _notify();
    try {
      final page = await _request(0);
      _items = page.items;
      _total = page.total;
      _serverCount = page.items.length;
      _fromCache = false;
      _status = LoadStatus.success;
      if (_query.isEmpty) {
        try {
          await cache.write(page.items);
        } catch (_) {
          _fromCache = false;
        }
      }
    } on ApiException catch (error) {
      _error = error;
      final cached = _query.isEmpty ? cache.read() : null;
      if (cached != null && cached.isNotEmpty) {
        _items = cached;
        _total = cached.length;
        _serverCount = cached.length;
        _fromCache = true;
        _status = LoadStatus.success;
      } else {
        _items = [];
        _status = LoadStatus.error;
      }
    }
    _notify();
  }

  Future<void> loadMore() async {
    if (!hasMore || _loadingMore) {
      return;
    }
    _loadingMore = true;
```

### 12. Loading күйі (экран)
`lib/features/remote/screens/remote_catalog_screen.dart` — строка 210

```dart
                const LinearProgressIndicator(minHeight: 3)
              else
                const SizedBox(height: 3),
              Expanded(
```

### 13. Success күйі
`lib/features/remote/state/remote_catalog_controller.dart` — строка 11

```dart
class ActionResult {
  const ActionResult.ok(this.message, [this.product]) : ok = true;

  const ActionResult.fail(this.message)
      : ok = false,
        product = null;

  final bool ok;
  final String message;
  final RemoteProduct? product;
}
```

### 14. Error — сервер қатесі
`lib/data/remote/api_exceptions.dart` — строка 24

```dart
class ServerException extends ApiException {
  ServerException(this.statusCode, [String? detail])
      : super(_describe(statusCode, detail));

  final int statusCode;

  static String _describe(int code, String? detail) {
    final extra = (detail == null || detail.isEmpty) ? '' : ' $detail';
    if (code == 404) {
      return 'Деректер серверден табылмады (404).$extra';
    }
    if (code == 400 || code == 422) {
      return 'Сұрау дұрыс емес ($code).$extra';
    }
    if (code == 401 || code == 403) {
      return 'Қолжетімділік жоқ ($code).$extra';
    }
    if (code >= 500) {
      return 'Сервер қатесі ($code). Кейінірек қайталап көріңіз.';
    }
    return 'Сервер қатесі ($code).$extra';
  }
```

### 14. Error күйін экранда көрсету
`lib/features/remote/screens/remote_catalog_screen.dart` — строка 279

```dart
                      else if (controller.status == LoadStatus.error)
                        EmptyState(
                          icon: _errorIcon(controller.error),
                          title: 'Деректерді жүктеу мүмкін болмады',
                          message: controller.error?.message ?? 'Қате орын алды.',
                          actionLabel: 'Қайталау',
                          onAction: controller.load,
                        )
```

### 15. Интернет жоқ
`lib/data/remote/api_client.dart` — строка 60

```dart
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
```

### 16. Timeout
`lib/data/remote/api_client.dart` — строка 63

```dart
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } catch (_) {
      throw const NoInternetException();
```

### 17. Exception өңдеу (контроллер)
`lib/features/remote/state/remote_catalog_controller.dart` — строка 128

```dart
  Future<ActionResult> _run(Future<ActionResult> Function() action) async {
    _busy = true;
    _notify();
    ActionResult result;
    try {
      result = await action();
    } on ApiException catch (error) {
      result = ActionResult.fail(error.message);
    } catch (_) {
      result = const ActionResult.fail('Күтпеген қате орын алды. Қайталап көріңіз.');
    }
    _busy = false;
    _notify();
    return result;
  }
```

### 18. Серверді локалды деректермен байланыстыру (Hive-қа сақтау)
`lib/data/state/app_state.dart` — строка 264

```dart
  Future<bool> importRemoteProduct(RemoteProduct remote) async {
    final categoryId = await _ensureCategory(remote.category);
    if (categoryId == null) {
      return false;
    }
    final existing = products.byId(RemoteProductMapper.localId(remote.id));
    final product = RemoteProductMapper.toLocal(remote, categoryId, existing: existing);
    return saveProduct(product);
  }
```

### 18. Mapper: сервер моделі → локалды Product
`lib/data/remote/remote_product_mapper.dart` — строка 44

```dart
  static Product toLocal(RemoteProduct remote, String categoryId, {Product? existing}) {
    final title = categoryTitle(remote.category);
    final brand = remote.brand;
    final subtitle = (brand == null || brand.isEmpty) ? title : '$brand · $title';
    final images = remote.images.isNotEmpty
        ? remote.images
        : (remote.thumbnail.isEmpty ? <String>[] : [remote.thumbnail]);
    final words = remote.title
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1);
    return Product(
      id: localId(remote.id),
      name: remote.title,
      subtitle: subtitle,
      tagline: subtitle,
      price: toKzt(remote.price),
      images: images,
      categoryId: categoryId,
      colors: existing?.colors ?? const [ProductColor.fallback],
      description: remote.description,
      specs: [
        ProductSpec('Санат', title),
        ProductSpec('Қоймада', '${remote.stock} дана'),
      ],
      cartInfo: '',
      deliveryTime: '1–3 жұмыс күні',
      rating: remote.rating,
      reviews: remote.reviewCount,
      popularity: (remote.rating * 20).round(),
      keywords: [...remote.tags.map((tag) => tag.toLowerCase()), ...words],
      createdAt: existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      isNew: false,
      inStock: remote.stock > 0,
      remoteId: remote.id,
    );
```

### 18. Интернет жоқта кэш
`lib/data/repositories/remote_cache_repository.dart` — строка 4

```dart
class RemoteCacheRepository {
  RemoteCacheRepository(this._store);

  static const String _key = 'products';

  final JsonStore _store;

  List<RemoteProduct>? read() {
    final json = _store.get(_key);
    if (json == null) {
      return null;
    }
    try {
      return (json['items'] as List)
          .map((item) => RemoteProduct.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<RemoteProduct> items) {
    return _store.put(_key, {
      'savedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    });
  }
}
```

### 19–20. Тесттер (GET/POST/PATCH/PUT/DELETE, қателер)
`test/api_client_test.dart` — строка 29

```dart
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
```

---

# Практикалық жұмыс №4 — локалды БД (Hive)

### 3. Модель: өрістер, типтер, id
`lib/data/models/product.dart` — строка 34

```dart
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tagline,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.colors,
    required this.description,
    required this.specs,
    required this.cartInfo,
    required this.deliveryTime,
    required this.rating,
    required this.reviews,
    required this.popularity,
    required this.keywords,
    required this.createdAt,
    this.isNew = false,
    this.inStock = true,
    this.remoteId,
  });

  final String id;
  final String name;
  final String subtitle;
  final String tagline;
  final int price;
  final List<String> images;
```

### 4. Байланыс: Product → Category
`lib/data/models/product.dart` — строка 64

```dart
  final String categoryId;
```

### 5–6. Hive кітапханасы
`pubspec.yaml` — строка 14

```yaml
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  crypto: ^3.0.3
```

### 7. Деректер қорын инициализациялау
`lib/data/local/app_database.dart` — строка 23

```dart
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
```

### 8,10,11. Create/Update/Delete (Repository)
`lib/data/repositories/product_repository.dart` — строка 49

```dart
  Future<void> save(Product product) => _store.put(product.id, product.toJson());

  Future<void> delete(String id) => _store.delete(id);
```

### 9. Read (Repository)
`lib/data/repositories/product_repository.dart` — строка 25

```dart
  List<Product> all() {
    final list = <Product>[];
    for (final json in _store.all()) {
      try {
        list.add(Product.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    return list;
  }
```

### 12. Repository қабаты: JSON сақтау
`lib/data/local/json_store.dart` — строка 49

```dart
  Future<void> put(String key, Map<String, dynamic> value) async {
    try {
      await _box.put(key, jsonEncode(value));
    } catch (_) {
      throw const DatabaseException('Деректерді сақтау мүмкін болмады. Қайталап көріңіз.');
    }
  }
```

### 13–15. Іздеу, сүзгі, сұрыптау (5 параметр)
`lib/data/repositories/product_repository.dart` — строка 69

```dart
  List<Product> filter({
    String? categoryId,
    String query = '',
    int minPrice = 0,
    int maxPrice = 100000000,
    bool onlyInStock = false,
    ProductSort sort = ProductSort.popular,
  }) {
    final q = query.trim().toLowerCase();
    final list = all().where((product) {
      final categoryOk = categoryId == null || product.categoryId == categoryId;
      final priceOk = product.price >= minPrice && product.price <= maxPrice;
      final stockOk = !onlyInStock || product.inStock;
      final queryOk = q.isEmpty || product.matches(q);
      return categoryOk && priceOk && stockOk && queryOk;
    }).toList();
    switch (sort) {
      case ProductSort.popular:
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
      case ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case ProductSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<Product> search(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return const [];
    }
```

### 15. Сұрыптау түрлері
`lib/data/repositories/product_repository.dart` — строка 4

```dart
enum ProductSort {
  popular('Танымалдары'),
  priceAsc('Бағасы: өсу бойынша'),
  priceDesc('Бағасы: кему бойынша'),
  nameAsc('Атауы: А–Я'),
  newest('Жаңалары алдымен');

  const ProductSort(this.label);

  final String label;
}
```

### 16. Favorites (БД-ға жазу)
`lib/data/state/app_state.dart` — строка 296

```dart
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
```

### 8. Create — форма (UI)
`lib/features/product/screens/product_form_screen.dart` — строка 71

```dart
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final state = context.read<AppState>();
    final categoryId = _categoryId;
    if (categoryId == null) {
      showAppSnack(context, 'Санатты таңдаңыз', isError: true);
      return;
    }
    final image = _image.text.trim();
    final existing = widget.product;
    final Product product;
    if (existing == null) {
      product = Product(
        id: state.products.newId(),
        name: _name.text.trim(),
        subtitle: _subtitle.text.trim(),
        tagline: _subtitle.text.trim(),
        price: int.parse(_price.text.trim()),
        images: image.isEmpty ? const [] : [image],
        categoryId: categoryId,
        colors: const [ProductColor.fallback],
        description: _description.text.trim(),
        specs: const [],
        cartInfo: '',
        deliveryTime: '1–3 жұмыс күні',
        rating: 0,
        reviews: 0,
        popularity: 50,
        keywords: _keywords(_name.text),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isNew: _isNew,
        inStock: _inStock,
      );
    } else {
      product = existing.copyWith(
        name: _name.text.trim(),
        subtitle: _subtitle.text.trim(),
        tagline: _subtitle.text.trim(),
        price: int.parse(_price.text.trim()),
        images: image.isEmpty ? const [] : [image],
        categoryId: categoryId,
        description: _description.text.trim(),
        keywords: _keywords(_name.text),
        isNew: _isNew,
        inStock: _inStock,
      );
    }
    setState(() => _saving = true);
    final ok = await state.saveProduct(product);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (!ok) {
      return;
```

### 17. Бос күй хабарламасы
`lib/features/catalog/screens/catalog_screen.dart` — строка 162

```dart
          if (state.products.count == 0)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Каталог бос',
                message: 'Әзірге бірде-бір тауар қосылмаған.',
                actionLabel: 'Тауар қосу',
                onAction: () => Navigator.of(context).pushNamed(AppRoutes.productForm),
              ),
            )
          else if (products.isEmpty)
```

### 18. Қателерді өңдеу (_guard)
`lib/data/state/app_state.dart` — строка 86

```dart
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
```

### 18. Қате хабарламасы SnackBar (app.dart)
`lib/app.dart` — строка 32

```dart
  void _onStateChanged() {
    final message = _state.takeError();
    if (message == null) {
      return;
    }
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
```

### 20. Сессияны қалпына келтіру (қайта іске қосқанда)
`lib/data/state/app_state.dart` — строка 25

```dart
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
```

### 20. Алғашқы деректерді толтыру (seed)
`lib/data/local/database_seeder.dart` — строка 20

```dart
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
```

---

# Жаңа файлдар (қанша жол)

| Файл | Жол |
|---|---|
| `lib/data/remote/api_client.dart` | 95 |
| `lib/data/remote/api_exceptions.dart` | 46 |
| `lib/data/remote/product_api.dart` | 98 |
| `lib/data/remote/remote_product_mapper.dart` | 81 |
| `lib/data/remote/models/remote_product.dart` | 129 |
| `lib/data/repositories/remote_cache_repository.dart` | 31 |
| `lib/features/remote/state/remote_catalog_controller.dart` | 211 |
| `lib/features/remote/screens/remote_catalog_screen.dart` | 436 |
| `lib/features/remote/screens/remote_product_form_sheet.dart` | 163 |
| `lib/data/local/app_database.dart` | 42 |
| `lib/data/local/json_store.dart` | 80 |
| `lib/data/local/database_seeder.dart` | 59 |
| `lib/data/local/seed_data.dart` | 186 |
| `lib/data/repositories/product_repository.dart` | 112 |
| `lib/data/repositories/user_repository.dart` | 89 |
| `lib/data/repositories/address_repository.dart` | 42 |
| `lib/data/repositories/order_repository.dart` | 28 |
| `lib/data/repositories/favorite_repository.dart` | 34 |
| `lib/data/repositories/cart_repository.dart` | 64 |
| `lib/data/repositories/category_repository.dart` | 23 |
| `lib/data/repositories/settings_repository.dart` | 38 |
| `lib/features/product/screens/manage_products_screen.dart` | 288 |
| `lib/features/product/screens/product_form_screen.dart` | 278 |
| `lib/features/splash/screens/database_error_screen.dart` | 30 |
