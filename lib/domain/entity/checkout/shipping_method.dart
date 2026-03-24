/// Represents a shipping method available for checkout
class ShippingMethod {
  const ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.estimatedDays,
    this.carrier,
    this.trackingSupported = true,
    this.insuranceIncluded = false,
    this.iconPath,
    this.isAvailable = true,
    this.unavailableReason,
  });

  /// Unique identifier for the shipping method
  final String id;

  /// Display name (e.g., "Standard Shipping", "Express Delivery")
  final String name;

  /// Short description of the shipping method
  final String description;

  /// Base shipping cost (may be modified based on location/weight)
  final double baseCost;

  /// Estimated delivery time in days (min days)
  final int estimatedDays;

  /// Shipping carrier name (e.g., "DHL", "FedEx", "Local Post")
  final String? carrier;

  /// Whether tracking is supported
  final bool trackingSupported;

  /// Whether insurance is included
  final bool insuranceIncluded;

  /// Path to icon asset
  final String? iconPath;

  /// Whether this method is currently available
  final bool isAvailable;

  /// Reason if unavailable
  final String? unavailableReason;

  /// Get estimated delivery date range as string
  String get estimatedDeliveryText {
    if (estimatedDays <= 1) return '1 day';
    return '$estimatedDays-${estimatedDays + 2} days';
  }

  /// Get formatted cost string
  String get formattedCost => '\$${baseCost.toStringAsFixed(2)}';

  ShippingMethod copyWith({
    String? id,
    String? name,
    String? description,
    double? baseCost,
    int? estimatedDays,
    String? carrier,
    bool? trackingSupported,
    bool? insuranceIncluded,
    String? iconPath,
    bool? isAvailable,
    String? unavailableReason,
  }) {
    return ShippingMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseCost: baseCost ?? this.baseCost,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      carrier: carrier ?? this.carrier,
      trackingSupported: trackingSupported ?? this.trackingSupported,
      insuranceIncluded: insuranceIncluded ?? this.insuranceIncluded,
      iconPath: iconPath ?? this.iconPath,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingMethod && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
