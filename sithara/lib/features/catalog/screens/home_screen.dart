import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../providers/collection_provider.dart';
import '../../../shared/widgets/category_tile.dart';
import '../../search/widgets/search_bar_widget.dart';
import '../../search/widgets/search_results_widget.dart';
import '../../search/providers/search_provider.dart';

const _categories = [
  {'id': 'sarees', 'label': 'Sarees'},
  {'id': 'salwars', 'label': 'Salwars'},
  {'id': 'modern', 'label': 'Modern'},
  {'id': 'kids', 'label': 'Kids'},
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sithara'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBarWidget(
              onSearch: (q) => setState(() => _searchQuery = q),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildGrid(context)
                : _buildSearchResults(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/upload/pick'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final searchAsync = ref.watch(searchProvider((_searchQuery, null)));
    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Search error: $e')),
      data: (results) => SearchResultsWidget(results: results),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final collectionsAsync = ref.watch(collectionListProvider);
    final collections = collectionsAsync.valueOrNull ?? [];

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
            productCount: 0,
            onTap: () => context.push('/collection/${item.id}'),
          );
        }
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
