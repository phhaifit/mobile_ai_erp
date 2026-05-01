import 'dart:async';

import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

import '../../../domain/entity/user/user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<User>> getAll() => remoteDataSource.getUsers();

  @override
  Future<User> getById(String id) => remoteDataSource.getUserById(id);

  @override
  Future<User> create(User user) => remoteDataSource.createUser(user);

  @override
  Future<User> update(String id, User user) => remoteDataSource.updateUser(id, user);

  @override
  Future<void> delete(String id) => remoteDataSource.deleteUser(id);
}
