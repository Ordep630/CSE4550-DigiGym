import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'workout_recommendation_service.dart';

/// Provides workout recommendations for the authenticated user.
class WorkoutRecommendationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<WorkoutRecommendation?> getMyWorkoutRecommendation(
    Session session,
  ) async {
    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      return null;
    }

    final profile = await DigiGymUser.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (profile == null) {
      return null;
    }

    final recommendationService = WorkoutRecommendationService();

    return recommendationService.recommend(profile);
  }
}
