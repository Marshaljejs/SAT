import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_frame.dart';
import 'data/local/app_database.dart';
import 'data/state/app_state.dart';

class SatApp extends StatefulWidget {
  const SatApp({super.key, required this.database});

  final AppDatabase database;

  @override
  State<SatApp> createState() => _SatAppState();
}

class _SatAppState extends State<SatApp> {
  late final AppState _state = AppState(widget.database);
  late final AppRouter _router = AppRouter(_state);
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

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
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
