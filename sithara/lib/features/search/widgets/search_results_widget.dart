import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/search_results.dart';
import '../../../shared/widgets/product_card.dart';
import '../../share_tray/providers/share_tray_provider.dart';
import '../../share_tray/models/share_item.dart';

class SearchResultsWidget extends ConsumerWidget {
  final SearchResults results;

  const SearchResultsWidget({super.key, required this.results});

  String _categoryLabel(String categoryId) {
    switch (categoryId) {
      case 'sarees': return 'Sarees';
      case 'salwars': return 'Salwars';
      case 'modern': return 'Modern';
      case 'kids': return 'Kids';
      default: return categoryId;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No results for "${results.query}"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final categories = results.byCategory.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final entry = categories[catIndex];
        final categoryId = entry.key;
        final products = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (catIndex > 0) const SizedBox(height: 16),
            Text(
              '${_categoryLabel(categoryId)} (${products.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            ),
          ],
        );
      },
    );
  }
}
