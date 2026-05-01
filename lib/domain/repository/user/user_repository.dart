import 'dart:async';

import '../../entity/user/user.dart';

// =============================
// REPOSITORIES (ASYNC)
// =============================

abstract class UserRepository {
  Future<List<User>> getAll();
  Future<User> getById(String id);
  Future<User> create(User user);
  Future<User> update(String id, User user);
  Future<void> delete(String id);
}
