import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<void> execute(String id) async {
    await _repository.delete(id);
  }
}
