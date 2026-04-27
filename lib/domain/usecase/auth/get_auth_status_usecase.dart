import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/auth_repository.dart';

class GetAuthStatusUseCase implements UseCase<AuthStatusResponse, String> {
  final AuthRepository _authRepository;

  GetAuthStatusUseCase(this._authRepository);

  @override
  Future<AuthStatusResponse> call({required String params}) async {
    return _authRepository.getAuthStatus(params);
  }
}