import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/share_item.dart';

class ShareTrayNotifier extends Notifier<List<ShareItem>> {
  @override
  List<ShareItem> build() => [];

  void addItem(ShareItem item) {
    // Avoid duplicates by productId
    final existing = state.indexWhere((i) => i.productId == item.productId);
    if (existing == -1) {
      state = [...state, item];
    } else {
      // Update the existing item's image
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existing) item else state[i],
      ];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void updateDescription(String productId, String description) {
    state = [
      for (final item in state)
        if (item.productId == productId)
          item.copyWith(description: description)
        else
          item,
    ];
  }

  void clear() {
    state = [];
  }
}

final shareTrayProvider = NotifierProvider<ShareTrayNotifier, List<ShareItem>>(
  ShareTrayNotifier.new,
);
