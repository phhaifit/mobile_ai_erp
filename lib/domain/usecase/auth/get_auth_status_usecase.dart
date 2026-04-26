import '../../../core/domain/usecase/use_case.dart';
import '../../entity/user/user.dart';
import '../../repository/user/auth_repository.dart';

class GetAuthStatusUseCase implements UseCase<User, String> {
  final AuthRepository _authRepository;

  GetAuthStatusUseCase(this._authRepository);

  @override
  Future<User> call({required String params}) async {
    return _authRepository.getAuthStatus(params);
  }
}