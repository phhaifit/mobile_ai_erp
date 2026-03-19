import 'package:mobile_ai_erp/data/local/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class ProductMetadataRepositoryImpl extends ProductMetadataRepository {
  ProductMetadataRepositoryImpl(this._dataSource);

  final ProductMetadataDataSource _dataSource;

  @override
  Future<List<Category>> getCategories() => _dataSource.getCategories();

  @override
  Future<Category> saveCategory(Category category) =>
      _dataSource.saveCategory(category);

  @override
  Future<void> deleteCategory(String categoryId) =>
      _dataSource.deleteCategory(categoryId);

  @override
  Future<List<Attribute>> getAttributes() => _dataSource.getAttributes();

  @override
  Future<Attribute> saveAttribute(Attribute attribute) =>
      _dataSource.saveAttribute(attribute);

  @override
  Future<void> deleteAttribute(String attributeId) =>
      _dataSource.deleteAttribute(attributeId);

  @override
  Future<List<AttributeOption>> getAttributeOptions(String attributeId) =>
      _dataSource.getAttributeOptions(attributeId);

  @override
  Future<Map<String, int>> getAttributeOptionCounts(
          List<String> attributeIds) =>
      _dataSource.getAttributeOptionCounts(attributeIds);

  @override
  Future<AttributeOption> saveAttributeOption(
          AttributeOption attributeOption) =>
      _dataSource.saveAttributeOption(attributeOption);

  @override
  Future<void> deleteAttributeOption(String attributeOptionId) =>
      _dataSource.deleteAttributeOption(attributeOptionId);

  @override
  Future<List<CategoryAttribute>> getCategoryAttributes() =>
      _dataSource.getCategoryAttributes();

  @override
  Future<CategoryAttribute> saveCategoryAttribute(CategoryAttribute item) =>
      _dataSource.saveCategoryAttribute(item);

  @override
  Future<void> deleteCategoryAttribute(String categoryAttributeId) =>
      _dataSource.deleteCategoryAttribute(categoryAttributeId);

  @override
  Future<List<Brand>> getBrands() => _dataSource.getBrands();

  @override
  Future<Brand> saveBrand(Brand brand) => _dataSource.saveBrand(brand);

  @override
  Future<void> deleteBrand(String brandId) => _dataSource.deleteBrand(brandId);

  @override
  Future<List<Tag>> getTags() => _dataSource.getTags();

  @override
  Future<Tag> saveTag(Tag tag) => _dataSource.saveTag(tag);

  @override
  Future<void> deleteTag(String tagId) => _dataSource.deleteTag(tagId);
}
