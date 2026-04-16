enum StocktakeSessionStatus {
  draft,
  counting,
  submitted,
  reconciled,
  approved,
  rejected,
}

enum OutboundIssueStatus {
  draft,
  confirmed,
  cancelled,
}

class StocktakeLineViewModel {
  const StocktakeLineViewModel({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.systemQty,
    this.countedQty,
    this.note,
  });

  final String productId;
  final String productName;
  final String unit;
  final int systemQty;
  final int? countedQty;
  final String? note;

  int? get discrepancy {
    final count = countedQty;
    if (count == null) {
      return null;
    }
    return count - systemQty;
  }

  StocktakeLineViewModel copyWith({
    String? productId,
    String? productName,
    String? unit,
    int? systemQty,
    int? countedQty,
    String? note,
    bool clearCountedQty = false,
  }) {
    return StocktakeLineViewModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unit: unit ?? this.unit,
      systemQty: systemQty ?? this.systemQty,
      countedQty: clearCountedQty ? null : (countedQty ?? this.countedQty),
      note: note ?? this.note,
    );
  }
}

class StocktakeSessionViewModel {
  const StocktakeSessionViewModel({
    required this.id,
    required this.code,
    required this.warehouseId,
    required this.warehouseName,
    required this.status,
    required this.openedAt,
    required this.lines,
    required this.mismatchCount,
    required this.totalAbsoluteDiscrepancy,
    this.closedAt,
    this.reconciledAt,
    this.approvedAt,
    this.approverName,
    this.serverCalculated = false,
  });

  final String id;
  final String code;
  final String warehouseId;
  final String warehouseName;
  final StocktakeSessionStatus status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final DateTime? reconciledAt;
  final DateTime? approvedAt;
  final String? approverName;
  final List<StocktakeLineViewModel> lines;
  final int mismatchCount;
  final int totalAbsoluteDiscrepancy;
  final bool serverCalculated;

  StocktakeSessionViewModel copyWith({
    String? id,
    String? code,
    String? warehouseId,
    String? warehouseName,
    StocktakeSessionStatus? status,
    DateTime? openedAt,
    DateTime? closedAt,
    DateTime? reconciledAt,
    DateTime? approvedAt,
    String? approverName,
    List<StocktakeLineViewModel>? lines,
    int? mismatchCount,
    int? totalAbsoluteDiscrepancy,
    bool? serverCalculated,
    bool clearClosedAt = false,
    bool clearReconciledAt = false,
    bool clearApprovedAt = false,
    bool clearApproverName = false,
  }) {
    return StocktakeSessionViewModel(
      id: id ?? this.id,
      code: code ?? this.code,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      closedAt: clearClosedAt ? null : (closedAt ?? this.closedAt),
      reconciledAt: clearReconciledAt ? null : (reconciledAt ?? this.reconciledAt),
      approvedAt: clearApprovedAt ? null : (approvedAt ?? this.approvedAt),
      approverName: clearApproverName ? null : (approverName ?? this.approverName),
      lines: lines ?? this.lines,
      mismatchCount: mismatchCount ?? this.mismatchCount,
      totalAbsoluteDiscrepancy:
          totalAbsoluteDiscrepancy ?? this.totalAbsoluteDiscrepancy,
      serverCalculated: serverCalculated ?? this.serverCalculated,
    );
  }
}

class OutboundIssueViewModel {
  const OutboundIssueViewModel({
    required this.id,
    required this.code,
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final String id;
  final String code;
  final String warehouseId;
  final String warehouseName;
  final String productId;
  final String productName;
  final int quantity;
  final OutboundIssueStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  OutboundIssueViewModel copyWith({
    String? id,
    String? code,
    String? warehouseId,
    String? warehouseName,
    String? productId,
    String? productName,
    int? quantity,
    OutboundIssueStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return OutboundIssueViewModel(
      id: id ?? this.id,
      code: code ?? this.code,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }
}
