import 'package:mobile_ai_erp/data/network/dto/supplier_response.dto.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier.dart';

class SupplierMapper {
  static Supplier toDomain(SupplierResponseDto dto) {
    return Supplier(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      phone: dto.phone,
      email: dto.email,
      address: dto.address,
      taxCode: dto.taxCode,
      idCard: dto.idCard,
      bankName: dto.bankName,
      bankAccount: dto.bankAccount,
      bankNote: dto.bankNote,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
    );
  }

  static Supplier fromJson(Map<String, dynamic> json) {
    return toDomain(SupplierResponseDto.fromJson(json));
  }

  static List<Supplier> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
