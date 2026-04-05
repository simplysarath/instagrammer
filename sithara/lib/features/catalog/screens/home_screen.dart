import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../providers/collection_provider.dart';
import '../../../shared/widgets/category_tile.dart';

const _categories = [
  {'id': 'sarees', 'label': 'Sarees'},
  {'id': 'salwars', 'label': 'Salwars'},
  {'id': 'modern', 'label': 'Modern'},
  {'id': 'kids', 'label': 'Kids'},
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sithara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {/* TODO: open search */},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar placeholder (wired in step 11)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              readOnly: true,
              onTap: () {/* TODO: wire search in step 11 */},
              decoration: InputDecoration(
                hintText: 'Search catalog...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic_none),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildGrid(context, ref, collectionsAsync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload/pick'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, AsyncValue collectionsAsync) {
    final collections = collectionsAsync.valueOrNull ?? [];

    // Build combined list: categories first, then collections
    final categoryItems = _categories.map((c) => _GridItem(
      id: c['id']!,
      label: c['label']!,
      isCollection: false,
    )).toList();

    final collectionItems = collections.map((col) => _GridItem(
      id: col.id,
      label: col.name,
      isCollection: true,
    )).toList();

    final allItems = [...categoryItems, ...collectionItems];

    if (allItems.isEmpty) {
      return const Center(
        child: Text('No products yet — tap + to add your first'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item.isCollection) {
          return CategoryTile(
            categoryId: item.id,
            label: item.label,
            productCount: 0, // collections show product count in step 8
            onTap: () => context.push('/collection/${item.id}'),
          );
        }
        // Category tile — watch product count
        final products = ref.watch(productListProvider(item.id));
        final count = products.valueOrNull?.length ?? 0;
        return CategoryTile(
          categoryId: item.id,
          label: item.label,
          productCount: count,
          onTap: () => context.push('/category/${item.id}'),
        );
      },
    );
  }
}

class _GridItem {
  final String id;
  final String label;
  final bool isCollection;
  _GridItem({required this.id, required this.label, required this.isCollection});
}
