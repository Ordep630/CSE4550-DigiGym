import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  Future<User> createUser(Session session, User user) async {
    return await User.db.insertRow(session, user);
  }

  Future<User?> getUser(Session session, int id) async {
    return await User.db.findById(session, id);
  }

  Future<User> updateUser(Session session, User user) async {
    return await User.db.updateRow(session, user);
  }
}