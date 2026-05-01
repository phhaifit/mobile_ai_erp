class AddressDto {
  final String id;
  final String customerId;
  final String label;
  final String street;
  final String city;
  final String countryCode;
  final String? type;
  final String? state;
  final String? postalCode;
  final bool isDefault;

  AddressDto({
    required this.id,
    required this.customerId,
    required this.label,
    required this.street,
    required this.city,
    required this.countryCode,
    this.type,
    this.state,
    this.postalCode,
    required this.isDefault,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      countryCode: json['countryCode'] as String,
      type: json['type'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
