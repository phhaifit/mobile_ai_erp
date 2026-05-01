import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository _repository;

  GetUserByIdUseCase(this._repository);

  Future<User> execute(String id) async {
    return await _repository.getById(id);
  }
}
