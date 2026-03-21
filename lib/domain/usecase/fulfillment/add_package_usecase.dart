import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class AddPackageParams {
  final String orderId;
  final PackageInfo package;

  AddPackageParams({
    required this.orderId,
    required this.package,
  });
}

class AddPackageUseCase extends UseCase<void, AddPackageParams> {
  final FulfillmentRepository _repository;

  AddPackageUseCase(this._repository);

  @override
  Future<void> call({required AddPackageParams params}) {
    return _repository.addPackage(params.orderId, params.package);
  }
}
