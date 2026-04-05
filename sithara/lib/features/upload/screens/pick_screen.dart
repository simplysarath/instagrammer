import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/upload_provider.dart';
import '../data/storage_repository.dart';

final _storageRepoProvider = Provider<StorageRepository>((ref) => StorageRepository());

class PickScreen extends ConsumerStatefulWidget {
  const PickScreen({super.key});

  @override
  ConsumerState<PickScreen> createState() => _PickScreenState();
}

class _PickScreenState extends ConsumerState<PickScreen> {
  final _picker = ImagePicker();
  List<String> _selectedPaths = [];
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 90);
    if (images.isNotEmpty) {
      setState(() {
        _selectedPaths = [..._selectedPaths, ...images.map((x) => x.path)];
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        _selectedPaths = [..._selectedPaths, image.path];
        _errorMessage = null;
      });
    }
  }

  void _removePath(int index) {
    setState(() {
      _selectedPaths = List.from(_selectedPaths)..removeAt(index);
    });
  }

  Future<void> _done() async {
    if (_selectedPaths.isEmpty) {
      setState(() => _errorMessage = 'Select at least one photo');
      return;
    }
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      ref.read(uploadProvider.notifier).setSelectedFiles(_selectedPaths);
      final repo = ref.read(_storageRepoProvider);
      final ids = await repo.uploadProductImages(_selectedPaths);
      ref.read(uploadProvider.notifier).setUploadedFileIds(ids);
      if (mounted) context.push('/upload/bg-removal');
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Photos'),
        actions: [
          TextButton(
            onPressed: _isUploading || _selectedPaths.isEmpty ? null : _done,
            child: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedPaths.isNotEmpty) ...[
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedPaths[index]),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removePath(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(_errorMessage!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _selectedPaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No photos selected',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'Add more photos or tap Done',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
