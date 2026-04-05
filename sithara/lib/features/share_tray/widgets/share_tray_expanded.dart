import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/share_tray_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/catalog/data/collection_repository.dart';
import '../../../features/catalog/providers/collection_provider.dart';
import '../../../features/upload/data/storage_repository.dart';
import '../../../core/utils/share_utils.dart';

final _storageRepoProvider = Provider<StorageRepository>((ref) => StorageRepository());
final _collectionRepoProvider = Provider<CollectionRepository>((ref) => CollectionRepository());

class ShareTrayExpanded extends ConsumerStatefulWidget {
  const ShareTrayExpanded({super.key});

  @override
  ConsumerState<ShareTrayExpanded> createState() => _ShareTrayExpandedState();
}

class _ShareTrayExpandedState extends ConsumerState<ShareTrayExpanded> {
  bool _isSharing = false;
  bool _isSavingCollection = false;
  final _collectionNameController = TextEditingController();
  bool _showCollectionInput = false;

  @override
  void dispose() {
    _collectionNameController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final items = ref.read(shareTrayProvider);
    if (items.isEmpty) return;
    setState(() => _isSharing = true);
    try {
      final repo = ref.read(_storageRepoProvider);
      await shareItems(context, items, repo);
      // After sharing, offer to clear
      if (mounted) {
        final shouldClear = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Clear tray?'),
            content: const Text('Remove all shared items from your tray?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Keep')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Clear')),
            ],
          ),
        );
        if (shouldClear == true && mounted) {
          ref.read(shareTrayProvider.notifier).clear();
          Navigator.pop(context); // close bottom sheet
        }
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _saveAsCollection() async {
    final name = _collectionNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSavingCollection = true);
    try {
      final items = ref.read(shareTrayProvider);
      final userId = ref.read(authProvider).valueOrNull?.$id ?? '';
      final repo = ref.read(_collectionRepoProvider);
      final collection = await repo.createCollection(name, userId);
      // Add all products in tray to the new collection
      for (final item in items) {
        await repo.addProductToCollection(collection.id, item.productId);
      }
      // Refresh home screen collections
      ref.invalidate(collectionListProvider);
      if (mounted) {
        setState(() {
          _showCollectionInput = false;
          _isSavingCollection = false;
        });
        _collectionNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$name" saved as a collection')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
        setState(() => _isSavingCollection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shareTrayProvider);
    final repo = ref.read(_storageRepoProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Share Tray (${items.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: items.isEmpty
                        ? null
                        : () {
                            ref.read(shareTrayProvider.notifier).clear();
                            Navigator.pop(context);
                          },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('Tray is empty',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final url = item.imageFileId.isNotEmpty
                            ? repo.getFileViewUrl(item.imageFileId)
                            : null;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: url != null
                                  ? Image.network(url,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image),
                                          ))
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Editable description
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Add a description...',
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                    text: item.description),
                                onChanged: (v) => ref
                                    .read(shareTrayProvider.notifier)
                                    .updateDescription(item.productId, v),
                                maxLines: 1,
                              ),
                            ),
                            // Remove button
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => ref
                                  .read(shareTrayProvider.notifier)
                                  .removeItem(item.productId),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            // Save as Collection input
            if (_showCollectionInput)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _collectionNameController,
                        decoration: const InputDecoration(
                          hintText: 'Collection name...',
                          isDense: true,
                        ),
                        autofocus: true,
                        onSubmitted: (_) => _saveAsCollection(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isSavingCollection
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : FilledButton(
                            onPressed: _saveAsCollection,
                            child: const Text('Save'),
                          ),
                  ],
                ),
              ),
            // Bottom action bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSavingCollection
                          ? null
                          : () => setState(
                              () => _showCollectionInput = !_showCollectionInput),
                      icon: const Icon(Icons.folder_outlined, size: 18),
                      label: const Text('Save as Collection'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            (_isSharing || items.isEmpty) ? null : _share,
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.share, size: 18),
                        label: Text(
                            _isSharing ? 'Sharing...' : 'Share (${items.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
