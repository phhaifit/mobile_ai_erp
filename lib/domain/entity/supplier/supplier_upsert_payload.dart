class SupplierUpsertPayload {
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

  const SupplierUpsertPayload({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'taxCode': taxCode,
      'idCard': idCard,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'bankNote': bankNote,
    };
  }
}
