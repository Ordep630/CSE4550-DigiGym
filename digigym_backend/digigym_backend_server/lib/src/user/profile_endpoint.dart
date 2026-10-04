import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';

/// Lets the currently logged-in user fetch their own DigiGym fitness profile.
class ProfileEndpoint extends Endpoint {
  /// Every method on this endpoint requires the caller to be logged in.
  @override
  bool get requireLogin => true;

  /// Returns the DigiGymUser profile for whoever is currently authenticated.
  Future<DigiGymUser?> getMyProfile(Session session) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      return null;
    }
    return await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
  }
}
