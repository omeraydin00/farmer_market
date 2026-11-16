import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../product/add_product_page.dart';
import '../product/edit_product_page.dart';
import '../product/product_detail_page.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_header.dart';
import '../widgets/product_image.dart';
import '../widgets/sort_chips.dart';
import '../widgets/stock_badge.dart';

class FarmerHomePage extends StatefulWidget {
  final AppUser user;

  const FarmerHomePage({super.key, required this.user});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  final _searchController = TextEditingController();
  String searchQuery = '';
  ProductSort sortOption = ProductSort.varsayilan;

  // Panelde sadece bu çiftçinin ürünleri. Önceden bütün ürünler listeleniyordu,
  // bir çiftçi başkasının ürününü düzenleyip silebiliyordu.
  late final Stream<List<Product>> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .where('ownerId', isEqualTo: widget.user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(user: widget.user)),
    );
  }

  Future<void> _deleteProduct(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: Text('"${p.name}" ürününü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              minimumSize: const Size(88, 44),
            ),
            child: const Text('Sil'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('products').doc(p.id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} silindi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silinemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Product>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <Product>[];

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(user: widget.user, title: 'Ürünlerim'),
                ),
                if (snapshot.hasData) ...[
                  SliverToBoxAdapter(child: _Summary(products: all)),
                  if (all.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Ürünlerimde ara...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Temizle',
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => searchQuery = '');
                                    },
                                  ),
                          ),
                          onChanged: (value) => setState(() => searchQuery = trLower(value.trim())),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SortChips(
                        value: sortOption,
                        onChanged: (value) => setState(() => sortOption = value),
                      ),
                    ),
                  ],
                ],
                ..._buildList(snapshot),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Ürün Ekle'),
      ),
    );
  }

  List<Widget> _buildList(AsyncSnapshot<List<Product>> snapshot) {
    if (snapshot.hasError) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(icon: Icons.cloud_off_outlined, text: 'Ürünler yüklenemedi'),
        ),
      ];
    }
    if (!snapshot.hasData) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (snapshot.data!.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.eco_outlined,
            text: 'Henüz ürün eklemediniz.\nİlk ürününüzü ekleyerek satışa başlayın.',
            action: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('Ürün Ekle'),
            ),
          ),
        ),
      ];
    }

    var products = snapshot.data!;
    if (searchQuery.isNotEmpty) {
      products = products.where((p) => trLower(p.name).contains(searchQuery)).toList();
    }
    products = sortOption.apply(products);

    if (products.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(icon: Icons.search_off, text: 'Eşleşen ürün bulunamadı'),
        ),
      ];
    }

    return [
      SliverPadding(
        // FAB son kartın üstüne binmesin
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        sliver: SliverList.separated(
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = products[index];
            return _FarmerProductTile(
              product: p,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: p, viewer: widget.user)),
              ),
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProductPage(product: p, user: widget.user)),
              ),
              onDelete: () => _deleteProduct(p),
            );
          },
        ),
      ),
    ];
  }
}

/// Ürün sayısı, toplam stok ve azalan ürünler
class _Summary extends StatelessWidget {
  final List<Product> products;

  const _Summary({required this.products});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalKg = products.fold<int>(0, (total, p) => total + p.stockKg);
    final needsAttention = products.where((p) => p.isLowStock || p.isOutOfStock).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  icon: Icons.storefront_outlined,
                  value: '${products.length}',
                  label: 'Ürün',
                  color: scheme.primaryContainer,
                  onColor: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.inventory_2_outlined,
                  value: '$totalKg',
                  label: 'kg stok',
                  color: scheme.secondaryContainer,
                  onColor: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.trending_down,
                  value: '$needsAttention',
                  label: 'Az kalan',
                  color: needsAttention > 0 ? scheme.tertiaryContainer : scheme.surfaceContainerHigh,
                  onColor: needsAttention > 0 ? scheme.onTertiaryContainer : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (needsAttention > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: scheme.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$needsAttention üründe stok ${Product.lowStockKg} kg altına düştü. '
                      'Stoğu güncellemeyi unutmayın.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color onColor;

  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: onColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: onColor, fontWeight: FontWeight.w800),
          ),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: onColor)),
        ],
      ),
    );
  }
}

class _FarmerProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FarmerProductTile({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            children: [
              ProductImage(
                url: product.imageUrl,
                width: 84,
                height: 84,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatPrice(product.price),
                            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: ' / kg',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    StockBadge(product: product),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Seçenekler',
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Düzenle'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: scheme.error),
                      title: Text('Sil', style: TextStyle(color: scheme.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
