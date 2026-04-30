class SupplierResponseDto {
  final String id;
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxCode;
  final String? idCard;
  final String? bankName;
  final String? bankAccount;
  final String? bankNote;
  final DateTime createdAt;

  SupplierResponseDto({
    required this.id,
    required this.code,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.taxCode,
    this.idCard,
    this.bankName,
    this.bankAccount,
    this.bankNote,
    required this.createdAt,
  });

  factory SupplierResponseDto.fromJson(Map<String, dynamic> json) {
    return SupplierResponseDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      taxCode: json['taxCode'] as String?,
      idCard: json['idCard'] as String?,
      bankName: json['bankName'] as String?,
      bankAccount: json['bankAccount'] as String?,
      bankNote: json['bankNote'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(0),
    );
  }
}
