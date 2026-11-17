import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'meal_recommendation_service.dart';


class MealRecommendationEndpoint extends Endpoint {    /// Provides meal recommendations for the authenticated user
  @override
  bool get requireLogin => true;

  Future<MealRecommendation?> getMyMealRecommendation(
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

    return MealRecommendationService().recommend(profile);
  }
  
  Future<List<MealOption>> getMyMealOptions(Session session) async {
  final authUserId = session.authenticated?.authUserId;

  if (authUserId == null) {
    return [];
  }

  final profile = await DigiGymUser.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(authUserId),
  );

  if (profile == null) {
    return [];
  }

  return MealRecommendationService().recommendOptions(profile);
}
}
