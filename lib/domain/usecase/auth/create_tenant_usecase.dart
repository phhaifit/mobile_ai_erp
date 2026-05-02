import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/auth_repository.dart';

class CreateTenantParams {
  final String name;
  final String subdomain;

  CreateTenantParams({required this.name, required this.subdomain});
}

class CreateTenantUseCase implements UseCase<Map<String, dynamic>, CreateTenantParams> {
  final AuthRepository _authRepository;

  CreateTenantUseCase(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({required CreateTenantParams params}) async {
    return _authRepository.createTenant(params.name, params.subdomain);
  }
}