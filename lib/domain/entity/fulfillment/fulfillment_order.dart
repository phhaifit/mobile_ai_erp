import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';

class FulfillmentOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final String channel;
  FulfillmentStatus status;
  final DateTime createdAt;
  DateTime? updatedAt;
  final List<FulfillmentItem> items;
  final List<PackageInfo> packages;
  final List<TrackingEvent> trackingEvents;
  final double totalAmount;
  String? notes;

  FulfillmentOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.channel,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    List<PackageInfo>? packages,
    List<TrackingEvent>? trackingEvents,
    required this.totalAmount,
    this.notes,
  })  : packages = packages ?? [],
        trackingEvents = trackingEvents ?? [];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isFullyPicked => items.every((item) => item.isFullyPicked);
  bool get isFullyPacked => items.every((item) => item.isFullyPacked);
}
