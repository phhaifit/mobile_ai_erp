enum AttributeValueType {
  dropdown('Dropdown'),
  multiselect('Multi-select'),
  text('Text'),
  number('Number');

  const AttributeValueType(this.label);

  final String label;

  bool get supportsOptions =>
      this == AttributeValueType.dropdown ||
      this == AttributeValueType.multiselect;
}

class Attribute {
  const Attribute({
    required this.id,
    required this.name,
    required this.code,
    required this.valueType,
    this.description,
    this.unitLabel,
    this.allowedUnitLabels = const <String>[],
    this.sortOrder = 0,
    this.isFilterable = true,
    this.minLength,
    this.maxLength,
    this.inputPattern,
    this.minValue,
    this.maxValue,
    this.decimalPlaces,
  });

  final String id;
  final String name;
  final String code;
  final AttributeValueType valueType;
  final String? description;
  final String? unitLabel;
  final List<String> allowedUnitLabels;
  final int sortOrder;
  final bool isFilterable;
  final int? minLength;
  final int? maxLength;
  final String? inputPattern;
  final num? minValue;
  final num? maxValue;
  final int? decimalPlaces;

  List<String> get effectiveUnitLabels {
    if (allowedUnitLabels.isNotEmpty) {
      return List<String>.unmodifiable(allowedUnitLabels);
    }
    if (unitLabel != null && unitLabel!.trim().isNotEmpty) {
      return List<String>.unmodifiable(<String>[unitLabel!.trim()]);
    }
    return const <String>[];
  }

  Attribute copyWith({
    String? id,
    String? name,
    String? code,
    AttributeValueType? valueType,
    Object? description = _sentinel,
    Object? unitLabel = _sentinel,
    List<String>? allowedUnitLabels,
    int? sortOrder,
    bool? isFilterable,
    Object? minLength = _sentinel,
    Object? maxLength = _sentinel,
    Object? inputPattern = _sentinel,
    Object? minValue = _sentinel,
    Object? maxValue = _sentinel,
    Object? decimalPlaces = _sentinel,
  }) {
    return Attribute(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      valueType: valueType ?? this.valueType,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      unitLabel: identical(unitLabel, _sentinel)
          ? this.unitLabel
          : unitLabel as String?,
      allowedUnitLabels: allowedUnitLabels ?? this.allowedUnitLabels,
      sortOrder: sortOrder ?? this.sortOrder,
      isFilterable: isFilterable ?? this.isFilterable,
      minLength:
          identical(minLength, _sentinel) ? this.minLength : minLength as int?,
      maxLength:
          identical(maxLength, _sentinel) ? this.maxLength : maxLength as int?,
      inputPattern: identical(inputPattern, _sentinel)
          ? this.inputPattern
          : inputPattern as String?,
      minValue:
          identical(minValue, _sentinel) ? this.minValue : minValue as num?,
      maxValue:
          identical(maxValue, _sentinel) ? this.maxValue : maxValue as num?,
      decimalPlaces: identical(decimalPlaces, _sentinel)
          ? this.decimalPlaces
          : decimalPlaces as int?,
    );
  }
}

const Object _sentinel = Object();
