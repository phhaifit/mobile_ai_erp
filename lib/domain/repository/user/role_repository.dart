import 'package:mobile_ai_erp/domain/entity/user/role.dart';

abstract class RoleRepository {
  Future<List<Role>> getAll();
  Future<Role> getById(String id);
  Future<Role> create(Role role);
  Future<Role> update(String id, Role role);
  Future<void> delete(String id);
}
