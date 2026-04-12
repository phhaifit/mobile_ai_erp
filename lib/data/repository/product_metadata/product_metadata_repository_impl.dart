import 'package:mobile_ai_erp/data/network/apis/product_metadata/metadata_api_client.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class ProductMetadataRepositoryImpl extends ProductMetadataRepository {
  ProductMetadataRepositoryImpl(this._apiClient);

  final MetadataApiClient _apiClient;

  @override
  Future<List<Category>> getCategories() => _apiClient.categories
      .getCategories()
      .then((page) => page.items);

  @override
  Future<List<Category>> getCategoryTree() => _apiClient.categories.getCategoryTree();

  @override
  Future<Category> getCategoryById(String categoryId) =>
      _apiClient.categories.getCategoryById(categoryId);

  @override
  Future<Category> saveCategory(Category category) =>
      _apiClient.categories.saveCategory(category);

  @override
  Future<void> deleteCategory(String categoryId) =>
      _apiClient.categories.deleteCategory(categoryId);

  @override
  Future<List<AttributeSet>> getAttributeSets() => _apiClient.attributeSets
      .getAttributeSets()
      .then((page) => page.items);

  @override
  Future<AttributeSet> getAttributeSetById(String attributeSetId) =>
      _apiClient.attributeSets.getAttributeSetById(attributeSetId);

  @override
  Future<AttributeSet> saveAttributeSet(AttributeSet attributeSet) =>
      _apiClient.attributeSets.saveAttributeSet(attributeSet);

  @override
  Future<void> deleteAttributeSet(String attributeSetId) =>
      _apiClient.attributeSets.deleteAttributeSet(attributeSetId);

  @override
  Future<List<AttributeValue>> getAttributeValues(String attributeSetId) =>
      _apiClient.attributeSets.getAttributeSetById(attributeSetId).then(
            (attributeSet) => attributeSet.values,
          );

  @override
  Future<List<AttributeValue>> getAllAttributeValues() =>
      _apiClient.attributeSets.getAllAttributeValues();

  @override
  Future<Map<String, int>> getAttributeValueCounts(
      List<String> attributeSetIds) async {
    if (attributeSetIds.isEmpty) {
      return <String, int>{};
    }

    // Parallelize API calls using Future.wait() instead of sequential awaits
    // Reduces total time from O(N*latency) to O(latency) by firing all requests simultaneously
    final futures = attributeSetIds.map(
      (attributeSetId) => _apiClient.attributeSets
          .getAttributeSetById(attributeSetId)
          .then(
            (attributeSet) => MapEntry(attributeSetId, attributeSet.values.length),
          )
          .catchError(
            // If attribute set not found or error, count as 0
            (dynamic _) => MapEntry(attributeSetId, 0),
          ),
    );

    final results = await Future.wait(futures);
    return <String, int>{for (final entry in results) entry.key: entry.value};
  }

  @override
  Future<AttributeValue> saveAttributeValue(
      AttributeValue attributeValue) =>
      _apiClient.attributeSets.saveAttributeValue(attributeValue);

  @override
  Future<void> deleteAttributeOption(String attributeSetId, String optionId) =>
      _apiClient.attributeSets.deleteAttributeOption(attributeSetId, optionId);

  @override
  Future<MetadataPage<Brand>> getBrands({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool includeInactive = false,
  }) =>
      _apiClient.brands.getBrands(
        page: page,
        pageSize: pageSize,
        search: search,
        includeInactive: includeInactive,
      );

  @override
  Future<Brand> getBrandById(String brandId) => _apiClient.brands.getBrandById(brandId);

  @override
  Future<Brand> saveBrand(Brand brand) => _apiClient.brands.saveBrand(brand);

  @override
  Future<void> deleteBrand(String brandId) => _apiClient.brands.deleteBrand(brandId);

  @override
  Future<List<Tag>> getTags() => _apiClient.tags
      .getTags()
      .then((page) => page.items);

  @override
  Future<Tag> getTagById(String tagId) => _apiClient.tags.getTagById(tagId);

  @override
  Future<Tag> saveTag(Tag tag) => _apiClient.tags.saveTag(tag);

  @override
  Future<void> deleteTag(String tagId) => _apiClient.tags.deleteTag(tagId);

  @override
  Future<List<Unit>> getUnits({bool includeInactive = false}) => _apiClient.units
      .getUnits(includeInactive: includeInactive)
      .then((page) => page.items);

  @override
  Future<Unit> getUnitById(String unitId) => _apiClient.units.getUnitById(unitId);

  @override
  Future<Unit> saveUnit(Unit unit) => _apiClient.units.saveUnit(unit);

  @override
  Future<void> deleteUnit(String unitId) => _apiClient.units.deleteUnit(unitId);
}
