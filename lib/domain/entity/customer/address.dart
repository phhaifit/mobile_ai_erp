enum AddressType {
  shipping('Shipping'),
  billing('Billing'),
  both('Shipping & Billing');

  const AddressType(this.label);

  final String label;
}

class Address {
  const Address({
    required this.id,
    required this.customerId,
    required this.label,
    required this.street,
    required this.city,
    required this.countryCode,
    this.type = AddressType.both,
    this.state,
    this.postalCode,
    this.isDefault = false,
  });

  final String id;
  final String customerId;
  final String label;
  final AddressType type;
  final String street;
  final String city;
  final String? state;
  final String countryCode;
  final String? postalCode;
  final bool isDefault;

  String get displayAddress {
    final parts = <String>[
      street,
      city,
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
      countryCode.toUpperCase(),
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        postalCode!.trim(),
    ];
    return parts.join(', ');
  }

  Address copyWith({
    String? id,
    String? customerId,
    String? label,
    AddressType? type,
    String? street,
    String? city,
    Object? state = _sentinel,
    String? countryCode,
    Object? postalCode = _sentinel,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      type: type ?? this.type,
      street: street ?? this.street,
      city: city ?? this.city,
      state: identical(state, _sentinel) ? this.state : state as String?,
      countryCode: countryCode ?? this.countryCode,
      postalCode: identical(postalCode, _sentinel)
          ? this.postalCode
          : postalCode as String?,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

const Object _sentinel = Object();
