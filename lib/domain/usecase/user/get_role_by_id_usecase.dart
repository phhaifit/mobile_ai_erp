import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class GetRoleByIdUseCase {
  final RoleRepository roleRepository;

  GetRoleByIdUseCase(this.roleRepository);

  Future<Role> execute(String id) async {
    return await roleRepository.getById(id);
  }
}
