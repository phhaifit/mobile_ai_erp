import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';

class TrackingEvent {
  final String id;
  final FulfillmentStatus? oldStatus;
  final FulfillmentStatus newStatus;
  final String? note;
  final DateTime changedAt;
  final String? changedByName;

  TrackingEvent({
    required this.id,
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.changedAt,
    this.changedByName,
  });
}
