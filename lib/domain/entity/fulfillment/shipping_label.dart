class ShippingLabel {
  final String orderId;
  final String packageId;
  final String senderName;
  final String senderAddress;
  final String receiverName;
  final String receiverAddress;
  final String trackingNumber;
  final String carrier;
  final double weight;

  ShippingLabel({
    required this.orderId,
    required this.packageId,
    required this.senderName,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverAddress,
    required this.trackingNumber,
    required this.carrier,
    required this.weight,
  });
}
