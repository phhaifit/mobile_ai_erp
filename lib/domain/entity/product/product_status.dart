import 'package:mobile_ai_erp/constants/strings.dart';

enum ProductStatus {
  NEW,
  ACTIVE,
  OUT_OF_STOCK,
  DISCONTINUED,
}

extension ProductStatusExtension on ProductStatus {
  String get displayName {
    switch (this) {
      case ProductStatus.NEW:
        return ProductStrings.statusNew;
      case ProductStatus.ACTIVE:
        return ProductStrings.statusActive;
      case ProductStatus.OUT_OF_STOCK:
        return ProductStrings.statusOutOfStock;
      case ProductStatus.DISCONTINUED:
        return ProductStrings.statusDiscontinued;
    }
  }

  int get value {
    switch (this) {
      case ProductStatus.NEW:
        return 1;
      case ProductStatus.ACTIVE:
        return 2;
      case ProductStatus.OUT_OF_STOCK:
        return 3;
      case ProductStatus.DISCONTINUED:
        return 4;
    }
  }
}

ProductStatus productStatusFromValue(int value) {
  switch (value) {
    case 1:
      return ProductStatus.NEW;
    case 2:
      return ProductStatus.ACTIVE;
    case 3:
      return ProductStatus.OUT_OF_STOCK;
    case 4:
      return ProductStatus.DISCONTINUED;
    default:
      return ProductStatus.ACTIVE;
  }
}
