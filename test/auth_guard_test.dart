import 'package:flutter_test/flutter_test.dart';
import 'package:sat_store_app/core/routes/app_router.dart';
import 'package:sat_store_app/core/routes/app_routes.dart';
import 'package:sat_store_app/core/utils/validators.dart';

void main() {
  test('public routes are open to guests', () {
    expect(AppRouter.isProtected(AppRoutes.splash), isFalse);
    expect(AppRouter.isProtected(AppRoutes.onboarding), isFalse);
    expect(AppRouter.isProtected(AppRoutes.login), isFalse);
    expect(AppRouter.isProtected(AppRoutes.register), isFalse);
  });

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
    final validator = Validators.confirmPassword(() => 'Sat12345');
    expect(validator(''), isNotNull);
    expect(validator('other'), isNotNull);
    expect(validator('Sat12345'), isNull);
  });
}
