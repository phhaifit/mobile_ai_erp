import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';

class FulfillmentOrder {
  final String id;
  final String code;
  final String customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final String? shippingProvince;
  final String? shippingDistrict;
  final String? shippingWard;
  final String source;
  final FulfillmentStatus status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<FulfillmentItem> items;
  final List<PackageInfo> packages;
  final List<TrackingEvent> trackingEvents;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double shippingFee;
  final double totalAmount;
  final String? notes;

  FulfillmentOrder({
    required this.id,
    required this.code,
    required this.customerName,
    this.customerPhone,
    this.shippingAddress,
    this.shippingProvince,
    this.shippingDistrict,
    this.shippingWard,
    required this.source,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    List<PackageInfo>? packages,
    List<TrackingEvent>? trackingEvents,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.shippingFee = 0,
    required this.totalAmount,
    this.notes,
  })  : packages = packages ?? [],
        trackingEvents = trackingEvents ?? [];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  FulfillmentOrder copyWith({
    String? id,
    String? code,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? shippingProvince,
    String? shippingDistrict,
    String? shippingWard,
    String? source,
    FulfillmentStatus? status,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FulfillmentItem>? items,
    List<PackageInfo>? packages,
    List<TrackingEvent>? trackingEvents,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? shippingFee,
    double? totalAmount,
    String? notes,
  }) {
    return FulfillmentOrder(
      id: id ?? this.id,
      code: code ?? this.code,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingProvince: shippingProvince ?? this.shippingProvince,
      shippingDistrict: shippingDistrict ?? this.shippingDistrict,
      shippingWard: shippingWard ?? this.shippingWard,
      source: source ?? this.source,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      packages: packages ?? this.packages,
      trackingEvents: trackingEvents ?? this.trackingEvents,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
    );
  }
}
