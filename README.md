# SÄT — мобильді интернет-дүкен (Flutter)

Figma прототипіне сәйкес әзірленген Flutter қосымшасы.

## Іске қосу

```
flutter pub get
flutter run
```

Demo аккаунт (кіру экранында алдын ала толтырылған):

- Email: `aidana@mail.kz`
- Құпиясөз: `Sat12345`
- Телефон: `+7 (701) 234 56 78`
- Промокод себетте: `SAT2026` (−10%)

## Құрылым (feature-based)

```
lib/
  main.dart, app.dart
  core/
    constants/   app_config, app_dimens
    theme/       app_colors, app_text, app_theme
    routes/      app_routes, app_router
    utils/       validators, formatters, responsive
    widgets/     reusable виджеттер
  data/
    models/      product, cart_item, address, order, user_profile
    services/    product_service, auth_service, demo_data
    state/       app_state, app_scope
  features/
    splash, onboarding, auth, main, home, catalog, product,
    cart, checkout, search, favorites, profile, orders,
    addresses, settings
```

## Навигация

`MaterialApp.onGenerateRoute` + `AppRoutes`. Төменгі навигация (`NavigationBar`) 5 бөлімді
`IndexedStack` арқылы ауыстырады: Басты бет, Іздеу, Таңдаулы, Себет, Профиль.

## Валидация

Email, бос құпиясөз, міндетті өрістер, телефон, пошта индексі, шарттармен келісу —
`core/utils/validators.dart`.

## Локалды деректер қоры (Hive)

Таңдалған технология: **Hive** (`hive`, `hive_flutter`) — интернетсіз жұмыс істейді,
Android, iOS, Windows және Web-те қосымша нативті баптаусыз істейді. Деректер JSON
жолдары ретінде бөлек box-тарда сақталады, `crypto` құпиясөзді SHA-256 арқылы хэштейді.

### Модельдер (Entity)

| Entity | Негізгі өрістер | Байланыс |
|---|---|---|
| UserProfile | id, name, email, phone, passwordHash | 1 — N Address, Order, Favorite, CartItem |
| Category | id, name, order | 1 — N Product |
| Product | id, name, subtitle, price, categoryId, colors, images, inStock, popularity, createdAt | N — 1 Category |
| Address | id, userId, label, fullName, phone, city, street, apartment, postalCode, isDefault | N — 1 User |
| Order | id, userId, status, items (Product snapshot), address (snapshot), totals, dates | N — 1 User |
| Favorite | userId, productId, createdAt | User N — N Product |
| CartItem | userId, productId, colorIndex, quantity | User N — N Product |

### Қабаттар

```
UI (features) -> AppState (ChangeNotifier) -> Repositories -> JsonStore -> Hive box
```

- `data/local` — `AppDatabase` (инициализация), `JsonStore`, `DatabaseSeeder`, `SeedData`.
- `data/repositories` — Product, Category, User, Address, Order, Favorite, Cart, Settings.
- Қателер `DatabaseException` арқылы көтеріледі, `AppState` оларды ұстап, SnackBar көрсетеді.
  Дерекқор ашылмаса, «Қайталау» түймесі бар экран шығады.

### CRUD, іздеу, сүзгі, сұрыптау

- **Product**: Профиль → «Тауарларды басқару» (қосу, оқу, өзгерту, жою).
- **Address**: Профиль → «Жеткізу мекенжайлары».
- **Favorite / Cart / Order / Profile / Settings** — деректер қорына жазылады.
- Іздеу: Іздеу бөлімі және басқару экранындағы іздеу.
- Сүзгі: санат, баға аралығы, «тек қоймада бар».
- Сұрыптау (5 параметр): танымалдығы, баға өсу/кему, атауы, жаңалығы.
- Бос күйлер: бос каталог, бос себет, бос таңдаулы, бос тапсырыстар, нәтиже жоқ.

### Тексеру тізімі (интернетсіз)

1. Ұшақ режимін қосып қосымшаны іске қосыңыз (суреттер орнына толтырғыш көрінеді).
2. Тауар қосыңыз, өзгертіңіз, жойыңыз; мекенжайды қосып өңдеңіз.
3. Таңдаулыға және себетке қосыңыз, тапсырыс рәсімдеңіз.
4. Қосымшаны толық жауып қайта ашыңыз: деректер мен сессия сақталады.

## REST API (практикалық жұмыс №5)

Таңдалған API: **DummyJSON** (`https://dummyjson.com`), `http` пакеті арқылы.
DummyJSON GET, POST, PUT, PATCH және DELETE әдістерін қолдайды, бірақ жазу операцияларын
серверде сақтамай, нәтижені симуляциялап қайтарады. Сондықтан қосымшада жаңа қосылған
(симуляцияланған) жазбаларға PATCH/DELETE серверге жіберілмей, тек қосымшада орындалады
және экранда түсіндіріледі.

