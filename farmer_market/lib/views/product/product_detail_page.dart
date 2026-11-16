import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../widgets/product_image.dart';
import '../widgets/stock_badge.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final AppUser viewer;

  const ProductDetailPage({super.key, required this.product, required this.viewer});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Listeden gelen ürünle açılıyor ama belgeyi dinlemeye devam ediyor,
  // düzenlemeden dönünce sayfa eski bilgiyi göstermesin
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _productStream =
      FirebaseFirestore.instance.collection('products').doc(widget.product.id).snapshots();

  Future<void> _callFarmer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama başlatılamadı. Numara: $phone')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _productStream,
      builder: (context, snapshot) {
        final doc = snapshot.data;
        if (doc != null && !doc.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Bu ürün artık satışta değil.')),
          );
        }
        final product = doc != null ? Product.fromMap(doc.data()!, doc.id) : widget.product;
        return _buildPage(context, product);
      },
    );
  }

  Widget _buildPage(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isOwner = product.ownerId != null && product.ownerId == widget.viewer.uid;
    final phone = product.sellerPhone?.trim() ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: scheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filledTonal(
                tooltip: 'Geri',
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(backgroundColor: scheme.surface.withValues(alpha: 0.9)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImage(url: product.imageUrl),
            ),
            // Resmin altına binen yuvarlak köşeli içerik başlangıcı
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: formatPrice(product.price),
                              style: theme.textTheme.headlineSmall?.copyWith(color: scheme.primary),
                            ),
                            TextSpan(
                              text: ' / kg',
                              style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StockBadge(product: product),
                    ],
                  ),
                  if (product.description != null && product.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Açıklama', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      product.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('Çiftçi', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _FarmerCard(product: product, isOwner: isOwner),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: isOwner
              ? OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ürünü Düzenle'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductPage(product: product, user: widget.viewer),
                    ),
                  ),
                )
              : FilledButton.icon(
                  icon: const Icon(Icons.call),
                  label: Text(phone.isEmpty ? 'Telefon bilgisi yok' : 'Çiftçiyi Ara'),
                  onPressed: phone.isEmpty ? null : () => _callFarmer(phone),
                ),
        ),
      ),
    );
  }
}

class _FarmerCard extends StatelessWidget {
  final Product product;
  final bool isOwner;

  const _FarmerCard({required this.product, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = product.sellerName?.trim().isNotEmpty == true ? product.sellerName!.trim() : 'Çiftçi';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                initials(name),
                style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isOwner ? '$name (siz)' : name, style: theme.textTheme.titleMedium),
                  if (product.sellerLocation?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    _InfoLine(icon: Icons.place_outlined, text: product.sellerLocation!),
                  ],
                  if (product.sellerPhone?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    _InfoLine(icon: Icons.phone_outlined, text: product.sellerPhone!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
