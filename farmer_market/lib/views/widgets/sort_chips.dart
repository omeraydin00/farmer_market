import 'package:material_ui/material_ui.dart';

import '../../models/product.dart';

enum ProductSort {
  varsayilan('Varsayılan'),
  artan('Fiyat: Artan'),
  azalan('Fiyat: Azalan');

  final String label;
  const ProductSort(this.label);

  List<Product> apply(List<Product> products) {
    final sorted = [...products];
    switch (this) {
      case ProductSort.artan:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.azalan:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.varsayilan:
        // En yeni ürün en üstte, tarihi olmayan eski kayıtlar sonda
        sorted.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
    }
    return sorted;
  }
}

class SortChips extends StatelessWidget {
  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  const SortChips({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final option in ProductSort.values) ...[
            ChoiceChip(
              label: Text(option.label),
              selected: option == value,
              showCheckmark: false,
              onSelected: (_) => onChanged(option),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
