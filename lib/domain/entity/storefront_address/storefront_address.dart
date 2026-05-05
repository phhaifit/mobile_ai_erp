enum AddressType {
  home('home'),
  office('office'),
  billing('billing'),
  shipping('shipping'),
  warehouse('warehouse'),
  other('other');

  const AddressType(this.value);
  final String value;

  static AddressType fromString(String? val) {
    return AddressType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => AddressType.home,
    );
  }
}

class StorefrontAddress {
  final String id;
  final String address;
  final AddressType type; // Updated to Enum
  final String? province;
  final String? district;
  final String? ward;
  final bool isDefault;

  StorefrontAddress({
    required this.id,
    required this.address,
    required this.type,
    this.province,
    this.district,
    this.ward,
    this.isDefault = false,
  });

  StorefrontAddress copyWith({
    String? id,
    String? address,
    AddressType? type,
    Object? province,
    Object? district,
    Object? ward,
    bool? isDefault,
  }) {
    return StorefrontAddress(
      id: id ?? this.id,
      address: address ?? this.address,
      type: type ?? this.type,
      province: identical(province, _sentinel) ? this.province : province as String?,
      district: identical(district, _sentinel) ? this.district : district as String?,
      ward: identical(ward, _sentinel) ? this.ward : ward as String?,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'type': type.value, // Send the string value to NestJS
      'province': province,
      'district': district,
      'ward': ward,
      'isDefault': isDefault,
    };
  }

  factory StorefrontAddress.fromJson(Map<String, dynamic> json) {
    return StorefrontAddress(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      type: AddressType.fromString(json['type']?.toString()), // Parse string back to Enum
      province: json['province']?.toString(),
      district: json['district']?.toString(),
      ward: json['ward']?.toString(),
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }
}

const _sentinel = Object();