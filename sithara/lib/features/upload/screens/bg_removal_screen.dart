import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/bg_removal_service.dart';
import '../data/storage_repository.dart';
import '../providers/upload_provider.dart';

final _bgRemovalServiceProvider = Provider<BgRemovalService>((ref) => BgRemovalService());
final _storageRepoProvider2 = Provider<StorageRepository>((ref) => StorageRepository());

class BgRemovalScreen extends ConsumerStatefulWidget {
  const BgRemovalScreen({super.key});

  @override
  ConsumerState<BgRemovalScreen> createState() => _BgRemovalScreenState();
}

class _BgRemovalScreenState extends ConsumerState<BgRemovalScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  String? _processedFileId;

  Future<void> _removeBackground() async {
    final uploadState = ref.read(uploadProvider);
    final primaryFileId = uploadState.primaryFileId;
    if (primaryFileId.isEmpty) {
      setState(() => _errorMessage = 'No image to process');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final service = ref.read(_bgRemovalServiceProvider);
    final newFileId = await service.removeBackground(primaryFileId);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (newFileId != null) {
          _processedFileId = newFileId;
        } else {
          _errorMessage = 'Background removal failed. You can skip or try again.';
        }
      });
    }
  }

  void _approve() {
    ref.read(uploadProvider.notifier).setBgRemovalStatus(
      'done',
      newFileId: _processedFileId,
    );
    context.push('/upload/tags');
  }

  void _skipOrReject() {
    ref.read(uploadProvider.notifier).setBgRemovalStatus('none');
    context.push('/upload/tags');
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final repo = ref.read(_storageRepoProvider2);
    final primaryUrl = uploadState.primaryFileId.isNotEmpty
        ? repo.getFileViewUrl(uploadState.primaryFileId)
        : null;
    final processedUrl = _processedFileId != null
        ? repo.getFileViewUrl(_processedFileId!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Background Removal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Remove the background from your product photo.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Before/after comparison
            if (primaryUrl != null || processedUrl != null)
              Expanded(
                child: Row(
                  children: [
                    if (primaryUrl != null)
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Original',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Image.network(primaryUrl, fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image)),
                            ),
                          ],
                        ),
                      ),
                    if (processedUrl != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Processed',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Image.network(processedUrl, fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              const Expanded(child: Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.grey))),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],

            const SizedBox(height: 16),
            if (_isProcessing)
              const Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Processing...', textAlign: TextAlign.center),
                ],
              )
            else if (_processedFileId != null) ...[
              FilledButton(onPressed: _approve, child: const Text('Approve — Use this version')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: _skipOrReject, child: const Text('Reject — Keep original')),
            ] else ...[
              FilledButton(
                onPressed: _removeBackground,
                child: const Text('Remove Background'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _skipOrReject, child: const Text('Skip')),
            ],
          ],
        ),
      ),
    );
  }
}
