class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://dummyjson.com';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const int usdToKzt = 480;
  static const int remotePageSize = 20;
  static const int deliveryFee = 1500;
  static const int freeDeliveryFrom = 50000;
  static const String promoCode = 'SAT2026';
  static const int promoPercent = 10;
  static const String demoUserId = 'u1';
  static const String paymentCardLabel = 'Банк картасы · •••• 4242';
  static const String paymentCashLabel = 'Алу кезінде төлеу';
  static const String demoEmail = 'aidana@mail.kz';
  static const String demoPassword = 'Sat12345';
  static const String demoPhone = '+7 (701) 234 56 78';
  static const String appVersion = '1.0.0';
  static const List<String> cities = ['Алматы', 'Астана', 'Шымкент', 'Қарағанды', 'Ақтөбе'];
}
