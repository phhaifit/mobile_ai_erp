enum BrandStatus {
  active('Active'),
  archived('Archived');

  const BrandStatus(this.label);

  final String label;
}

class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.logoUrl,
    this.countryCode,
    this.regionOrState,
    this.city,
    this.sortOrder = 0,
    this.status = BrandStatus.active,
  });

  final String id;
  final String name;
  final String code;
  final String? description;
  final String? logoUrl;
  final String? countryCode;
  final String? regionOrState;
  final String? city;
  final int sortOrder;
  final BrandStatus status;

  bool get isActive => status == BrandStatus.active;

  String? get displayLocation {
    final parts = <String>[
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (regionOrState != null && regionOrState!.trim().isNotEmpty)
        regionOrState!.trim(),
      if (countryCode != null && countryCode!.trim().isNotEmpty)
        countryCode!.trim().toUpperCase(),
    ];
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(', ');
  }

  Brand copyWith({
    String? id,
    String? name,
    String? code,
    Object? description = _sentinel,
    Object? logoUrl = _sentinel,
    Object? countryCode = _sentinel,
    Object? regionOrState = _sentinel,
    Object? city = _sentinel,
    int? sortOrder,
    BrandStatus? status,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      logoUrl:
          identical(logoUrl, _sentinel) ? this.logoUrl : logoUrl as String?,
      countryCode: identical(countryCode, _sentinel)
          ? this.countryCode
          : countryCode as String?,
      regionOrState: identical(regionOrState, _sentinel)
          ? this.regionOrState
          : regionOrState as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
    );
  }
}

const Object _sentinel = Object();
