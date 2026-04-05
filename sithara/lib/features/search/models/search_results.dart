import '../../catalog/models/product.dart';

class SearchResults {
  final Map<String, List<Product>> byCategory; // categoryId → products
  final String query;

  const SearchResults({
    required this.byCategory,
    required this.query,
  });

  bool get isEmpty => byCategory.values.every((list) => list.isEmpty);

  int get totalCount =>
      byCategory.values.fold(0, (sum, list) => sum + list.length);

  static SearchResults empty(String query) =>
      SearchResults(byCategory: {}, query: query);
}
