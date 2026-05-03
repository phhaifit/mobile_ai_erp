class Address {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final bool isDefault;

  // Backend fields
  final String? type;
  final String? province;
  final String? district;
  final String? ward;
  final String? customerId;
  final String? tenantId;
  final DateTime? createdAt;

  Address({
    required this.id,
    this.fullName = '',
    this.phone = '',
    required this.street,
    required this.city,
    this.isDefault = false,
    this.type,
    this.province,
    this.district,
    this.ward,
    this.customerId,
    this.tenantId,
    this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['address'] as String? ?? json['street'] as String? ?? '',
      city: json['city'] as String? ?? json['province'] as String? ?? '',
      isDefault:
          json['isDefault'] as bool? ?? json['is_default'] as bool? ?? false,
      type: json['type'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      ward: json['ward'] as String?,
      customerId: json['customerId'] as String?,
      tenantId: json['tenantId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type ?? 'home',
        'address': street,
        if (province != null) 'province': province,
        if (district != null) 'district': district,
        if (ward != null) 'ward': ward,
        'isDefault': isDefault,
      };

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    bool? isDefault,
    String? type,
    String? province,
    String? district,
    String? ward,
    String? customerId,
    String? tenantId,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      customerId: customerId ?? this.customerId,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
