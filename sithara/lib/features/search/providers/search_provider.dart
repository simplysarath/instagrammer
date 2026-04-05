import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_results.dart';
import '../../catalog/data/product_repository.dart';
import '../../catalog/models/product.dart';

final searchProductRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(),
);

class SearchNotifier extends FamilyAsyncNotifier<SearchResults, (String, String?)> {
  @override
  Future<SearchResults> build((String, String?) arg) async {
    final (query, categoryId) = arg;
    if (query.trim().isEmpty) {
      return SearchResults.empty(query);
    }

    final repo = ref.read(searchProductRepositoryProvider);
    final products = await repo.searchProducts(query, categoryId: categoryId);

    // Group by category
    final byCategory = <String, List<Product>>{};
    for (final product in products) {
      byCategory.putIfAbsent(product.category, () => []).add(product);
    }

    return SearchResults(byCategory: byCategory, query: query);
  }
}

final searchProvider = AsyncNotifierProviderFamily<SearchNotifier, SearchResults, (String, String?)>(
  SearchNotifier.new,
);
