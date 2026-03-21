import 'package:mobile_ai_erp/data/local/datasources/user/role_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleDataSource dataSource;

  RoleRepositoryImpl(this.dataSource);

  @override
  Future<List<Role>> getAll() => dataSource.getRoles();

  @override
  Future<void> create(Role role) => dataSource.addRole(role);

  @override
  Future<void> update(Role role) => dataSource.updateRole(role);

  @override
  Future<void> delete(int id) => dataSource.deleteRole(id);
}
