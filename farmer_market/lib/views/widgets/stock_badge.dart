import 'package:material_ui/material_ui.dart';

import '../../models/product.dart';

/// Stok durumu etiketi: tükendi / az kaldı / normal
class StockBadge extends StatelessWidget {
  final Product product;
  final bool compact;

  const StockBadge({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg, IconData icon, String label) = switch (product) {
      Product(isOutOfStock: true) => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.remove_shopping_cart_outlined,
          'Tükendi',
        ),
      Product(isLowStock: true) => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.trending_down,
          compact ? 'Az kaldı' : 'Az kaldı · ${product.stockKg} kg',
        ),
      _ => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          Icons.inventory_2_outlined,
          '${product.stockKg} kg stokta',
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
