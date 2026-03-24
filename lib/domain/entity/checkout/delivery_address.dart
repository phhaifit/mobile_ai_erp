/// Enum representing address label type
enum AddressLabel {
  home('Home', 'Residential address'),
  work('Work', 'Business/Office address'),
  other('Other', 'Custom address');

  const AddressLabel(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Represents a delivery address for checkout
class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.countryCode,
    this.label = AddressLabel.home,
    this.companyName,
    this.state,
    this.stateCode,
    this.postalCode,
    this.country,
    this.isDefault = false,
    this.isVerified = false,
    this.deliveryInstructions,
    this.latitude,
    this.longitude,
  });

  /// Unique identifier
  final String id;

  /// Full name of recipient
  final String fullName;

  /// Phone number for delivery contact
  final String phone;

  /// Street address (including house/unit number)
  final String street;

  /// City name
  final String city;

  /// Country code (ISO 3166-1 alpha-2)
  final String countryCode;

  /// Address label type
  final AddressLabel label;

  /// Company name (optional, for work addresses)
  final String? companyName;

  /// State/Province name
  final String? state;

  /// State/Province code
  final String? stateCode;

  /// Postal/ZIP code
  final String? postalCode;

  /// Full country name
  final String? country;

  /// Whether this is the default address
  final bool isDefault;

  /// Whether this address has been verified
  final bool isVerified;

  /// Special delivery instructions
  final String? deliveryInstructions;

  /// Latitude coordinate (for map display)
  final double? latitude;

  /// Longitude coordinate (for map display)
  final double? longitude;

  /// Get formatted single-line address
  String get formattedAddress {
    final parts = <String>[
      street,
      city,
      if (state != null && state!.isNotEmpty) state!,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode!,
      countryCode.toUpperCase(),
    ];
    return parts.join(', ');
  }

  /// Get formatted multi-line address
  List<String> get addressLines {
    return [
      street,
      '$city${state != null && state!.isNotEmpty ? ', $state' : ''}${postalCode != null && postalCode!.isNotEmpty ? ' $postalCode' : ''}',
      country ?? countryCode.toUpperCase(),
    ];
  }

  /// Get short display name
  String get shortDisplayName {
    return '${label.displayName} - ${street.split(',').first}';
  }

  /// Check if address has coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  DeliveryAddress copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? countryCode,
    AddressLabel? label,
    String? companyName,
    Object? state = _sentinel,
    Object? stateCode = _sentinel,
    Object? postalCode = _sentinel,
    Object? country = _sentinel,
    bool? isDefault,
    bool? isVerified,
    Object? deliveryInstructions = _sentinel,
    Object? latitude = _sentinel,
    Object? longitude = _sentinel,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      label: label ?? this.label,
      companyName: companyName ?? this.companyName,
      state: identical(state, _sentinel) ? this.state : state as String?,
      stateCode:
          identical(stateCode, _sentinel) ? this.stateCode : stateCode as String?,
      postalCode:
          identical(postalCode, _sentinel) ? this.postalCode : postalCode as String?,
      country: identical(country, _sentinel) ? this.country : country as String?,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      deliveryInstructions: identical(deliveryInstructions, _sentinel)
          ? this.deliveryInstructions
          : deliveryInstructions as String?,
      latitude:
          identical(latitude, _sentinel) ? this.latitude : latitude as double?,
      longitude:
          identical(longitude, _sentinel) ? this.longitude : longitude as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAddress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
