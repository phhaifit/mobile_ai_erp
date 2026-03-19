import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit_group.dart';

class ProductMetadataDataSource {
  final List<Category> _categories = <Category>[
    const Category(
      id: 'cat_fashion',
      name: 'Fashion',
      code: 'fashion',
      slug: 'fashion',
      sortOrder: 10,
    ),
    const Category(
      id: 'cat_women',
      name: 'Women',
      code: 'women',
      slug: 'women',
      parentId: 'cat_fashion',
      sortOrder: 10,
    ),
    const Category(
      id: 'cat_dresses',
      name: 'Dresses',
      code: 'dresses',
      slug: 'dresses',
      parentId: 'cat_women',
      sortOrder: 10,
    ),
    const Category(
      id: 'cat_electronics',
      name: 'Electronics',
      code: 'electronics',
      slug: 'electronics',
      sortOrder: 20,
    ),
    const Category(
      id: 'cat_accessories',
      name: 'Accessories',
      code: 'accessories',
      slug: 'accessories',
      parentId: 'cat_electronics',
      sortOrder: 10,
    ),
  ];

  final List<Attribute> _attributes = <Attribute>[
    const Attribute(
      id: 'attr_color',
      name: 'Color',
      code: 'color',
      valueType: AttributeValueType.dropdown,
      sortOrder: 10,
    ),
    const Attribute(
      id: 'attr_size',
      name: 'Size',
      code: 'size',
      valueType: AttributeValueType.multiselect,
      sortOrder: 20,
    ),
    const Attribute(
      id: 'attr_material',
      name: 'Material',
      code: 'material',
      valueType: AttributeValueType.text,
      sortOrder: 30,
      maxLength: 100,
    ),
    const Attribute(
      id: 'attr_weight',
      name: 'Weight',
      code: 'weight',
      valueType: AttributeValueType.number,
      unitGroup: UnitGroup.weight,
      sortOrder: 40,
      isFilterable: false,
      minValue: 0,
      decimalPlaces: 2,
    ),
  ];

  final List<AttributeOption> _attributeOptions = <AttributeOption>[
    const AttributeOption(
      id: 'attr_option_color_black',
      attributeId: 'attr_color',
      value: 'Black',
      sortOrder: 10,
    ),
    const AttributeOption(
      id: 'attr_option_color_white',
      attributeId: 'attr_color',
      value: 'White',
      sortOrder: 20,
    ),
    const AttributeOption(
      id: 'attr_option_size_s',
      attributeId: 'attr_size',
      value: 'S',
      sortOrder: 10,
    ),
    const AttributeOption(
      id: 'attr_option_size_m',
      attributeId: 'attr_size',
      value: 'M',
      sortOrder: 20,
    ),
    const AttributeOption(
      id: 'attr_option_size_l',
      attributeId: 'attr_size',
      value: 'L',
      sortOrder: 30,
    ),
  ];

  final List<CategoryAttribute> _categoryAttributes = <CategoryAttribute>[
    const CategoryAttribute(
      id: 'cat_attr_dresses_color',
      categoryId: 'cat_dresses',
      attributeId: 'attr_color',
      isRequired: true,
      sortOrder: 10,
    ),
    const CategoryAttribute(
      id: 'cat_attr_dresses_size',
      categoryId: 'cat_dresses',
      attributeId: 'attr_size',
      isRequired: true,
      sortOrder: 20,
    ),
    const CategoryAttribute(
      id: 'cat_attr_dresses_material',
      categoryId: 'cat_dresses',
      attributeId: 'attr_material',
      sortOrder: 30,
    ),
    const CategoryAttribute(
      id: 'cat_attr_accessories_weight',
      categoryId: 'cat_accessories',
      attributeId: 'attr_weight',
      sortOrder: 10,
    ),
  ];

  final List<Unit> _units = <Unit>[
    const Unit(
      id: 'unit_g',
      code: 'g',
      name: 'Gram',
      symbol: 'g',
      unitGroup: UnitGroup.weight,
    ),
    const Unit(
      id: 'unit_kg',
      code: 'kg',
      name: 'Kilogram',
      symbol: 'kg',
      unitGroup: UnitGroup.weight,
    ),
    const Unit(
      id: 'unit_cm',
      code: 'cm',
      name: 'Centimeter',
      symbol: 'cm',
      unitGroup: UnitGroup.length,
    ),
  ];

