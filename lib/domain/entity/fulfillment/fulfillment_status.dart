enum FulfillmentStatus {
  pending,
  picking,
  packing,
  packed,
  shipped,
  partiallyDelivered,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case FulfillmentStatus.pending:
        return 'Pending';
      case FulfillmentStatus.picking:
        return 'Picking';
      case FulfillmentStatus.packing:
        return 'Packing';
      case FulfillmentStatus.packed:
        return 'Packed';
      case FulfillmentStatus.shipped:
        return 'Shipped';
      case FulfillmentStatus.partiallyDelivered:
        return 'Partially Delivered';
      case FulfillmentStatus.delivered:
        return 'Delivered';
      case FulfillmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
