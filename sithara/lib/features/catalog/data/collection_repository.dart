import 'package:appwrite/appwrite.dart';
import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/appwrite/constants.dart';
import '../models/collection.dart';

class CollectionRepository {
  Future<List<Collection>> getCollections() async {
    final result = await appwriteDatabases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionsCollectionId,
    );
    return result.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id;
      data['\$createdAt'] = doc.$createdAt;
      return Collection.fromJson(data);
    }).toList();
  }

  Future<Collection> createCollection(String name, String createdBy, {String? description}) async {
    final doc = await appwriteDatabases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionsCollectionId,
      documentId: ID.unique(),
      data: {
        'name': name,
        if (description != null) 'description': description,
        'product_ids': [],
        'created_by': createdBy,
      },
    );
    final data = Map<String, dynamic>.from(doc.data);
    data['\$id'] = doc.$id;
    data['\$createdAt'] = doc.$createdAt;
    return Collection.fromJson(data);
  }

  Future<Collection> addProductToCollection(String collectionId, String productId) async {
    final existing = await appwriteDatabases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionsCollectionId,
      documentId: collectionId,
    );
    final currentIds = List<String>.from(existing.data['product_ids'] as List? ?? []);
    if (!currentIds.contains(productId)) {
      currentIds.add(productId);
    }
    final doc = await appwriteDatabases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionsCollectionId,
      documentId: collectionId,
      data: {'product_ids': currentIds},
    );
    final data = Map<String, dynamic>.from(doc.data);
    data['\$id'] = doc.$id;
    data['\$createdAt'] = doc.$createdAt;
    return Collection.fromJson(data);
  }
}
