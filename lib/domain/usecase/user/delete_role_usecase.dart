import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class DeleteRoleUseCase {
  final RoleRepository roleRepository;

  DeleteRoleUseCase(this.roleRepository);

  Future<void> execute(String id) async {
    await roleRepository.delete(id);
  }
}
