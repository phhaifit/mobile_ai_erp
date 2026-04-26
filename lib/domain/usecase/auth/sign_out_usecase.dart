import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/auth_repository.dart';

class SignOutParams {
  final String accessToken;
  final String tenantId;

  SignOutParams({required this.accessToken, required this.tenantId});
}

class SignOutUseCase implements UseCase<void, SignOutParams> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<void> call({required SignOutParams params}) async {
    return _authRepository.signOut(params.accessToken, params.tenantId);
  }
}