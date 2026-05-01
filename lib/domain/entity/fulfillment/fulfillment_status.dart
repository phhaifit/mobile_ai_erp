enum FulfillmentStatus {
  newOrder,
  pending,
  confirmed,
  packing,
  shipping,
  partiallyShipped,
  delivered,
  success,
  cancelled,
  returned;

  String get displayName {
    switch (this) {
      case FulfillmentStatus.newOrder:
        return 'New';
      case FulfillmentStatus.pending:
        return 'Pending';
      case FulfillmentStatus.confirmed:
        return 'Confirmed';
      case FulfillmentStatus.packing:
        return 'Packing';
      case FulfillmentStatus.shipping:
        return 'Shipping';
      case FulfillmentStatus.partiallyShipped:
        return 'Partially Shipped';
      case FulfillmentStatus.delivered:
        return 'Delivered';
      case FulfillmentStatus.success:
        return 'Completed';
      case FulfillmentStatus.cancelled:
        return 'Cancelled';
      case FulfillmentStatus.returned:
        return 'Returned';
    }
  }

  /// Maps a BE API status string to the corresponding enum value.
  /// One-to-one mapping — no merging of multiple BE statuses.
  static FulfillmentStatus? fromApiString(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'new':
        return FulfillmentStatus.newOrder;
      case 'pending':
        return FulfillmentStatus.pending;
      case 'confirmed':
        return FulfillmentStatus.confirmed;
      case 'packing':
        return FulfillmentStatus.packing;
      case 'shipping':
        return FulfillmentStatus.shipping;
      case 'partially_shipped':
        return FulfillmentStatus.partiallyShipped;
      case 'delivered':
        return FulfillmentStatus.delivered;
      case 'success':
        return FulfillmentStatus.success;
      case 'cancelled':
        return FulfillmentStatus.cancelled;
      case 'returned':
        return FulfillmentStatus.returned;
      default:
        return null;
    }
  }

  /// Converts the enum value to the BE API status string expected by PATCH /orders/:id/status.
  String get apiValue {
    switch (this) {
      case FulfillmentStatus.newOrder:
        return 'new';
      case FulfillmentStatus.partiallyShipped:
        return 'partially_shipped';
      default:
        // For all other statuses, the enum name matches the BE string exactly.
        return name;
    }
  }

  /// Returns true for statuses that represent an active shipment phase
  /// where the carrier (GHN) drives status transitions via webhook.
  bool get isActiveShippingPhase =>
      this == FulfillmentStatus.shipping ||
      this == FulfillmentStatus.partiallyShipped;

  /// Returns true for terminal statuses where no further transitions are possible.
  bool get isTerminal =>
      this == FulfillmentStatus.success ||
      this == FulfillmentStatus.cancelled ||
      this == FulfillmentStatus.returned;
}
