import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';

class DatabaseErrorApp extends StatelessWidget {
  const DatabaseErrorApp({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.storage_outlined,
            title: 'Деректер қоры ашылмады',
            message: message,
            actionLabel: 'Қайталау',
            onAction: onRetry,
          ),
        ),
      ),
    );
  }
}
