class ProductTags {
  final String garmentType;
  final String? fabric;
  final String? color;
  final String? occasion;
  final String? ageGroup;

  const ProductTags({
    required this.garmentType,
    this.fabric,
    this.color,
    this.occasion,
    this.ageGroup,
  });

  factory ProductTags.fromJson(Map<String, dynamic> json) {
    return ProductTags(
      garmentType: json['garment_type'] as String? ?? '',
      fabric: json['fabric'] as String?,
      color: json['color'] as String?,
      occasion: json['occasion'] as String?,
      ageGroup: json['age_group'] as String?,
    );
  }

  /// Maps Ximilar Fashion Tagging API response to ProductTags.
  /// Ximilar field → ProductTags field:
  ///   category.name → garment_type
  ///   fabric.name → fabric
  ///   dominant_color.name → color
  ///   occasions[0].name → occasion
  ///   age_group.name → age_group
  factory ProductTags.fromXimilarResponse(Map<String, dynamic> ximilar) {
    final records = ximilar['records'] as List<dynamic>?;
    final record = records?.isNotEmpty == true ? records!.first as Map<String, dynamic> : <String, dynamic>{};

    String? extractName(dynamic field) {
      if (field is Map) return field['name'] as String?;
      if (field is List && field.isNotEmpty) {
        final first = field.first;
        if (first is Map) return first['name'] as String?;
      }
      return null;
    }

    return ProductTags(
      garmentType: extractName(record['category']) ?? '',
      fabric: extractName(record['fabric']),
      color: extractName(record['dominant_color']),
      occasion: extractName(record['occasions']),
      ageGroup: extractName(record['age_group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'garment_type': garmentType,
      if (fabric != null) 'fabric': fabric,
      if (color != null) 'color': color,
      if (occasion != null) 'occasion': occasion,
      if (ageGroup != null) 'age_group': ageGroup,
    };
  }

  ProductTags copyWith({
    String? garmentType,
    String? fabric,
    String? color,
    String? occasion,
    String? ageGroup,
  }) {
    return ProductTags(
      garmentType: garmentType ?? this.garmentType,
      fabric: fabric ?? this.fabric,
      color: color ?? this.color,
      occasion: occasion ?? this.occasion,
      ageGroup: ageGroup ?? this.ageGroup,
    );
  }
}
