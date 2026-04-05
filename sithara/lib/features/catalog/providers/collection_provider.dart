import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collection_repository.dart';
import '../models/collection.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(),
);

class CollectionListNotifier extends AsyncNotifier<List<Collection>> {
  @override
  Future<List<Collection>> build() async {
    return ref.read(collectionRepositoryProvider).getCollections();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(collectionRepositoryProvider).getCollections(),
    );
  }
}

final collectionListProvider = AsyncNotifierProvider<CollectionListNotifier, List<Collection>>(
  CollectionListNotifier.new,
);
