import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/auth_repository.dart';

class RefreshTokenUseCase implements UseCase<Map<String, String>, String> {
  final AuthRepository _authRepository;

  RefreshTokenUseCase(this._authRepository);

  @override
  Future<Map<String, String>> call({required String params}) async {
    return _authRepository.refreshToken(params);
  }
}