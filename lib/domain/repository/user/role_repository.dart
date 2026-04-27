import 'package:mobile_ai_erp/domain/entity/user/role.dart';

abstract class RoleRepository {
  Future<List<Role>> getAll();
  Future<void> create(Role role);
  Future<void> update(Role role);
  Future<void> delete(String id);
}
