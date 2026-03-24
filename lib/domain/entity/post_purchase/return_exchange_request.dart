enum ReturnType {
  returnOnly,
  exchange,
}

extension ReturnTypeLabel on ReturnType {
  String get displayName {
    switch (this) {
      case ReturnType.returnOnly:
        return 'Return';
      case ReturnType.exchange:
        return 'Exchange';
    }
  }
}

enum ReturnStatus {
  requested,
  approved,
  inTransitBack,
  received,
  refunded,
  exchanged,
  rejected,
}

extension ReturnStatusLabel on ReturnStatus {
  String get displayName {
    switch (this) {
      case ReturnStatus.requested:
        return 'Requested';
      case ReturnStatus.approved:
        return 'Approved';
      case ReturnStatus.inTransitBack:
        return 'In Transit';
      case ReturnStatus.received:
        return 'Received';
      case ReturnStatus.refunded:
        return 'Refunded';
      case ReturnStatus.exchanged:
        return 'Exchanged';
      case ReturnStatus.rejected:
        return 'Rejected';
    }
  }
}

class ReturnLineItem {
  ReturnLineItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String sku;
  final String name;
  final int quantity;
  final double price;
}

class ReturnExchangeRequest {
  ReturnExchangeRequest({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.reason,
    required this.status,
    required this.type,
    required this.requestedAt,
    required this.updatedAt,
    required this.items,
    this.refundAmount,
    this.exchangeSku,
    this.notes,
    this.adminNotes,
    this.linkedIssueId,
  });

  final String id;
  final String orderId;
  final String customerName;
  final String reason;
  ReturnStatus status;
  ReturnType type;
  final DateTime requestedAt;
  DateTime updatedAt;
  final List<ReturnLineItem> items;
  double? refundAmount;
  final String? exchangeSku;
  final String? notes;
  String? adminNotes;
  String? linkedIssueId;
}
