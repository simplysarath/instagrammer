import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/collection_repository.dart';
import '../data/product_repository.dart';
import '../models/collection.dart';
import '../models/product.dart';
import '../../../shared/widgets/product_card.dart';

final _collectionRepoProvider = Provider<CollectionRepository>((ref) => CollectionRepository());
final _productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository());

// Provider to fetch a collection and its products
final collectionDetailProvider = FutureProvider.family<(Collection, List<Product>), String>(
  (ref, collectionId) async {
    final collectionRepo = ref.read(_collectionRepoProvider);
    final productRepo = ref.read(_productRepoProvider);
    final collections = await collectionRepo.getCollections();
    final collection = collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => throw Exception('Collection not found'),
    );
    final products = await Future.wait(
      collection.productIds.map((id) => productRepo.getProduct(id)),
    );
    return (collection, products);
  },
);

class CollectionScreen extends ConsumerWidget {
  final String collectionId;
  const CollectionScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(collectionDetailProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.whenData((d) => Text(d.$1.name)).value ??
            const Text('Collection'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (detail) {
          final (_, products) = detail;
          if (products.isEmpty) {
            return const Center(
              child: Text('No products in this collection',
                  style: TextStyle(color: Colors.grey)),
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
                  // TODO: wire shareTrayProvider in step 10
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to share tray')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