  final List<Brand> _brands = <Brand>[
    const Brand(
      id: 'brand_nike',
      name: 'Nike',
      logoUrl: 'https://example.com/nike.png',
      countryCode: 'US',
      regionOrState: 'Oregon',
      city: 'Beaverton',
      sortOrder: 10,
    ),
    const Brand(
      id: 'brand_uniqlo',
      name: 'Uniqlo',
      countryCode: 'JP',
      regionOrState: 'Tokyo',
      city: 'Tokyo',
      sortOrder: 20,
    ),
    const Brand(
      id: 'brand_anker',
      name: 'Anker',
      countryCode: 'CN',
      regionOrState: 'Hunan',
      city: 'Changsha',
      sortOrder: 30,
    ),
  ];

  final List<Tag> _tags = <Tag>[
    const Tag(
      id: 'tag_best_seller',
      name: 'Best seller',
      description: 'Highlight products with strong sales performance.',
      colorHex: '#2E7D32',
      sortOrder: 10,
      status: TagStatus.active,
    ),
    const Tag(
      id: 'tag_hot_trend',
      name: 'Hot trend',
      description: 'Mark products that are currently trending.',
      colorHex: '#C62828',
      sortOrder: 20,
      status: TagStatus.reviewRequired,
    ),
    const Tag(
      id: 'tag_new_arrival',
      name: 'New arrival',
      description: 'Quick label for newly added products.',
      colorHex: '#1565C0',
      sortOrder: 30,
      status: TagStatus.active,
    ),
    const Tag(
      id: 'tag_limited_drop',
      name: 'Limited drop',
      description: 'Use for short-run or exclusive product drops.',
      colorHex: '#6A1B9A',
      sortOrder: 40,
      status: TagStatus.reviewRequired,
    ),
    const Tag(
      id: 'tag_hashtag_streetwear',
      name: '#streetwear',
      description: 'Hashtag-style tag for fast merchandising classification.',
      colorHex: '#37474F',
      sortOrder: 50,
      status: TagStatus.active,
    ),
    const Tag(
      id: 'tag_hashtag_summerlook',
      name: '#summerlook',
      description: 'Hashtag-style tag for seasonal lookbooks and campaigns.',
      colorHex: '#EF6C00',
      sortOrder: 60,
      status: TagStatus.active,
    ),
  ];

  Future<List<Category>> getCategories() async => _sortCategories(_categories);

  Future<Category> saveCategory(Category category) async {
    final name = category.name.trim();
    final code = category.code.trim();
    final parentId = _normalizeNullable(category.parentId);
    if (name.isEmpty) {
      throw const ProductMetadataValidationException(
          'Category name is required.');
    }
    if (code.isEmpty) {
      throw const ProductMetadataValidationException(
          'Category code is required.');
    }

    final categoryId = category.id.trim();
    final slug = _slugify(name);
    final hasDuplicateName = _categories.any(
      (existing) =>
          existing.id != categoryId &&
          _normalize(existing.name) == _normalize(name) &&
          _normalizeNullable(existing.parentId) == parentId,
    );
    if (hasDuplicateName) {
      throw const ProductMetadataValidationException(
        'Sibling category names must be unique.',
      );
    }
    final hasDuplicateCode = _categories.any(
      (existing) =>
          existing.id != categoryId &&
          _normalize(existing.code) == _normalize(code),
    );
    if (hasDuplicateCode) {
      throw const ProductMetadataValidationException(
          'Category codes must be unique.');
    }
    final hasDuplicateSlug = _categories.any(
      (existing) =>
          existing.id != categoryId &&
          _normalize(existing.slug) == _normalize(slug),
    );
    if (hasDuplicateSlug) {
      throw const ProductMetadataValidationException(
          'Category slugs must be unique.');
    }
    if (categoryId.isNotEmpty && parentId == categoryId) {
      throw const ProductMetadataValidationException(
        'A category cannot be its own parent.',
      );
    }
    if (categoryId.isNotEmpty &&
        parentId != null &&
        _isDescendant(candidateParentId: parentId, categoryId: categoryId)) {
      throw const ProductMetadataValidationException(
        'A category cannot move under one of its descendants.',
      );
    }

    final savedCategory = category.copyWith(
      id: categoryId.isEmpty ? _generateId('cat') : categoryId,
      name: name,
      code: code,
      slug: slug,
      parentId: parentId,
      description: _normalizeNullable(category.description),
      coverImageUrl: _normalizeNullable(category.coverImageUrl),
    );

    _upsertById(_categories, savedCategory, (item) => item.id);
    return savedCategory;
  }

