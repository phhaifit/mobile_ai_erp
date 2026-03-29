import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Use case for validating an address
class ValidateAddressUseCase extends UseCase<DeliveryAddress, DeliveryAddress> {
  ValidateAddressUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<DeliveryAddress> call({required DeliveryAddress params}) {
    return _repository.validateAddress(params);
  }
}

/// Use case for parsing a raw address string
class ParseAddressUseCase extends UseCase<DeliveryAddress?, String> {
  ParseAddressUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<DeliveryAddress?> call({required String params}) {
    return _repository.parseAddress(params);
  }
}

/// Use case for creating a checkout order
class CreateCheckoutOrderUseCase extends UseCase<CheckoutOrder, CheckoutOrder> {
  CreateCheckoutOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<CheckoutOrder> call({required CheckoutOrder params}) {
    return _repository.createOrder(params);
  }
}

/// Use case for getting an order by ID
class GetCheckoutOrderUseCase extends UseCase<CheckoutOrder?, String> {
  GetCheckoutOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<CheckoutOrder?> call({required String params}) {
    return _repository.getOrderById(params);
  }
}

/// Use case for updating a checkout order
class UpdateCheckoutOrderUseCase extends UseCase<CheckoutOrder, CheckoutOrder> {
  UpdateCheckoutOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<CheckoutOrder> call({required CheckoutOrder params}) {
    return _repository.updateOrder(params);
  }
}

/// Use case for confirming an order
class ConfirmOrderUseCase extends UseCase<CheckoutOrder, String> {
  ConfirmOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<CheckoutOrder> call({required String params}) {
    return _repository.confirmOrder(params);
  }
}

/// Use case for getting saved addresses
class GetSavedAddressesUseCase extends UseCase<List<DeliveryAddress>, String?> {
  GetSavedAddressesUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<List<DeliveryAddress>> call({required String? params}) {
    return _repository.getSavedAddresses(params);
  }
}

/// Use case for saving an address
class SaveAddressUseCase extends UseCase<DeliveryAddress, DeliveryAddress> {
  SaveAddressUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<DeliveryAddress> call({required DeliveryAddress params}) {
    return _repository.saveAddress(params);
  }
}

/// Use case for deleting an address
class DeleteAddressUseCase extends UseCase<void, String> {
  DeleteAddressUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<void> call({required String params}) {
    return _repository.deleteAddress(params);
  }
}
