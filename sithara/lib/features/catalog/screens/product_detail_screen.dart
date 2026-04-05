import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../data/collection_repository.dart';
import '../models/product.dart';
import '../models/product_tags.dart';
import '../../../shared/widgets/tag_chip.dart';
import '../../../shared/widgets/stock_indicator.dart';
import '../../upload/data/storage_repository.dart';
import '../../share_tray/providers/share_tray_provider.dart';
import '../../share_tray/models/share_item.dart';

final _productRepoProvider = Provider<ProductRepository>((ref) => ProductRepository());
final _collectionRepoProvider = Provider<CollectionRepository>((ref) => CollectionRepository());
final _storageRepoProvider = Provider<StorageRepository>((ref) => StorageRepository());

final productDetailProvider = FutureProvider.family<Product, String>(
  (ref, productId) => ref.read(_productRepoProvider).getProduct(productId),
);

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  int _activeImageIndex = 0;

  // Edit state — populated when entering edit mode
  late String _garmentType;
  late String? _fabric;
  late String? _color;
  late String? _occasion;
  late String? _ageGroup;
  late String _stockStatus;
  late String _category;
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _garmentTypeError;

  static const _categoryOptions = ['sarees', 'salwars', 'modern', 'kids'];

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _enterEditMode(Product product) {
    setState(() {
      _isEditing = true;
      _garmentType = product.tags.garmentType;
      _fabric = product.tags.fabric;
      _color = product.tags.color;
      _occasion = product.tags.occasion;
      _ageGroup = product.tags.ageGroup;
      _stockStatus = product.stockStatus;
      _category = product.category;
      _priceController.text = product.price?.toStringAsFixed(2) ?? '';
      _descriptionController.text = product.description ?? '';
      _garmentTypeError = null;
    });
  }

  Future<void> _saveEdit(Product product) async {
    if (_garmentType.trim().isEmpty) {
      setState(() => _garmentTypeError = 'Garment type cannot be empty');
      return;
    }
    setState(() {
      _garmentTypeError = null;
      _isSaving = true;
    });

    try {
      final searchTextParts = [
        _garmentType,
        if (_fabric != null) _fabric!,
        if (_color != null) _color!,
        if (_occasion != null) _occasion!,
        if (_ageGroup != null) _ageGroup!,
        _category,
      ].where((s) => s.isNotEmpty).toList();

      final updates = <String, dynamic>{
        'tags': ProductTags(
          garmentType: _garmentType.trim(),
          fabric: _fabric,
          color: _color,
          occasion: _occasion,
          ageGroup: _ageGroup,
        ).toJson(),
        'stock_status': _stockStatus,
        'category': _category,
        'search_text': searchTextParts.join(' '),
        if (_priceController.text.isNotEmpty)
          'price': double.tryParse(_priceController.text),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      await ref.read(_productRepoProvider).updateProduct(product.id, updates);
      // Invalidate the detail provider to refetch
      ref.invalidate(productDetailProvider(widget.productId));
      if (mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addToShareTray(Product product) {
    final activeImageId = product.imageIds.isNotEmpty
        ? product.imageIds[_activeImageIndex]
        : product.primaryImageId;
    ref.read(shareTrayProvider.notifier).addItem(
      ShareItem(
        productId: product.id,
        imageFileId: activeImageId,
        description: product.description ?? '',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to share tray')),
    );
  }

  Future<void> _showAddToCollection(Product product) async {
    final collections = await ref.read(_collectionRepoProvider).getCollections();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _AddToCollectionSheet(
        collections: collections,
        onSelect: (collectionId) async {
          Navigator.pop(ctx);
          await ref
              .read(_collectionRepoProvider)
              .addProductToCollection(collectionId, product.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to collection')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => productAsync.whenData(_enterEditMode),
            )
          else ...[
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => productAsync.whenData(_saveEdit),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (product) => _isEditing
            ? _buildEditView(product)
            : _buildDetailView(product),
      ),
    );
  }

  Widget _buildDetailView(Product product) {
    final repo = ref.read(_storageRepoProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Swipeable image gallery
          SizedBox(
            height: 320,
            child: PageView.builder(
              itemCount: product.imageIds.length,
              onPageChanged: (i) => setState(() => _activeImageIndex = i),
              itemBuilder: (context, index) {
                final url = repo.getFileViewUrl(product.imageIds[index]);
                return Image.network(url, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 60));
              },
            ),
          ),

          // Image selector row
          if (product.imageIds.length > 1)
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: product.imageIds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final url = repo.getFileViewUrl(product.imageIds[index]);
                  return GestureDetector(
                    onTap: () => setState(() => _activeImageIndex = index),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _activeImageIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: _activeImageIndex == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (product.tags.garmentType.isNotEmpty)
                      Chip(label: Text(product.tags.garmentType)),
                    if (product.tags.fabric != null)
                      Chip(label: Text(product.tags.fabric!)),
                    if (product.tags.color != null)
                      Chip(label: Text(product.tags.color!)),
                    if (product.tags.occasion != null)
                      Chip(label: Text(product.tags.occasion!)),
                    if (product.tags.ageGroup != null)
                      Chip(label: Text(product.tags.ageGroup!)),
                  ],
                ),

                const SizedBox(height: 12),
                StockIndicator(status: product.stockStatus),

                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(product.description!),
                ],

                if (product.price != null) ...[
                  const SizedBox(height: 8),
                  Text('₹${product.price!.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],

                const SizedBox(height: 8),
                Text('Added by: ${product.uploadedBy}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
                if (product.createdAt != null)
                  Text(
                    'On: ${_formatDate(product.createdAt!)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),

                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _addToShareTray(product),
                        icon: const Icon(Icons.share),
                        label: const Text('Add to Tray'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddToCollection(product),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Collection'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Product',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Garment type (required)
          TagChip(
            label: 'Type',
            value: _garmentType,
            editable: true,
            onChanged: (v) => setState(() {
              _garmentType = v;
              _garmentTypeError = null;
            }),
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
                onChanged: (v) =>
                    setState(() => _fabric = v.isEmpty ? null : v),
                onDelete: () => setState(() => _fabric = null),
              ),
              TagChip(
                label: 'Color',
                value: _color,
                editable: true,
                deletable: _color != null,
                onChanged: (v) =>
                    setState(() => _color = v.isEmpty ? null : v),
                onDelete: () => setState(() => _color = null),
              ),
              TagChip(
                label: 'Occasion',
                value: _occasion,
                editable: true,
                deletable: _occasion != null,
                onChanged: (v) =>
                    setState(() => _occasion = v.isEmpty ? null : v),
                onDelete: () => setState(() => _occasion = null),
              ),
              TagChip(
                label: 'Age Group',
                value: _ageGroup,
                editable: true,
                deletable: _ageGroup != null,
                onChanged: (v) =>
                    setState(() => _ageGroup = v.isEmpty ? null : v),
                onDelete: () => setState(() => _ageGroup = null),
              ),
            ],
          ),

          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
                labelText: 'Category', isDense: true),
            items: _categoryOptions
                .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                        c[0].toUpperCase() + c.substring(1))))
                .toList(),
            onChanged: (v) =>
                setState(() => _category = v ?? _category),
          ),

          const SizedBox(height: 16),
          StockIndicator(
            status: _stockStatus,
            interactive: true,
            onChanged: (v) => setState(() => _stockStatus = v),
          ),

          const SizedBox(height: 16),
          TextFormField(
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
            onChanged: (_) {},
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

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving
                  ? null
                  : () => ref
                      .read(productDetailProvider(widget.productId).future)
                      .then(_saveEdit),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// Bottom sheet for adding product to a collection
class _AddToCollectionSheet extends StatelessWidget {
  final List<dynamic> collections; // List<Collection>
  final ValueChanged<String> onSelect;

  const _AddToCollectionSheet({
    required this.collections,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No collections yet. Create one from the Share Tray.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final col = collections[index];
        return ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(col.name as String),
          onTap: () => onSelect(col.id as String),
        );
      },
    );
  }
}
