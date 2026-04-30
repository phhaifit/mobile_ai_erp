import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';

class GetAllRolesUseCase {
  final RoleRepository roleRepository;

  GetAllRolesUseCase(this.roleRepository);

  Future<List<Role>> execute() async {
    return await roleRepository.getAll();
  }
}
