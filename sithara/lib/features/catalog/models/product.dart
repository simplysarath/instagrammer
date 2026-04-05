import 'product_tags.dart';

class Product {
  final String id;
  final String? description;
  final List<String> imageIds;
  final String primaryImageId;
  final String? videoId;
  final ProductTags tags;
  final double? price;
  final String stockStatus; // "in" | "out"
  final String bgRemovalStatus; // "none" | "pending" | "done"
  final String category; // "sarees" | "salwars" | "modern" | "kids"
  final String uploadedBy;
  final DateTime? createdAt;
  // Denormalized field for full-text search
  final String? searchText;

  const Product({
    required this.id,
    this.description,
    required this.imageIds,
    required this.primaryImageId,
    this.videoId,
    required this.tags,
    this.price,
    this.stockStatus = 'in',
    this.bgRemovalStatus = 'none',
    required this.category,
    required this.uploadedBy,
    this.createdAt,
    this.searchText,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['\$id'] as String? ?? json['id'] as String? ?? '',
      description: json['description'] as String?,
      imageIds: List<String>.from(json['image_ids'] as List? ?? []),
      primaryImageId: json['primary_image_id'] as String? ?? '',
      videoId: json['video_id'] as String?,
      tags: ProductTags.fromJson(json['tags'] as Map<String, dynamic>? ?? {}),
      price: (json['price'] as num?)?.toDouble(),
      stockStatus: json['stock_status'] as String? ?? 'in',
      bgRemovalStatus: json['bg_removal_status'] as String? ?? 'none',
      category: json['category'] as String? ?? '',
      uploadedBy: json['uploaded_by'] as String? ?? '',
      createdAt: json['\$createdAt'] != null
          ? DateTime.tryParse(json['\$createdAt'] as String)
          : null,
      searchText: json['search_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (description != null) 'description': description,
      'image_ids': imageIds,
      'primary_image_id': primaryImageId,
      if (videoId != null) 'video_id': videoId,
      'tags': tags.toJson(),
      if (price != null) 'price': price,
      'stock_status': stockStatus,
      'bg_removal_status': bgRemovalStatus,
      'category': category,
      'uploaded_by': uploadedBy,
      if (searchText != null) 'search_text': searchText,
    };
  }

  Product copyWith({
    String? id,
    String? description,
    List<String>? imageIds,
    String? primaryImageId,
    String? videoId,
    ProductTags? tags,
    double? price,
    String? stockStatus,
    String? bgRemovalStatus,
    String? category,
    String? uploadedBy,
    DateTime? createdAt,
    String? searchText,
  }) {
    return Product(
      id: id ?? this.id,
      description: description ?? this.description,
      imageIds: imageIds ?? this.imageIds,
      primaryImageId: primaryImageId ?? this.primaryImageId,
      videoId: videoId ?? this.videoId,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      stockStatus: stockStatus ?? this.stockStatus,
      bgRemovalStatus: bgRemovalStatus ?? this.bgRemovalStatus,
      category: category ?? this.category,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      searchText: searchText ?? this.searchText,
    );
  }
}
