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

class ShipmentItemDto {
  final String id;
  final String orderItemId;
  final int quantity;

  ShipmentItemDto({
    required this.id,
    required this.orderItemId,
    required this.quantity,
  });

  factory ShipmentItemDto.fromJson(Map<String, dynamic> json) {
    return ShipmentItemDto(
      id: json['id'] as String,
      orderItemId: json['orderItemId'] as String,
      quantity: json['quantity'] as int,
    );
  }
}

class ShipmentTrackingResponseDto {
  final String id;
  final String orderId;
  final int shipmentNumber;
  final String provider;
  final String trackingCode;
  final String status;
  final String? rawStatus;
  final String? latestNote;
  final String? estimatedDelivery;
  final String? syncedAt;
  final String createdAt;
  final String updatedAt;
  final List<ShipmentItemDto> items;
  final List<ShipmentTrackingEventDto> events;

  ShipmentTrackingResponseDto({
    required this.id,
    required this.orderId,
    required this.shipmentNumber,
    required this.provider,
    required this.trackingCode,
    required this.status,
    this.rawStatus,
    this.latestNote,
    this.estimatedDelivery,
    this.syncedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
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

    final itemsJson = json['items'];
    final itemList = itemsJson is List<dynamic>
        ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(ShipmentItemDto.fromJson)
              .toList()
        : <ShipmentItemDto>[];

    return ShipmentTrackingResponseDto(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      shipmentNumber: json['shipmentNumber'] as int? ?? 1,
      provider: json['provider'] as String,
      trackingCode: json['trackingCode'] as String,
      status: json['status'] as String,
      rawStatus: json['rawStatus'] as String?,
      latestNote: json['latestNote'] as String?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      syncedAt: json['syncedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      items: itemList,
      events: eventList,
    );
  }
}

class OrderShipmentsTrackingResponseDto {
  final String orderId;
  final List<ShipmentTrackingResponseDto> shipments;

  OrderShipmentsTrackingResponseDto({
    required this.orderId,
    required this.shipments,
  });

  factory OrderShipmentsTrackingResponseDto.fromJson(Map<String, dynamic> json) {
    final shipmentsJson = json['shipments'];
    final shipments = shipmentsJson is List<dynamic>
        ? shipmentsJson
              .whereType<Map<String, dynamic>>()
              .map(ShipmentTrackingResponseDto.fromJson)
              .toList()
        : <ShipmentTrackingResponseDto>[];

    return OrderShipmentsTrackingResponseDto(
      orderId: json['orderId'] as String,
      shipments: shipments,
    );
  }
}
