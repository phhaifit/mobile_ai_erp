import 'package:mobile_ai_erp/data/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/product_metadata/product_metadata_datasource.dart';
// import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
// import 'package:mobile_ai_erp/data/network/rest_client.dart';
// import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_list_response.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_list_response.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class ProductMetadataRepositoryImpl extends ProductMetadataRepository {
  ProductMetadataRepositoryImpl(this._dataSource);
  ProductMetadataRepositoryImpl.init() :
    _dataSource = ProductMetadataDataSource();

  final ProductMetadataDataSource _dataSource; // mock source, remove later

  final ProductMetadataDatasource _metadataSource  = ProductMetadataDatasource(); // network source

  @override
  Future<CategoryListResponse> getCategories({int? page, int? pageSize, String? search, bool? isActive}) {
    final queryParameters = <String, String>{};
    if (page != null) queryParameters['page'] = page.toString();
    if (pageSize != null) queryParameters['pageSize'] = pageSize.toString();
    if (search != null) queryParameters['search'] = search;
    if (isActive != null) queryParameters['isActive'] = isActive.toString();

    return _metadataSource.getCategories(queryParameters);
  }

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
  Future<BrandListResponse> getBrands({int? page, int? pageSize, String? search, bool? isActive}) {
    final queryParameters = <String, String>{};
    if (page != null) queryParameters['page'] = page.toString();
    if (pageSize != null) queryParameters['pageSize'] = pageSize.toString();
    if (search != null) queryParameters['search'] = search;
    if (isActive != null) queryParameters['isActive'] = isActive.toString();

    return _metadataSource.getBrands(queryParameters);
  }

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
