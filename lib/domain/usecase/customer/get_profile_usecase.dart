import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';

class GetProfileUseCase implements UseCase<Map<String, dynamic>, void> {
  final AccountCustomerRepository _customerRepository;

  GetProfileUseCase(this._customerRepository);

  @override
  Future<Map<String, dynamic>> call({dynamic params}) {
    return _customerRepository.getLoyaltyPoints();
  }
}