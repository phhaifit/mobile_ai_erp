import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<List<User>> execute() async {
    return await _repository.getAll();
  }
}
