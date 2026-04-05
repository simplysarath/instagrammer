class UploadState {
  final List<String> selectedFilePaths; // local file paths from image_picker
  final List<String> uploadedFileIds;   // Appwrite Storage file IDs after upload
  final String primaryFileId;           // which file is the catalog thumbnail
  final String bgRemovalStatus;         // "none" | "pending" | "done"
  final String? bgRemovedFileId;        // new file ID after bg removal
  final Map<String, dynamic>? tagDraft; // draft tags from Ximilar (step 6)

  const UploadState({
    this.selectedFilePaths = const [],
    this.uploadedFileIds = const [],
    this.primaryFileId = '',
    this.bgRemovalStatus = 'none',
    this.bgRemovedFileId,
    this.tagDraft,
  });

  UploadState copyWith({
    List<String>? selectedFilePaths,
    List<String>? uploadedFileIds,
    String? primaryFileId,
    String? bgRemovalStatus,
    String? bgRemovedFileId,
    Map<String, dynamic>? tagDraft,
  }) {
    return UploadState(
      selectedFilePaths: selectedFilePaths ?? this.selectedFilePaths,
      uploadedFileIds: uploadedFileIds ?? this.uploadedFileIds,
      primaryFileId: primaryFileId ?? this.primaryFileId,
      bgRemovalStatus: bgRemovalStatus ?? this.bgRemovalStatus,
      bgRemovedFileId: bgRemovedFileId ?? this.bgRemovedFileId,
      tagDraft: tagDraft ?? this.tagDraft,
    );
  }

  UploadState reset() {
    return const UploadState();
  }
}
