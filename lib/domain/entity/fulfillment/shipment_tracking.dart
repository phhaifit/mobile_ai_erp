class ShipmentTrackingEvent {
  final String id;
  final String status;
  final String? description;
  final String? location;
  final DateTime eventTime;

  ShipmentTrackingEvent({
    required this.id,
    required this.status,
    this.description,
    this.location,
    required this.eventTime,
  });
}

class ShipmentTrackingInfo {
  final String id;
  final String orderId;
  final String provider;
  final String trackingCode;
  final String status;
  final String? rawStatus;
  final String? latestNote;
  final DateTime? estimatedDelivery;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShipmentTrackingEvent> events;

  ShipmentTrackingInfo({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.trackingCode,
    required this.status,
    this.rawStatus,
    this.latestNote,
    this.estimatedDelivery,
    this.syncedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.events,
  });
}
