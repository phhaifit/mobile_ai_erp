import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class CreateRoleUseCase {
  final RoleRepository roleRepository;

  CreateRoleUseCase(this.roleRepository);

  Future<void> execute(Role role) async {
    await roleRepository.create(role);
  }
}
