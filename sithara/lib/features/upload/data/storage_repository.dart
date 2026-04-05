import 'package:appwrite/appwrite.dart';
import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/appwrite/constants.dart';

class StorageRepository {
  /// Upload a file to the product-images bucket.
  /// Returns the Appwrite file ID.
  Future<String> uploadProductImage(String filePath) async {
    final file = await appwriteStorage.createFile(
      bucketId: AppwriteConstants.productImagesBucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: filePath),
    );
    return file.$id;
  }

  /// Upload multiple files. Returns list of file IDs in the same order.
  Future<List<String>> uploadProductImages(List<String> filePaths) async {
    final ids = <String>[];
    for (final path in filePaths) {
      final id = await uploadProductImage(path);
      ids.add(id);
    }
    return ids;
  }

  /// Get a file view URL for displaying images.
  String getFileViewUrl(String fileId) {
    final endpoint = appwriteClient.endPoint;
    final projectId = appwriteClient.config['project'] ?? '';
    return '$endpoint/storage/buckets/${AppwriteConstants.productImagesBucketId}/files/$fileId/view?project=$projectId';
  }

  /// Download a file as bytes (used by Appwrite Functions and share).
  Future<List<int>> downloadFile(String fileId) async {
    final bytes = await appwriteStorage.getFileDownload(
      bucketId: AppwriteConstants.productImagesBucketId,
      fileId: fileId,
    );
    return bytes;
  }
}
