import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';

class CustomerForgotPasswordParams {
  final String email;

  CustomerForgotPasswordParams({required this.email});
}

class CustomerForgotPasswordUseCase implements UseCase<void, CustomerForgotPasswordParams> {
  final AccountCustomerRepository _customerRepository;

  CustomerForgotPasswordUseCase(this._customerRepository);

  @override
  Future<void> call({required CustomerForgotPasswordParams params}) {
    return _customerRepository.forgotPassword(params.email);
  }
}