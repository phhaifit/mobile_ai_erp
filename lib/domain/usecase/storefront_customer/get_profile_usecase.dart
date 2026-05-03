import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_customer/storefront_customer.dart';
import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';

class GetProfileUseCase implements UseCase<StorefrontCustomer, void> {
  final AccountCustomerRepository _customerRepository;

  GetProfileUseCase(this._customerRepository);

  @override
  Future<StorefrontCustomer> call({dynamic params}) {
    // Get the current user's profile using the unified endpoint
    // The repository datasource will retrieve the customer ID from SharedPreferences
    return _customerRepository.getProfile();
  }
}