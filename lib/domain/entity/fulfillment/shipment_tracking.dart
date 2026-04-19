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

class CreateShipmentItemAllocation {
  final String orderItemId;
  final int quantity;

  const CreateShipmentItemAllocation({
    required this.orderItemId,
    required this.quantity,
  });
}

class ShipmentItemAllocation {
  final String id;
  final String orderItemId;
  final int quantity;

  const ShipmentItemAllocation({
    required this.id,
    required this.orderItemId,
    required this.quantity,
  });
}

class ShipmentTrackingInfo {
  final String id;
  final String orderId;
  final int shipmentNumber;
  final String provider;
  final String trackingCode;
  final String status;
  final String? rawStatus;
  final String? latestNote;
  final DateTime? estimatedDelivery;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShipmentItemAllocation> items;
  final List<ShipmentTrackingEvent> events;

  ShipmentTrackingInfo({
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
    List<ShipmentItemAllocation>? items,
    required this.events,
  }) : items = items ?? const [];
}

class OrderShipmentsTrackingInfo {
  final String orderId;
  final List<ShipmentTrackingInfo> shipments;

  const OrderShipmentsTrackingInfo({
    required this.orderId,
    required this.shipments,
  });
}

class ShipmentLabelArtifact {
  final String id;
  final String shipmentId;
  final String artifactType;
  final String format;
  final String? publicUrl;
  final DateTime generatedAt;

  const ShipmentLabelArtifact({
    required this.id,
    required this.shipmentId,
    required this.artifactType,
    required this.format,
    this.publicUrl,
    required this.generatedAt,
  });
}

class ShipmentPrintAttempt {
  final String id;
  final String printJobId;
  final int attemptNo;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? durationMs;
  final String? errorCode;
  final String? errorMessage;

  const ShipmentPrintAttempt({
    required this.id,
    required this.printJobId,
    required this.attemptNo,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.durationMs,
    this.errorCode,
    this.errorMessage,
  });
}

class ShipmentPrintJob {
  final String id;
  final String shipmentId;
  final String? artifactId;
  final String status;
  final String? printerName;
  final String? printerCode;
  final int copies;
  final DateTime queuedAt;
  final DateTime? completedAt;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final ShipmentLabelArtifact? artifact;
  final List<ShipmentPrintAttempt> attempts;

  const ShipmentPrintJob({
    required this.id,
    required this.shipmentId,
    required this.artifactId,
    required this.status,
    this.printerName,
    this.printerCode,
    required this.copies,
    required this.queuedAt,
    this.completedAt,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.artifact,
    this.attempts = const [],
  });
}

class RoutingRecommendationOption {
  final String optionId;
  final String provider;
  final String serviceLevel;
  final double score;
  final int estimatedDeliveryDays;
  final double estimatedCost;
  final String reason;

  const RoutingRecommendationOption({
    required this.optionId,
    required this.provider,
    required this.serviceLevel,
    required this.score,
    required this.estimatedDeliveryDays,
    required this.estimatedCost,
    required this.reason,
  });
}

class OrderRoutingRecommendation {
  final String decisionId;
  final String orderId;
  final String recommendedProvider;
  final String? selectedProvider;
  final double? confidence;
  final String scoreStrategy;
  final bool fallbackUsed;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final List<RoutingRecommendationOption> options;

  const OrderRoutingRecommendation({
    required this.decisionId,
    required this.orderId,
    required this.recommendedProvider,
    required this.selectedProvider,
    required this.confidence,
    required this.scoreStrategy,
    required this.fallbackUsed,
    required this.createdAt,
    required this.appliedAt,
    required this.options,
  });
}

class OrderRoutingApplyResult {
  final String decisionId;
  final String orderId;
  final String selectedProvider;
  final String? selectedOptionId;
  final DateTime appliedAt;

  const OrderRoutingApplyResult({
    required this.decisionId,
    required this.orderId,
    required this.selectedProvider,
    required this.selectedOptionId,
    required this.appliedAt,
  });
}
