/// Enum representing different payment method types
enum PaymentMethodType {
  cod('Cash on Delivery', 'Pay when you receive your order'),
  bankTransfer('Bank Transfer', 'Transfer to our bank account'),
  eWallet('E-Wallet', 'Pay with your digital wallet'),
  creditCard('Credit/Debit Card', 'Pay securely with your card'),
  paymentGateway('Payment Gateway', 'Pay via third-party gateway');

  const PaymentMethodType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Represents a payment method available for checkout
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.isEnabled,
    this.description,
    this.iconPath,
    this.fee = 0.0,
    this.feePercentage = 0.0,
    this.minAmount,
    this.maxAmount,
    this.instructions,
    this.gatewayConfig,
    this.requiresVerification = false,
    this.processingTime,
  });

  /// Unique identifier for the payment method
  final String id;

  /// Type of payment method
  final PaymentMethodType type;

  /// Display name
  final String name;

  /// Whether this method is enabled
  final bool isEnabled;

  /// Optional description
  final String? description;

  /// Path to icon asset
  final String? iconPath;

  /// Fixed fee for using this payment method
  final double fee;

  /// Percentage fee (e.g., 2.5% = 2.5)
  final double feePercentage;

  /// Minimum order amount for this method
  final double? minAmount;

  /// Maximum order amount for this method
  final double? maxAmount;

  /// Payment instructions (for bank transfer, etc.)
  final String? instructions;

  /// Gateway configuration (for payment gateway type)
  final Map<String, dynamic>? gatewayConfig;

  /// Whether verification is required
  final bool requiresVerification;

  /// Estimated processing time description
  final String? processingTime;

  /// Calculate total fee for a given order amount
  double calculateFee(double orderAmount) {
    return fee + (orderAmount * feePercentage / 100);
  }

  /// Check if this method is available for the given amount
  bool isAvailableForAmount(double amount) {
    if (!isEnabled) return false;
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }

  /// Get fee description
  String get feeDescription {
    if (fee == 0 && feePercentage == 0) return 'No fee';
    if (fee > 0 && feePercentage > 0) {
      return '\$${fee.toStringAsFixed(2)} + $feePercentage%';
    }
    if (fee > 0) return '\$${fee.toStringAsFixed(2)}';
    return '$feePercentage%';
  }

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? name,
    bool? isEnabled,
    String? description,
    String? iconPath,
    double? fee,
    double? feePercentage,
    double? minAmount,
    double? maxAmount,
    String? instructions,
    Map<String, dynamic>? gatewayConfig,
    bool? requiresVerification,
    String? processingTime,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      fee: fee ?? this.fee,
      feePercentage: feePercentage ?? this.feePercentage,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      instructions: instructions ?? this.instructions,
      gatewayConfig: gatewayConfig ?? this.gatewayConfig,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      processingTime: processingTime ?? this.processingTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
