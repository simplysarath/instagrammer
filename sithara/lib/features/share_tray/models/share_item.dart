class ShareItem {
  final String productId;
  final String imageFileId; // selected image for this tray item
  final String description; // editable one-line description for share

  const ShareItem({
    required this.productId,
    required this.imageFileId,
    this.description = '',
  });

  ShareItem copyWith({
    String? productId,
    String? imageFileId,
    String? description,
  }) {
    return ShareItem(
      productId: productId ?? this.productId,
      imageFileId: imageFileId ?? this.imageFileId,
      description: description ?? this.description,
    );
  }
}
