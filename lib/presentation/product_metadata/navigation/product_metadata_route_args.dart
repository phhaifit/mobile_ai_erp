class CategoriesArgs {
  const CategoriesArgs({this.parentCategoryId, this.initialTabIndex});

  final String? parentCategoryId;
  final int? initialTabIndex;
}

class CategoryFormArgs {
  const CategoryFormArgs({
    this.categoryId,
    this.initialParentId,
  });

  final String? categoryId;
  final String? initialParentId;
}

class CategoryDetailArgs {
  const CategoryDetailArgs({
    required this.categoryId,
  });

  final String categoryId;
}

class AttributesArgs {
  const AttributesArgs();
}

class AttributeFormArgs {
  const AttributeFormArgs({
    this.attributeId,
  });

  final String? attributeId;
}

class AttributeDetailArgs {
  const AttributeDetailArgs({
    required this.attributeId,
  });

  final String attributeId;
}

class AttributeOptionsArgs {
  const AttributeOptionsArgs({
    required this.attributeId,
  });

  final String attributeId;
}

class AttributeOptionFormArgs {
  const AttributeOptionFormArgs({
    required this.attributeId,
    this.attributeOptionId,
  });

  final String attributeId;
  final String? attributeOptionId;
}

class BrandFormArgs {
  const BrandFormArgs({this.brandId});

  final String? brandId;
}

class BrandDetailArgs {
  const BrandDetailArgs({required this.brandId});

  final String brandId;
}

class TagFormArgs {
  const TagFormArgs({this.tagId});

  final String? tagId;
}

class TagDetailArgs {
  const TagDetailArgs({required this.tagId});

  final String tagId;
}

class UnitFormArgs {
  const UnitFormArgs({this.unitId});

  final String? unitId;
}

class UnitDetailArgs {
  const UnitDetailArgs({required this.unitId});

  final String unitId;
}
