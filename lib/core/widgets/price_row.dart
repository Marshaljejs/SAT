import 'package:flutter/material.dart';

import '../theme/app_text.dart';

class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? AppText.bodyStrong : AppText.body),
          Text(value, style: isTotal ? AppText.h3 : AppText.bodyStrong),
        ],
      ),
    );
  }
}
