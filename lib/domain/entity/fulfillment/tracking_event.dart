import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';

class TrackingEvent {
  final String id;
  final FulfillmentStatus status;
  final String description;
  final DateTime timestamp;
  final String? location;
  final String? updatedBy;

  TrackingEvent({
    required this.id,
    required this.status,
    required this.description,
    required this.timestamp,
    this.location,
    this.updatedBy,
  });
}