  Future<void> deleteCategory(String categoryId) async {
    final hasChildren = _categories.any((item) => item.parentId == categoryId);
    if (hasChildren) {
      throw const ProductMetadataValidationException(
        'Delete child categories first.',
      );
    }
    _categoryAttributes.removeWhere((item) => item.categoryId == categoryId);
    _categories.removeWhere((item) => item.id == categoryId);
  }

  Future<List<Attribute>> getAttributes() async => _sortByOrderThenName(
      _attributes, (item) => item.name, (item) => item.sortOrder);

  Future<Attribute> saveAttribute(Attribute attribute) async {
    final name = attribute.name.trim();
    final code = attribute.code.trim();
    if (name.isEmpty) {
      throw const ProductMetadataValidationException(
          'Attribute name is required.');
    }
    if (code.isEmpty) {
      throw const ProductMetadataValidationException(
          'Attribute code is required.');
    }

    final attributeId = attribute.id.trim();
    final hasDuplicateName = _attributes.any(
      (existing) =>
          existing.id != attributeId &&
          _normalize(existing.name) == _normalize(name),
    );
    if (hasDuplicateName) {
      throw const ProductMetadataValidationException(
          'Attribute names must be unique.');
    }
    final hasDuplicateCode = _attributes.any(
      (existing) =>
          existing.id != attributeId &&
          _normalize(existing.code) == _normalize(code),
    );
    if (hasDuplicateCode) {
      throw const ProductMetadataValidationException(
          'Attribute codes must be unique.');
    }
    if (attribute.valueType != AttributeValueType.number &&
        attribute.unitGroup != null) {
      throw const ProductMetadataValidationException(
        'Only number attributes can use a unit group.',
      );
    }

    final savedAttribute = attribute.copyWith(
      id: attributeId.isEmpty ? _generateId('attr') : attributeId,
      name: name,
      code: code,
      inputPattern: _normalizeNullable(attribute.inputPattern),
      unitGroup: attribute.valueType == AttributeValueType.number
          ? attribute.unitGroup
          : null,
    );

    _upsertById(_attributes, savedAttribute, (item) => item.id);
    return savedAttribute;
  }

  Future<void> deleteAttribute(String attributeId) async {
    _attributes.removeWhere((item) => item.id == attributeId);
    _attributeOptions.removeWhere((item) => item.attributeId == attributeId);
    _categoryAttributes.removeWhere((item) => item.attributeId == attributeId);
  }

  Future<List<AttributeOption>> getAttributeOptions(String attributeId) async {
    final options = _attributeOptions
        .where((item) => item.attributeId == attributeId)
        .toList();
    return _sortByOrderThenName(
        options, (item) => item.value, (item) => item.sortOrder);
  }

