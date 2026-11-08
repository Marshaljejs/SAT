import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'features/splash/screens/database_error_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await bootstrap();
}

Future<void> bootstrap() async {
  final database = AppDatabase();
  try {
    await database.init();
    runApp(SatApp(database: database));
  } catch (error) {
    runApp(
      DatabaseErrorApp(
        message: error.toString(),
        onRetry: bootstrap,
      ),
    );
  }
}
