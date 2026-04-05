import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/ximilar_service.dart';
import '../providers/upload_provider.dart';
import '../../catalog/data/product_repository.dart';
import '../../catalog/models/product.dart';
import '../../catalog/models/product_tags.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/tag_chip.dart';
import '../../../shared/widgets/stock_indicator.dart';

final _ximilarProvider = Provider<XimilarService>((ref) => XimilarService());
final _productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository());

class TagReviewScreen extends ConsumerStatefulWidget {
  const TagReviewScreen({super.key});

  @override
  ConsumerState<TagReviewScreen> createState() => _TagReviewScreenState();
}

class _TagReviewScreenState extends ConsumerState<TagReviewScreen> {
  bool _isLoadingTags = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _garmentTypeError;

  // Editable tag state
  String _garmentType = '';
  String? _fabric;
  String? _color;
  String? _occasion;
  String? _ageGroup;

  // Product fields
  String _stockStatus = 'in';
  double? _price;
  String _category = 'sarees';

  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const _categoryOptions = ['sarees', 'salwars', 'modern', 'kids'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTags());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final uploadState = ref.read(uploadProvider);
    final fileId = uploadState.bgRemovedFileId ?? uploadState.primaryFileId;
    if (fileId.isEmpty) {
      setState(() => _isLoadingTags = false);
      return;
    }

    final service = ref.read(_ximilarProvider);
    final tags = await service.tagProduct(fileId);
    if (mounted) {
      setState(() {
        _garmentType = tags.garmentType;
        _fabric = tags.fabric;
        _color = tags.color;
        _occasion = tags.occasion;
        _ageGroup = tags.ageGroup;
        _isLoadingTags = false;
        // Try to infer category from garment type
        _category = _inferCategory(tags.garmentType);
      });
    }
  }

  String _inferCategory(String garmentType) {
    final g = garmentType.toLowerCase();
    if (g.contains('saree') || g.contains('sari')) return 'sarees';
    if (g.contains('salwar') || g.contains('kurta') || g.contains('suit')) return 'salwars';
    if (g.contains('kid') || g.contains('child') || g.contains('girl') || g.contains('boy')) return 'kids';
    return 'modern';
  }

  Future<void> _saveProduct() async {
    if (_garmentType.trim().isEmpty) {
      setState(() => _garmentTypeError = 'Garment type cannot be empty');
      return;
    }
    setState(() {
      _garmentTypeError = null;
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final uploadState = ref.read(uploadProvider);
      final userId = ref.read(authProvider).valueOrNull?.$id ?? '';

      // Build denormalized search_text for full-text search
      final searchTextParts = [
        _garmentType,
        if (_fabric != null) _fabric!,
        if (_color != null) _color!,
        if (_occasion != null) _occasion!,
        if (_ageGroup != null) _ageGroup!,
        _category,
      ].where((s) => s.isNotEmpty).toList();

      final imageIds = List<String>.from(uploadState.uploadedFileIds);
      // If bg removal was done, replace the primary image ID
      if (uploadState.bgRemovedFileId != null && imageIds.isNotEmpty) {
        imageIds[0] = uploadState.bgRemovedFileId!;
      }

      final product = Product(
        id: '',
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        imageIds: imageIds,
        primaryImageId: imageIds.isNotEmpty ? imageIds.first : '',
        tags: ProductTags(
          garmentType: _garmentType.trim(),
          fabric: _fabric,
          color: _color,
          occasion: _occasion,
          ageGroup: _ageGroup,
        ),
        price: _price,
        stockStatus: _stockStatus,
        bgRemovalStatus: uploadState.bgRemovalStatus,
        category: _category,
        uploadedBy: userId,
        searchText: searchTextParts.join(' '),
      );

      final repo = ref.read(_productRepoProvider);
      await repo.createProduct(product);

      // Reset upload state
      ref.read(uploadProvider.notifier).reset();

      if (mounted) {
        // Pop the entire upload stack back to home
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Tags'),
        actions: [
          if (!_isLoadingTags)
            TextButton(
              onPressed: _isSaving ? null : _saveProduct,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
        ],
      ),
      body: _isLoadingTags
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Analyzing image...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags section
                  Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  // Garment type (required)
                  Row(
                    children: [
                      Expanded(
                        child: TagChip(
                          label: 'Type',
                          value: _garmentType,
                          editable: true,
                          onChanged: (v) => setState(() {
                            _garmentType = v;
                            _garmentTypeError = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('*required',
                          style: TextStyle(
                              fontSize: 11,
                              color: _garmentTypeError != null
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.grey)),
                    ],
                  ),
                  if (_garmentTypeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(_garmentTypeError!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12)),
                    ),

                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TagChip(
                        label: 'Fabric',
                        value: _fabric,
                        editable: true,
                        deletable: _fabric != null,
                        onChanged: (v) => setState(() => _fabric = v.isEmpty ? null : v),
                        onDelete: () => setState(() => _fabric = null),
                      ),
                      TagChip(
                        label: 'Color',
                        value: _color,
                        editable: true,
                        deletable: _color != null,
                        onChanged: (v) => setState(() => _color = v.isEmpty ? null : v),
                        onDelete: () => setState(() => _color = null),
                      ),
                      TagChip(
                        label: 'Occasion',
                        value: _occasion,
                        editable: true,
                        deletable: _occasion != null,
                        onChanged: (v) => setState(() => _occasion = v.isEmpty ? null : v),
                        onDelete: () => setState(() => _occasion = null),
                      ),
                      TagChip(
                        label: 'Age Group',
                        value: _ageGroup,
                        editable: true,
                        deletable: _ageGroup != null,
                        onChanged: (v) => setState(() => _ageGroup = v.isEmpty ? null : v),
                        onDelete: () => setState(() => _ageGroup = null),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Category dropdown
                  Text('Category', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(isDense: true),
                    items: _categoryOptions.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c[0].toUpperCase() + c.substring(1)),
                    )).toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),

                  const SizedBox(height: 20),
                  // Stock + Price
                  Text('Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StockIndicator(
                        status: _stockStatus,
                        interactive: true,
                        onChanged: (v) => setState(() => _stockStatus = v),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (optional)',
                            prefixText: '₹',
                            isDense: true,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          onChanged: (v) =>
                              _price = double.tryParse(v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Save Product'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
