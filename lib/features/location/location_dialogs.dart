import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../data/location/location_service.dart';

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
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Жабу'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            action();
          },
          child: Text(actionLabel, style: AppText.link),
        ),
      ],
    ),
  );
}
