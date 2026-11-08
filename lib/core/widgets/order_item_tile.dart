import 'package:flutter/material.dart';

import '../../data/models/cart_item.dart';
import '../theme/app_text.dart';
import '../utils/formatters.dart';
import 'net_image.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item, this.showQuantity = true});

  final CartItem item;
  final bool showQuantity;

  @override
  Widget build(BuildContext context) {
    final subtitle = showQuantity
        ? '${item.colorName} · ${item.quantity} дана'
        : item.info;
    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: NetImage(url: item.product.image, borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyStrong,
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.caption),
              const SizedBox(height: 2),
              Text(Formatters.price(item.lineTotal), style: AppText.bodyStrong),
            ],
          ),
        ),
      ],
    );
  }
}
