import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';

class CustomerLoginParams {
  final String email;
  final String password;

  CustomerLoginParams({required this.email, required this.password});
}

class CustomerLoginUseCase implements UseCase<Map<String, dynamic>, CustomerLoginParams> {
  final AccountCustomerRepository _customerRepository;

  CustomerLoginUseCase(this._customerRepository);

  @override
  Future<Map<String, dynamic>> call({required CustomerLoginParams params}) {
    return _customerRepository.login(params.email, params.password);
  }
}