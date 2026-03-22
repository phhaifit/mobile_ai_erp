import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class UpdatePackageParams {
  final String orderId;
  final PackageInfo package;

  UpdatePackageParams({
    required this.orderId,
    required this.package,
  });
}

class UpdatePackageUseCase extends UseCase<void, UpdatePackageParams> {
  final FulfillmentRepository _repository;

  UpdatePackageUseCase(this._repository);

  @override
  Future<void> call({required UpdatePackageParams params}) {
    return _repository.updatePackage(params.orderId, params.package);
  }
}
