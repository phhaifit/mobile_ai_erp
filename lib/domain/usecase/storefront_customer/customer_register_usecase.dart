import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';

class CustomerRegisterParams {
  final String name;
  final String email;
  final String password;

  CustomerRegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class CustomerRegisterUseCase implements UseCase<Map<String, dynamic>, CustomerRegisterParams> {
  final AccountCustomerRepository _customerRepository;

  CustomerRegisterUseCase(this._customerRepository);

  @override
  Future<Map<String, dynamic>> call({required CustomerRegisterParams params}) {
    return _customerRepository.register(
      params.name,
      params.email,
      params.password,
    );
  }
}