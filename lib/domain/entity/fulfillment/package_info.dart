import 'package:mobile_ai_erp/domain/entity/fulfillment/package_item.dart';

class PackageInfo {
  String id;
  String orderId;
  String label;
  double? weight;
  double? length;
  double? width;
  double? height;
  List<PackageItem> items;
  String? trackingNumber;

  PackageInfo({
    required this.id,
    required this.orderId,
    required this.label,
    this.weight,
    this.length,
    this.width,
    this.height,
    List<PackageItem>? items,
    this.trackingNumber,
  }) : items = items ?? [];

  String get dimensionsDisplay {
    if (length != null && width != null && height != null) {
      return '${length}x${width}x${height} cm';
    }
    return 'N/A';
  }
}