| Endpoint | Әдіс | Операция |
|---|---|---|
| `/products?limit=&skip=` | GET | Тауарлар тізімі (пагинация) |
| `/products/search?q=` | GET | Серверден іздеу |
| `/products/{id}` | GET | Бір тауар (қате тексеруде 404) |
| `/products/add` | POST | Жаңа тауар қосу |
| `/products/{id}` | PATCH | Тауарды өзгерту (қосымшада) |
| `/products/{id}` | PUT | Толық ауыстыру (`ProductApi.replaceProduct`) |
| `/products/{id}` | DELETE | Тауарды өшіру |

Файлдар: `data/remote/` (клиент, endpoint-тер, модельдер, mapper), `features/remote/`
(контроллер және экран). Ашу: Профиль → «Сервер каталогы (API)».

### Күйлер және қателер

- Loading: бастапқы жүктеу индикаторы, жоғарғы `LinearProgressIndicator`, түймелердегі spinner.
- Success: тізім және SnackBar хабарлары.
- Error: `NoInternetException`, `RequestTimeoutException` (10 с), `ServerException` (404/5xx),
  `ParseException`. Әрқайсысы өз хабарламасымен және «Қайталау» түймесімен көрсетіледі.
- Интернет жоқ болса, соңғы сәтті жауап Hive кэшінен (`remote_cache`) көрсетіледі.
- Байланыс: «Каталогқа сақтау» тауарды жергілікті Hive каталогына (`id = r{serverId}`,
  `remoteId`) жазады; сервердегі өзгеріс/өшіру жергілікті көшірмеге де қолданылады.

### Тексеру

1. GET: экранды ашыңыз, тізім жүктеледі; төмен тартып жаңартыңыз; іздеу жолын қолданыңыз.
2. POST: «Қосу» → форманы толтырыңыз → тізімнің басында жаңа жазба шығады.
3. PATCH: тізімдегі қарындаш белгісі → өзгертіп сақтаңыз.
4. DELETE: себет белгісі → растаңыз.
5. Offline: ұшақ режимі + «Қайталау»/жаңарту — кэш көрсетіледі немесе қате экраны.
6. Timeout / 404: экрандағы колба белгісі → «API тексеру».
7. Байланыс: «Каталогқа сақтау» → басты бет пен каталогта тауар пайда болады.

## Практикалық жұмыс №6 — Auth, Provider, геолокация

- **State Management: Provider.** `app.dart` ішінде `ChangeNotifierProvider<AppState>.value`,
  экрандарда `context.watch<AppState>()` (қайта салу), `context.read<AppState>()` (әрекет),
  `context.select` (`MainShell`: тек қажетті өріс өзгергенде қайта салынады).
- **Күрделі функция: геолокация** (`geolocator`). Орынға рұқсат сұрау, мекенжайды GPS арқылы
  толтыру (Мекенжай формасы) және жеткізу қаласын автоматты анықтау (Басты бет → қала таңдау).
  Координаттар бойынша мекенжай OpenStreetMap Nominatim арқылы анықталады.
- **Permission жағдайлары:** рұқсат берілді; бас тартылды (қайта сұрау); мәңгі бұғатталды
  (баптауларды ашу); геолокация өшірулі (баптауларды ашу); timeout; қолжетімсіз.
- **Route guard:** `AppRouter.isProtected` — splash, onboarding, login, register ғана ашық.
  Қалған экрандарға кірмеген пайдаланушы login-ге бағытталады, кіргеннен кейін қажетті экранға оралады.
- **Сессия:** `AppState.startSession` Hive-қа сақтайды, `AppState` конструкторы қалпына келтіреді.
- Registration-ға құпиясөзді қайталау өрісі қосылды, Profile-де тапсырыс/таңдаулы/мекенжай саны көрсетіледі.

### Тексеру

1. Тіркелу → қате пароль (хабарлама) → дұрыс кіру → қосымшаны жауып қайта ашу (сессия сақталады).
2. Профиль → «Аккаунттан шығу» → login экраны; артқа қайту мүмкін емес.
3. Профиль → Мекенжайлар → қосу → «Қазіргі орынды қолдану»: рұқсат беріңіз (өрістер толады).
4. Рұқсаттан бас тартыңыз → диалог; «мәңгі бас тарту» → «Баптауларды ашу».
5. Геолокацияны өшіріңіз → «Орынды қосу» диалогы.
6. Басты бет → қала → «Орынды автоматты анықтау».
7. Guard: `flutter test test/auth_guard_test.dart`.
