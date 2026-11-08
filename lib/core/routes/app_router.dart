import 'package:flutter/material.dart';

import '../../data/models/address.dart';
import '../../data/models/category.dart';
import '../../data/state/app_state.dart';
import '../../data/models/product.dart';
import '../../features/addresses/screens/address_form_screen.dart';
import '../../features/addresses/screens/addresses_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/catalog/screens/catalog_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/order_success_screen.dart';
import '../../features/main/screens/main_shell.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/orders/screens/order_status_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/product/screens/manage_products_screen.dart';
import '../../features/remote/screens/remote_catalog_screen.dart';
import '../../features/product/screens/product_detail_screen.dart';
import '../../features/product/screens/product_form_screen.dart';
import '../../features/profile/screens/personal_data_screen.dart';
import '../../features/settings/screens/change_password_screen.dart';
import '../../features/settings/screens/legal_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter(this._state);

  final AppState _state;

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
      AppRoutes.productDetail => ProductDetailScreen(productId: args is String ? args : ''),
      AppRoutes.checkout => const CheckoutScreen(),
      AppRoutes.orderSuccess => OrderSuccessScreen(orderId: args is String ? args : ''),
      AppRoutes.orders => const OrdersScreen(),
      AppRoutes.orderStatus => OrderStatusScreen(orderId: args is String ? args : ''),
      AppRoutes.addresses => const AddressesScreen(),
      AppRoutes.addressForm => AddressFormScreen(address: args is Address ? args : null),
      AppRoutes.settings => const SettingsScreen(),
      AppRoutes.personalData => const PersonalDataScreen(),
      AppRoutes.changePassword => const ChangePasswordScreen(),
      AppRoutes.remoteCatalog => const RemoteCatalogScreen(),
      AppRoutes.manageProducts => const ManageProductsScreen(),
      AppRoutes.productForm => ProductFormScreen(product: args is Product ? args : null),
      AppRoutes.legal => LegalScreen(args: args is LegalArgs ? args : LegalArgs.terms),
      _ => const SplashScreen(),
    };
    return MaterialPageRoute<dynamic>(settings: settings, builder: (context) => page);
  }
}
