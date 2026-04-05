import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../../core/appwrite/appwrite_client.dart';

/// Holds the parsed parameters from an Appwrite invite deep link.
/// Appwrite invite URLs carry userId, secret, membershipId, and teamId
/// as query parameters. The router encodes them as a single base64 token
/// so they can be passed cleanly via path parameters.
class InviteParams {
  final String teamId;
  final String membershipId;
  final String userId;
  final String secret;

  const InviteParams({
    required this.teamId,
    required this.membershipId,
    required this.userId,
    required this.secret,
  });

  /// Decode a base64url-encoded JSON token produced by [encode].
  factory InviteParams.decode(String token) {
    final json = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(token))),
    ) as Map<String, dynamic>;
    return InviteParams(
      teamId: json['teamId'] as String,
      membershipId: json['membershipId'] as String,
      userId: json['userId'] as String,
      secret: json['secret'] as String,
    );
  }

  /// Encode the params to a base64url-encoded JSON token for use in deep links.
  String encode() => base64Url.encode(
        utf8.encode(jsonEncode({
          'teamId': teamId,
          'membershipId': membershipId,
          'userId': userId,
          'secret': secret,
        })),
      );
}

final _appwriteTeams = Teams(appwriteClient);

class AuthRepository {
  Future<models.User> login(String email, String password) async {
    await appwriteAccount.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return await appwriteAccount.get();
  }

  Future<void> logout() async {
    await appwriteAccount.deleteSession(sessionId: 'current');
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await appwriteAccount.get();
    } on AppwriteException {
      return null;
    }
  }

  /// Accept a team membership invite and set the user's initial password.
  ///
  /// [token] is a base64url-encoded JSON string containing teamId, membershipId,
  /// userId, and secret — all provided by Appwrite's invite deep link URL.
  Future<models.User> acceptInvite(String token, String password) async {
    final params = InviteParams.decode(token);

    // Accept the team membership — this also creates a session for the user.
    await _appwriteTeams.updateMembershipStatus(
      teamId: params.teamId,
      membershipId: params.membershipId,
      userId: params.userId,
      secret: params.secret,
    );

    // Set the initial password (oldPassword is optional for invite-created accounts).
    await appwriteAccount.updatePassword(password: password);

    return await appwriteAccount.get();
  }
}
