import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class UpdateRoleUseCase {
  final RoleRepository roleRepository;

  UpdateRoleUseCase(this.roleRepository);

  Future<Role> execute(String id, Role role) async {
    return await roleRepository.update(id, role);
  }
}
