enum FulfillmentStatus {
  pending,
  processing,
  partiallyShipped,
  shipped,
  delivered,
  cancelled,
  returned;

  String get displayName {
    switch (this) {
      case FulfillmentStatus.pending:
        return 'Pending';
      case FulfillmentStatus.processing:
        return 'Processing';
      case FulfillmentStatus.partiallyShipped:
        return 'Partially Shipped';
      case FulfillmentStatus.shipped:
        return 'Shipped';
      case FulfillmentStatus.delivered:
        return 'Delivered';
      case FulfillmentStatus.cancelled:
        return 'Cancelled';
      case FulfillmentStatus.returned:
        return 'Returned';
    }
  }

  /// Maps a BE API status string to the corresponding enum value.
  static FulfillmentStatus? fromApiString(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'pending':
        return FulfillmentStatus.pending;
      case 'processing':
        return FulfillmentStatus.processing;
      case 'partially_shipped':
        return FulfillmentStatus.partiallyShipped;
      case 'shipped':
        return FulfillmentStatus.shipped;
      case 'delivered':
        return FulfillmentStatus.delivered;
      case 'cancelled':
        return FulfillmentStatus.cancelled;
      case 'returned':
        return FulfillmentStatus.returned;
      default:
        return null;
    }
  }

  /// Converts the enum value to a BE API status string.
  String get apiValue {
    switch (this) {
      case FulfillmentStatus.partiallyShipped:
        return 'partially_shipped';
      default:
        return name;
    }
  }
}
