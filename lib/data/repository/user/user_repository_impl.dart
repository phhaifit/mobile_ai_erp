import 'dart:async';

import 'package:mobile_ai_erp/data/local/datasources/user/user_datasource.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

import '../../../domain/entity/user/user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<List<User>> getAll() => dataSource.getUsers();

  @override
  Future<void> create(User user) => dataSource.addUser(user);

  @override
  Future<void> update(User user) => dataSource.updateUser(user);

  @override
  Future<void> delete(String id) => dataSource.deleteUser(id);
}
