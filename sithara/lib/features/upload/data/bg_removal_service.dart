import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/appwrite/constants.dart';

class BgRemovalService {
  /// Returns the new file ID if successful, null on failure.
  Future<String?> removeBackground(String fileId) async {
    try {
      final result = await appwriteFunctions.createExecution(
        functionId: AppwriteConstants.removeBackgroundFunctionId,
        body: jsonEncode({'file_id': fileId}),
        method: ExecutionMethod.pOST,
      );

      if (result.responseStatusCode != 200) {
        return null;
      }

      final responseBody = jsonDecode(result.responseBody) as Map<String, dynamic>;

      if (responseBody.containsKey('error')) {
        return null;
      }

      return responseBody['new_file_id'] as String?;
    } on AppwriteException {
      return null;
    }
  }
}
