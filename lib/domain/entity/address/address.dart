class Address {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}