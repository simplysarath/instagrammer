class Collection {
  final String id;
  final String name;
  final String? description;
  final List<String> productIds;
  final String createdBy;
  final DateTime? createdAt;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.productIds,
    required this.createdBy,
    this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['\$id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      productIds: List<String>.from(json['product_ids'] as List? ?? []),
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['\$createdAt'] != null
          ? DateTime.tryParse(json['\$createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'product_ids': productIds,
      'created_by': createdBy,
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? productIds,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productIds: productIds ?? this.productIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
