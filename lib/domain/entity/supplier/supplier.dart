class Supplier {
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

  Supplier({
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

  Supplier copyWith({
    String? id,
    String? code,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? taxCode,
    String? idCard,
    String? bankName,
    String? bankAccount,
    String? bankNote,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxCode: taxCode ?? this.taxCode,
      idCard: idCard ?? this.idCard,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      bankNote: bankNote ?? this.bankNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
