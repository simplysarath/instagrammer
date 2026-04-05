import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(),
);

class ProductListNotifier extends FamilyAsyncNotifier<List<Product>, String> {
  @override
  Future<List<Product>> build(String arg) async {
    return ref.read(productRepositoryProvider).getProductsByCategory(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProductsByCategory(arg),
    );
  }
}

final productListProvider = AsyncNotifierProviderFamily<ProductListNotifier, List<Product>, String>(
  ProductListNotifier.new,
);
