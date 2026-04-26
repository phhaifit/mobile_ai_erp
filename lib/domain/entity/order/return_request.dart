class ReturnItemPayload {
  final String orderItemId;
  final int quantity;
  final String? reason;

  ReturnItemPayload({
    required this.orderItemId,
    required this.quantity,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'quantity': quantity,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
    };
  }
}

class SubmitReturnPayload {
  final String type; // Usually 'return' or 'exchange'
  final String? reason;
  final List<ReturnItemPayload> items;

  SubmitReturnPayload({
    this.type = 'return',
    this.reason,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}