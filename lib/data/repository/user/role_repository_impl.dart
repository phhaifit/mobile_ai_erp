import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDataSource remoteDataSource;

  RoleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Role>> getAll() => remoteDataSource.getRoles();

  @override
  Future<Role> getById(String id) => remoteDataSource.getRoleById(id);

  @override
  Future<Role> create(Role role) => remoteDataSource.createRole(role);

  @override
  Future<Role> update(String id, Role role) => remoteDataSource.updateRole(id, role);

  @override
  Future<void> delete(String id) => remoteDataSource.deleteRole(id);
}
