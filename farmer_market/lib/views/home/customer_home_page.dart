import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../product/product_detail_page.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_header.dart';
import '../widgets/product_card.dart';
import '../widgets/sort_chips.dart';

class CustomerHomePage extends StatefulWidget {
  final AppUser user;

  const CustomerHomePage({super.key, required this.user});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final _searchController = TextEditingController();
  String searchQuery = '';
  ProductSort sortOption = ProductSort.varsayilan;

  // Akış bir kere oluşturuluyor. Eskiden build içinde her seferinde yeni stream
  // açılıyordu, aramaya her harf yazıldığında liste baştan yükleniyordu.
  late final Stream<List<Product>> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> products) {
    var result = products;
    if (searchQuery.isNotEmpty) {
      result = result.where((p) => trLower(p.name).contains(searchQuery)).toList();
    }
    return sortOption.apply(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Product>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    user: widget.user,
                    title: 'Bugün taze ne var?',
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Domates, biber, çilek...',
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
                ..._buildProducts(context, snapshot, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildProducts(BuildContext context, AsyncSnapshot<List<Product>> snapshot, ThemeData theme) {
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

    final products = _filter(snapshot.data!);

    if (products.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.search_off,
            text: snapshot.data!.isEmpty ? 'Henüz ürün eklenmemiş' : 'Eşleşen ürün bulunamadı',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        sliver: SliverToBoxAdapter(
          child: Text(
            '${products.length} ürün',
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 246,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return ProductCard(
              product: p,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: p, viewer: widget.user),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}
