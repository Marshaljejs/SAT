import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_bottom_nav.dart';
import '../../../data/state/app_state.dart';
import '../../cart/screens/cart_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../search/screens/search_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = context.select<AppState, int>((state) => state.currentTab);
    final cartCount = context.select<AppState, int>((state) => state.cartCount);
    final state = context.read<AppState>();
    return PopScope(
      canPop: tab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          state.setTab(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: tab, children: _pages),
        bottomNavigationBar: AppBottomNav(
          currentIndex: tab,
          onSelected: state.setTab,
          cartCount: cartCount,
        ),
      ),
    );
  }
}
