import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

class AssignRoleToUserUseCase {
  final UserRepository userRepository;

  AssignRoleToUserUseCase(this.userRepository);

  Future<void> execute({
    required User user,
    required String roleId,
  }) async {
    final updatedUser = user.copyWith(roleId: roleId);
    await userRepository.update(user.id, updatedUser);
  }
}
