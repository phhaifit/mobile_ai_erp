import '../../../core/domain/usecase/use_case.dart';
import '../../entity/storefront_customer/storefront_customer.dart';
import '../../repository/storefront_account/customer_repository.dart';

class UpdateProfileUseCase extends UseCase<StorefrontCustomer, Map<String, dynamic>> {
  final AccountCustomerRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<StorefrontCustomer> call({required Map<String, dynamic> params}) {
    return _repository.updateProfile(params);
  }
}