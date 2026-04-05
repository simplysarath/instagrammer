import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../share_tray/providers/share_tray_provider.dart';
import '../../share_tray/models/share_item.dart';
import '../../search/widgets/search_bar_widget.dart';
import '../../search/widgets/search_results_widget.dart';
import '../../search/providers/search_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  String _searchQuery = '';

  String get _title {
    switch (widget.categoryId) {
      case 'sarees': return 'Sarees';
      case 'salwars': return 'Salwars';
      case 'modern': return 'Modern';
      case 'kids': return 'Kids';
      default: return widget.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBarWidget(
              onSearch: (q) => setState(() => _searchQuery = q),
              categoryId: widget.categoryId,
              hintText: 'Search in $_title...',
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildProductGrid(context)
                : _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final searchAsync =
        ref.watch(searchProvider((_searchQuery, widget.categoryId)));
    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Search error: $e')),
      data: (results) => SearchResultsWidget(results: results),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    final productsAsync = ref.watch(productListProvider(widget.categoryId));
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No products in $_title yet',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => context.push('/product/${product.id}'),
              onQuickAdd: () {
                ref.read(shareTrayProvider.notifier).addItem(
                  ShareItem(
                    productId: product.id,
                    imageFileId: product.primaryImageId,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
