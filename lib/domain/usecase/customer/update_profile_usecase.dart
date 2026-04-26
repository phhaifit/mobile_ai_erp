import '../../../core/domain/usecase/use_case.dart';
import '../../entity/customer/customer.dart';
import '../../repository/account/customer_repository.dart';

class UpdateProfileUseCase extends UseCase<Customer, Map<String, dynamic>> {
  final AccountCustomerRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Customer> call({required Map<String, dynamic> params}) {
    return _repository.updateProfile(params);
  }
}