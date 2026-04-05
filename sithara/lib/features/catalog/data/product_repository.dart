import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/appwrite/constants.dart';
import '../models/product.dart';

class ProductRepository {
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final result = await appwriteDatabases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      queries: [Query.equal('category', categoryId)],
    );
    return result.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id;
      data['\$createdAt'] = doc.$createdAt;
      // Tags are stored as JSON string in Appwrite
      if (data['tags'] is String) {
        data['tags'] = jsonDecode(data['tags'] as String);
      }
      return Product.fromJson(data);
    }).toList();
  }

  Future<Product> createProduct(Product product) async {
    final data = product.toJson();
    // Encode tags as JSON string for Appwrite storage
    data['tags'] = jsonEncode(data['tags']);
    final doc = await appwriteDatabases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: ID.unique(),
      data: data,
    );
    final resultData = Map<String, dynamic>.from(doc.data);
    resultData['\$id'] = doc.$id;
    resultData['\$createdAt'] = doc.$createdAt;
    if (resultData['tags'] is String) {
      resultData['tags'] = jsonDecode(resultData['tags'] as String);
    }
    return Product.fromJson(resultData);
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> updates) async {
    if (updates.containsKey('tags')) {
      updates['tags'] = jsonEncode(updates['tags']);
    }
    final doc = await appwriteDatabases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: productId,
      data: updates,
    );
    final data = Map<String, dynamic>.from(doc.data);
    data['\$id'] = doc.$id;
    data['\$createdAt'] = doc.$createdAt;
    if (data['tags'] is String) {
      data['tags'] = jsonDecode(data['tags'] as String);
    }
    return Product.fromJson(data);
  }

  Future<Product> getProduct(String productId) async {
    final doc = await appwriteDatabases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: productId,
    );
    final data = Map<String, dynamic>.from(doc.data);
    data['\$id'] = doc.$id;
    data['\$createdAt'] = doc.$createdAt;
    if (data['tags'] is String) {
      data['tags'] = jsonDecode(data['tags'] as String);
    }
    return Product.fromJson(data);
  }

  Future<List<Product>> searchProducts(String query, {String? categoryId}) async {
    final queries = <String>[
      Query.search('search_text', query),
    ];
    if (categoryId != null) {
      queries.add(Query.equal('category', categoryId));
    }
    final result = await appwriteDatabases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      queries: queries,
    );
    return result.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id;
      data['\$createdAt'] = doc.$createdAt;
      if (data['tags'] is String) {
        data['tags'] = jsonDecode(data['tags'] as String);
      }
      return Product.fromJson(data);
    }).toList();
  }
}
