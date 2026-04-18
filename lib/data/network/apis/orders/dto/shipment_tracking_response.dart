class ShipmentTrackingEventDto {
  final String id;
  final String status;
  final String? description;
  final String? location;
  final String eventTime;

  ShipmentTrackingEventDto({
    required this.id,
    required this.status,
    this.description,
    this.location,
    required this.eventTime,
  });

  factory ShipmentTrackingEventDto.fromJson(Map<String, dynamic> json) {
    return ShipmentTrackingEventDto(
      id: json['id'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      eventTime: json['eventTime'] as String,
    );
  }
}

class ShipmentTrackingResponseDto {
  final String id;
  final String orderId;
  final String provider;
  final String trackingCode;
  final String status;
  final String? rawStatus;
  final String? latestNote;
  final String? estimatedDelivery;
  final String? syncedAt;
  final String createdAt;
  final String updatedAt;
  final List<ShipmentTrackingEventDto> events;

  ShipmentTrackingResponseDto({
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

  factory ShipmentTrackingResponseDto.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'];
    final eventList = eventsJson is List<dynamic>
        ? eventsJson
              .whereType<Map<String, dynamic>>()
              .map(ShipmentTrackingEventDto.fromJson)
              .toList()
        : <ShipmentTrackingEventDto>[];

    return ShipmentTrackingResponseDto(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      provider: json['provider'] as String,
      trackingCode: json['trackingCode'] as String,
      status: json['status'] as String,
      rawStatus: json['rawStatus'] as String?,
      latestNote: json['latestNote'] as String?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      syncedAt: json['syncedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      events: eventList,
    );
  }
}
