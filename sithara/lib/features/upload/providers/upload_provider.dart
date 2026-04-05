import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_state.dart';

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() => const UploadState();

  void setSelectedFiles(List<String> paths) {
    state = state.copyWith(selectedFilePaths: paths);
  }

  void setUploadedFileIds(List<String> ids) {
    state = state.copyWith(
      uploadedFileIds: ids,
      primaryFileId: ids.isNotEmpty ? ids.first : '',
    );
  }

  void setBgRemovalStatus(String status, {String? newFileId}) {
    state = state.copyWith(
      bgRemovalStatus: status,
      bgRemovedFileId: newFileId,
    );
  }

  void setTagDraft(Map<String, dynamic> tags) {
    state = state.copyWith(tagDraft: tags);
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);
