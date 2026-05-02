enum AddressType {
  home('Home'),
  office('Office'),
  billing('Billing'),
  shipping('Shipping'),
  warehouse('Warehouse'),
  other('Other');

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
    this.type = AddressType.home,
    this.state,
    this.postalCode,
    this.isDefault = false,
    this.updatedAt,
    this.isValidated = false,
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
  final DateTime? updatedAt;
  final bool isValidated;

  String get displayAddress {
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
      if (countryCode.isNotEmpty) countryCode.toUpperCase(),
      if (postalCode != null && postalCode!.trim().isNotEmpty)
        postalCode!.trim(),
    ];
    return parts.join(', ');
  }

  /// Validate address completeness and format
  ValidationResult validate() {
    final errors = <String>[];

    // Validate label - can be derived from city, but ensure it has content
    final labelValue = label.trim();
    if (labelValue.isEmpty) {
      errors.add('Address label is required');
    } else if (labelValue.length < 2) {
      errors.add('Address label must be at least 2 characters');
    }

    // Validate street address
    final streetValue = street.trim();
    if (streetValue.isEmpty) {
      errors.add('Street address is required');
    } else if (streetValue.length < 3) {
      errors.add('Street address must be at least 3 characters');
    }

    // Validate city/province
    final cityValue = city.trim();
    if (cityValue.isEmpty) {
      errors.add('City/Province is required');
    } else if (cityValue.length < 2) {
      errors.add('City/Province must be at least 2 characters');
    }

    // Validate country code - optional but if provided must be valid
    final countryValue = countryCode.trim();
    if (countryValue.isNotEmpty && countryValue.length < 2) {
      errors.add('Invalid country code format');
    }

    // Validate postal code if provided
    if (postalCode != null && postalCode!.trim().isNotEmpty) {
      final postalValue = postalCode!.trim();
      if (postalValue.isEmpty) {
        errors.add('Postal code cannot be empty if provided');
      }
    }

    // Validate state/district if provided
    if (state != null && state!.trim().isNotEmpty) {
      final stateValue = state!.trim();
      if (stateValue.isEmpty) {
        errors.add('State/District cannot be empty if provided');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Check if address data has changed
  bool hasChanged(Address other) {
    return label != other.label ||
        street != other.street ||
        city != other.city ||
        state != other.state ||
        countryCode != other.countryCode ||
        postalCode != other.postalCode ||
        type != other.type;
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
    DateTime? updatedAt,
    bool? isValidated,
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
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
      isValidated: isValidated ?? this.isValidated,
    );
  }
}

/// Result of address validation
class ValidationResult {
  const ValidationResult({required this.isValid, required this.errors});

  final bool isValid;
  final List<String> errors;

  String get errorMessage => errors.join(', ');
}

const Object _sentinel = Object();