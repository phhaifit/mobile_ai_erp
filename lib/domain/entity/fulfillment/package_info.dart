import 'package:mobile_ai_erp/domain/entity/fulfillment/package_item.dart';

class PackageInfo {
  final String id;
  final String orderId;
  final String label;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final List<PackageItem> items;
  final String? trackingNumber;

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
