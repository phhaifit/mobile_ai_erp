import 'package:mobile_ai_erp/domain/entity/product_metadata/unit_group.dart';

class Unit {
  const Unit({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.unitGroup,
  });

  // Unique identifier for the unit record.
  final String id;

  // Stable unit code, e.g. kg, g, cm.
  final String code;

  // Unit display name, e.g. Kilogram, Gram, Centimeter.
  final String name;

  // Short symbol shown in the UI.
  final String symbol;

  final UnitGroup unitGroup;

  Unit copyWith({
    String? id,
    String? code,
    String? name,
    String? symbol,
    UnitGroup? unitGroup,
  }) {
    return Unit(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      unitGroup: unitGroup ?? this.unitGroup,
    );
  }
}
