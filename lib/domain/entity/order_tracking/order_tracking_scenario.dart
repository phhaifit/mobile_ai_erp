enum ShipmentStage { confirmed, packed, shipped, delivered }

enum DeliveryAlertType { none, failed, redeliveryScheduled }

enum ReturnExchangeStage {
  none,
  requested,
  approved,
  inTransitBack,
  received,
  refunded,
  exchanged,
}

class TrackingTimelineStep {
  const TrackingTimelineStep({
    required this.stage,
    this.timestamp,
  });

  final ShipmentStage stage;
  final DateTime? timestamp;
}

class OrderTrackingScenario {
  const OrderTrackingScenario({
    required this.scenarioName,
    required this.orderId,
    required this.trackingNumber,
    required this.carrierName,
    required this.carrierTrackingUrl,
    required this.estimatedDeliveryDate,
    required this.lastUpdatedAt,
    required this.timelineSteps,
    required this.currentStage,
    required this.deliveryAlertType,
    required this.deliveryAlertMessage,
    required this.returnExchangeStage,
  });

  final String scenarioName;
  final String orderId;
  final String trackingNumber;
  final String carrierName;
  final String carrierTrackingUrl;
  final DateTime estimatedDeliveryDate;
  final DateTime lastUpdatedAt;
  final List<TrackingTimelineStep> timelineSteps;
  final ShipmentStage currentStage;
  final DeliveryAlertType deliveryAlertType;
  final String deliveryAlertMessage;
  final ReturnExchangeStage returnExchangeStage;
}
