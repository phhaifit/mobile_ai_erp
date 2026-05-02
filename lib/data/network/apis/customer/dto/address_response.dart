class AddressDto {
  final String id;
  final String customerId;
  final String type;
  final String? address;
  final String? province;
  final String? district;
  final String? ward;
  final bool isDefault;
  final String? createdAt;

  AddressDto({
    required this.id,
    required this.customerId,
    required this.type,
    this.address,
    this.province,
    this.district,
    this.ward,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'] as String,
      customerId: json['customerId'] as String? ?? '',
      type: json['type'] as String? ?? 'both',
      address: json['address'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }
}
