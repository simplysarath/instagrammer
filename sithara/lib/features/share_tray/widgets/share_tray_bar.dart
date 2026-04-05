import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/share_tray_provider.dart';
import '../../../features/upload/data/storage_repository.dart';
import 'share_tray_expanded.dart';

final _storageRepoProvider = Provider<StorageRepository>((ref) => StorageRepository());

class ShareTrayBar extends ConsumerWidget {
  const ShareTrayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trayItems = ref.watch(shareTrayProvider);

    if (trayItems.isEmpty) return const SizedBox.shrink();

    final repo = ref.read(_storageRepoProvider);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const ShareTrayExpanded(),
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Thumbnails (up to 5)
              ...trayItems.take(5).map((item) {
                final url = item.imageFileId.isNotEmpty
                    ? repo.getFileViewUrl(item.imageFileId)
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: url != null
                        ? Image.network(url,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image, size: 20),
                                ))
                        : Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 20),
                          ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${trayItems.length} item${trayItems.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const ShareTrayExpanded(),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
