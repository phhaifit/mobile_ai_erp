import 'dart:async';

import '../../entity/user/user.dart';

// =============================
// REPOSITORIES (ASYNC)
// =============================

abstract class UserRepository {
  Future<List<User>> getAll();
  Future<void> create(User user);
  Future<void> update(User user);
  Future<void> delete(String id);
}
