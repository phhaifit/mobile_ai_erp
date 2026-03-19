import 'dart:async';

import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;
}