  Future<Map<String, int>> getAttributeOptionCounts(
      List<String> attributeIds) async {
    final counts = <String, int>{for (final id in attributeIds) id: 0};
    for (final option in _attributeOptions) {
      if (counts.containsKey(option.attributeId)) {
        counts[option.attributeId] = (counts[option.attributeId] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<AttributeOption> saveAttributeOption(
      AttributeOption attributeOption) async {
    final value = attributeOption.value.trim();
    if (value.isEmpty) {
      throw const ProductMetadataValidationException(
          'Option value is required.');
    }

    final parent = _firstWhereOrNull(
      _attributes,
      (item) => item.id == attributeOption.attributeId,
    );
    if (parent == null) {
      throw const ProductMetadataValidationException('Attribute not found.');
    }
    if (!parent.valueType.supportsOptions) {
      throw const ProductMetadataValidationException(
        'Only dropdown or multiselect attributes can have options.',
      );
    }

    final optionId = attributeOption.id.trim();
    final hasDuplicate = _attributeOptions.any(
      (existing) =>
          existing.id != optionId &&
          existing.attributeId == attributeOption.attributeId &&
          _normalize(existing.value) == _normalize(value),
    );
    if (hasDuplicate) {
      throw const ProductMetadataValidationException(
        'Option values must be unique inside the attribute.',
      );
    }

    final savedOption = attributeOption.copyWith(
      id: optionId.isEmpty ? _generateId('attr_option') : optionId,
      value: value,
    );

    _upsertById(_attributeOptions, savedOption, (item) => item.id);
    return savedOption;
  }

  Future<void> deleteAttributeOption(String attributeOptionId) async {
    _attributeOptions.removeWhere((item) => item.id == attributeOptionId);
  }

  Future<List<CategoryAttribute>> getCategoryAttributes() async =>
      _sortByOrderThenName(
        _categoryAttributes,
        (item) => '${item.categoryId}_${item.attributeId}',
        (item) => item.sortOrder,
      );

  Future<CategoryAttribute> saveCategoryAttribute(
      CategoryAttribute item) async {
    final existsCategory =
        _categories.any((category) => category.id == item.categoryId);
    if (!existsCategory) {
      throw const ProductMetadataValidationException('Category not found.');
    }
    final existsAttribute =
        _attributes.any((attribute) => attribute.id == item.attributeId);
    if (!existsAttribute) {
      throw const ProductMetadataValidationException('Attribute not found.');
    }

    final relationId = item.id.trim();
    final hasDuplicate = _categoryAttributes.any(
      (existing) =>
          existing.id != relationId &&
          existing.categoryId == item.categoryId &&
          existing.attributeId == item.attributeId,
    );
    if (hasDuplicate) {
      throw const ProductMetadataValidationException(
        'This category already links to the selected attribute.',
      );
    }

    final saved = item.copyWith(
      id: relationId.isEmpty ? _generateId('cat_attr') : relationId,
    );
    _upsertById(_categoryAttributes, saved, (entry) => entry.id);
    return saved;
  }

  Future<void> deleteCategoryAttribute(String categoryAttributeId) async {
    _categoryAttributes.removeWhere((item) => item.id == categoryAttributeId);
  }

  Future<List<Unit>> getUnits() async =>
      _sortByOrderThenName(_units, (item) => item.name, (_) => null);

  Future<Unit> saveUnit(Unit unit) async {
    final code = unit.code.trim();
    final name = unit.name.trim();
    final symbol = unit.symbol.trim();
    if (code.isEmpty || name.isEmpty || symbol.isEmpty) {
      throw const ProductMetadataValidationException(
        'Unit code, name, and symbol are required.',
      );
    }

    final unitId = unit.id.trim();
    final hasDuplicateCode = _units.any(
      (existing) =>
          existing.id != unitId &&
          _normalize(existing.code) == _normalize(code),
    );
    if (hasDuplicateCode) {
      throw const ProductMetadataValidationException(
          'Unit codes must be unique.');
    }

    final saved = unit.copyWith(
      id: unitId.isEmpty ? _generateId('unit') : unitId,
      code: code,
      name: name,
      symbol: symbol,
    );
    _upsertById(_units, saved, (item) => item.id);
    return saved;
  }

  Future<void> deleteUnit(String unitId) async {
    _units.removeWhere((item) => item.id == unitId);
  }

  Future<List<Brand>> getBrands() async => _sortByOrderThenName(
      _brands, (item) => item.name, (item) => item.sortOrder);

  Future<Brand> saveBrand(Brand brand) async {
    final name = brand.name.trim();
    if (name.isEmpty) {
      throw const ProductMetadataValidationException('Brand name is required.');
    }

    final brandId = brand.id.trim();
    final hasDuplicateName = _brands.any(
      (existing) =>
          existing.id != brandId &&
          _normalize(existing.name) == _normalize(name),
    );
    if (hasDuplicateName) {
      throw const ProductMetadataValidationException(
          'Brand names must be unique.');
    }

    final normalizedCountry =
        _normalizeNullable(brand.countryCode)?.toUpperCase();
    final normalizedRegion = _normalizeNullable(brand.regionOrState);
    final normalizedCity = _normalizeNullable(brand.city);
    final hasDuplicateLocationTuple = _brands.any(
      (existing) =>
          existing.id != brandId &&
          _normalize(existing.name) == _normalize(name) &&
          _normalizeNullable(existing.countryCode)?.toUpperCase() ==
              normalizedCountry &&
          _normalizeNullable(existing.regionOrState) == normalizedRegion &&
          _normalizeNullable(existing.city) == normalizedCity,
    );
    if (hasDuplicateLocationTuple) {
      throw const ProductMetadataValidationException(
        'This brand already exists with the same location.',
      );
    }

    final saved = brand.copyWith(
      id: brandId.isEmpty ? _generateId('brand') : brandId,
      name: name,
      description: _normalizeNullable(brand.description),
      logoUrl: _normalizeNullable(brand.logoUrl),
      countryCode: normalizedCountry,
      regionOrState: normalizedRegion,
      city: normalizedCity,
    );
    _upsertById(_brands, saved, (item) => item.id);
    return saved;
  }

  Future<void> deleteBrand(String brandId) async {
    _brands.removeWhere((item) => item.id == brandId);
  }

  Future<List<Tag>> getTags() async => _sortByOrderThenName(
      _tags, (item) => item.name, (item) => item.sortOrder);

  Future<Tag> saveTag(Tag tag) async {
    final name = tag.name.trim();
    if (name.isEmpty) {
      throw const ProductMetadataValidationException('Tag name is required.');
    }

    final tagId = tag.id.trim();
    final hasDuplicateName = _tags.any(
      (existing) =>
          existing.id != tagId && _normalize(existing.name) == _normalize(name),
    );
    if (hasDuplicateName) {
      throw const ProductMetadataValidationException(
          'Tag names must be unique.');
    }

    final saved = tag.copyWith(
      id: tagId.isEmpty ? _generateId('tag') : tagId,
      name: name,
      description: _normalizeNullable(tag.description),
      colorHex: _normalizeNullable(tag.colorHex),
    );
    _upsertById(_tags, saved, (item) => item.id);
    return saved;
  }

  Future<void> deleteTag(String tagId) async {
    _tags.removeWhere((item) => item.id == tagId);
  }

  bool _isDescendant({
    required String candidateParentId,
    required String categoryId,
  }) {
    String? cursor = candidateParentId;
    while (cursor != null) {
      if (cursor == categoryId) {
        return true;
      }
      final found = _firstWhereOrNull(_categories, (item) => item.id == cursor);
      cursor = found?.parentId;
    }
    return false;
  }

  String _normalize(String value) => value.trim().toLowerCase();

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _slugify(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'category' : normalized;
  }

  String _generateId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }

  void _upsertById<T>(
    List<T> items,
    T value,
    String Function(T item) idSelector,
  ) {
    final index =
        items.indexWhere((item) => idSelector(item) == idSelector(value));
    if (index >= 0) {
      items[index] = value;
    } else {
      items.add(value);
    }
  }

  List<Category> _sortCategories(List<Category> source) {
    final items = List<Category>.from(source);
    items.sort((left, right) {
      final parentCompare =
          (left.parentId ?? '').compareTo(right.parentId ?? '');
      if (parentCompare != 0) {
        return parentCompare;
      }
      final orderCompare = left.sortOrder.compareTo(right.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return items;
  }

  List<T> _sortByOrderThenName<T>(
    List<T> source,
    String Function(T item) nameSelector,
    int? Function(T item) sortOrderSelector,
  ) {
    final items = List<T>.from(source);
    items.sort((left, right) {
      final orderCompare = (sortOrderSelector(left) ?? 999999)
          .compareTo(sortOrderSelector(right) ?? 999999);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return nameSelector(left)
          .toLowerCase()
          .compareTo(nameSelector(right).toLowerCase());
    });
    return items;
  }
}
