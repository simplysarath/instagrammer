import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/appwrite/constants.dart';
import '../../catalog/models/product_tags.dart';

class XimilarService {
  Future<ProductTags> tagProduct(String fileId) async {
    try {
      final result = await appwriteFunctions.createExecution(
        functionId: AppwriteConstants.tagProductFunctionId,
        body: jsonEncode({'file_id': fileId}),
        method: ExecutionMethod.pOST,
      );

      if (result.responseStatusCode != 200) {
        return const ProductTags(garmentType: '');
      }

      final responseBody = jsonDecode(result.responseBody) as Map<String, dynamic>;

      if (responseBody.containsKey('error')) {
        return const ProductTags(garmentType: '');
      }

      return ProductTags(
        garmentType: responseBody['garment_type'] as String? ?? '',
        fabric: responseBody['fabric'] as String?,
        color: responseBody['color'] as String?,
        occasion: responseBody['occasion'] as String?,
        ageGroup: responseBody['age_group'] as String?,
      );
    } on AppwriteException {
      return const ProductTags(garmentType: '');
    }
  }
}
