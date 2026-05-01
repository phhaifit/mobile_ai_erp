import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobx/mobx.dart';

part 'product_metadata_store.g.dart';

class ProductMetadataStore = ProductMetadataStoreBase
    with _$ProductMetadataStore;

abstract class ProductMetadataStoreBase with Store {
  ProductMetadataStoreBase(this._repository, this.errorStore);

  final ProductMetadataRepository _repository;
  final ErrorStore errorStore;

  @observable
  bool isLoading = false;

  @observable
  bool hasLoadedDashboard = false;

  @observable
  ObservableList<Category> categories = ObservableList<Category>();

  @observable
  ObservableList<Attribute> attributes = ObservableList<Attribute>();

  @observable
  ObservableList<AttributeOption> attributeOptions =
      ObservableList<AttributeOption>();

  @observable
  ObservableMap<String, int> attributeOptionCounts =
      ObservableMap<String, int>();

  @observable
  ObservableList<CategoryAttribute> categoryAttributes =
      ObservableList<CategoryAttribute>();

  @observable
  ObservableList<Brand> brands = ObservableList<Brand>();

  @observable
  ObservableList<Tag> tags = ObservableList<Tag>();

  @observable
  String? activeAttributeId;

  @action
  Future<void> loadDashboard({bool force = false}) async {
    if (hasLoadedDashboard && !force) {
      return;
    }

    await _runWithLoading(() async {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getCategories(),
        _repository.getAttributes(),
        _repository.getCategoryAttributes(),
        _repository.getBrands(),
        _repository.getTags(),
      ]);

      categories = ObservableList<Category>.of(results[0] as List<Category>);
      attributes = ObservableList<Attribute>.of(results[1] as List<Attribute>);
      categoryAttributes = ObservableList<CategoryAttribute>.of(
          results[2] as List<CategoryAttribute>);
      brands = ObservableList<Brand>.of(results[3] as List<Brand>);
      tags = ObservableList<Tag>.of(results[4] as List<Tag>);
      attributeOptionCounts = ObservableMap<String, int>.of(
        await _repository.getAttributeOptionCounts(
          attributes.map((attribute) => attribute.id).toList(),
        ),
      );
      hasLoadedDashboard = true;
      errorStore.errorMessage = '';
    });
  }

  @action
  Future<void> loadAttributes() async {
    activeAttributeId = null;
    await _runWithLoading(() async {
      final loadedAttributes = await _repository.getAttributes();
      attributes = ObservableList<Attribute>.of(loadedAttributes);
      attributeOptionCounts = ObservableMap<String, int>.of(
        await _repository.getAttributeOptionCounts(
          loadedAttributes.map((attribute) => attribute.id).toList(),
        ),
      );
      attributeOptions.clear();
      errorStore.errorMessage = '';
    });
  }

  @action
  Future<void> loadAttributeOptions(String attributeId) async {
    activeAttributeId = attributeId;
    await _runWithLoading(() async {
      final loadedOptions = await _repository.getAttributeOptions(attributeId);
      attributeOptions = ObservableList<AttributeOption>.of(loadedOptions);
      errorStore.errorMessage = '';
    });
  }

  @action
  Future<void> saveCategory(Category category) async {
    await _repository.saveCategory(category);
    categories = ObservableList<Category>.of((await _repository.getCategories()).categories);
  }

  @action
  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    categories.removeWhere((category) => category.id == categoryId);
    categoryAttributes.removeWhere((item) => item.categoryId == categoryId);
  }

  @action
  Future<void> saveAttribute(Attribute attribute) async {
    final savedAttribute = await _repository.saveAttribute(attribute);
    _upsertAttribute(savedAttribute);
    if (savedAttribute.valueType.supportsOptions) {
      attributeOptionCounts.putIfAbsent(savedAttribute.id, () => 0);
    } else {
      attributeOptionCounts.remove(savedAttribute.id);
    }
  }

  @action
  Future<void> deleteAttribute(String attributeId) async {
    await _repository.deleteAttribute(attributeId);
    attributes.removeWhere((attribute) => attribute.id == attributeId);
    attributeOptionCounts.remove(attributeId);
    categoryAttributes.removeWhere((item) => item.attributeId == attributeId);
    if (activeAttributeId == attributeId) {
      activeAttributeId = null;
      attributeOptions.clear();
    }
  }

  @action
  Future<void> saveAttributeOption(AttributeOption attributeOption) async {
    final savedOption = await _repository.saveAttributeOption(attributeOption);
    if (activeAttributeId == savedOption.attributeId) {
      _upsertAttributeOption(savedOption);
    }
    await _refreshAttributeOptionCount(savedOption.attributeId);
  }

  @action
  Future<void> deleteAttributeOption(String attributeOptionId) async {
    String? affectedAttributeId;
    for (final option in attributeOptions) {
      if (option.id == attributeOptionId) {
        affectedAttributeId = option.attributeId;
        break;
      }
    }
    await _repository.deleteAttributeOption(attributeOptionId);
    attributeOptions.removeWhere((option) => option.id == attributeOptionId);
    if (affectedAttributeId != null) {
      await _refreshAttributeOptionCount(affectedAttributeId);
    }
  }

  @action
  Future<void> saveCategoryAttribute(CategoryAttribute item) async {
    final saved = await _repository.saveCategoryAttribute(item);
    _upsertCategoryAttribute(saved);
  }

  @action
  Future<void> deleteCategoryAttribute(String categoryAttributeId) async {
    await _repository.deleteCategoryAttribute(categoryAttributeId);
    categoryAttributes.removeWhere((item) => item.id == categoryAttributeId);
  }

  @action
  Future<void> saveBrand(Brand brand) async {
    final savedBrand = await _repository.saveBrand(brand);
    _upsertBrand(savedBrand);
  }

  @action
  Future<void> deleteBrand(String brandId) async {
    await _repository.deleteBrand(brandId);
    brands.removeWhere((brand) => brand.id == brandId);
  }

  @action
  Future<void> saveTag(Tag tag) async {
    final savedTag = await _repository.saveTag(tag);
    _upsertTag(savedTag);
  }

  @action
  Future<void> deleteTag(String tagId) async {
    await _repository.deleteTag(tagId);
    tags.removeWhere((tag) => tag.id == tagId);
  }

  List<Category> childrenOf(String? parentId) {
    final items =
        categories.where((category) => category.parentId == parentId).toList();
    items.sort((left, right) {
      final orderCompare = left.sortOrder.compareTo(right.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return items;
  }

  Category? findCategoryById(String? id) =>
      _findById(categories, id, (item) => item.id);

  Brand? findBrandById(String? id) => _findById(brands, id, (item) => item.id);

  Tag? findTagById(String? id) => _findById(tags, id, (item) => item.id);

  Attribute? findAttributeById(String? id) =>
      _findById(attributes, id, (item) => item.id);

  List<CategoryAttribute> categoryAttributesForCategory(String categoryId) {
    final items = categoryAttributes
        .where((item) => item.categoryId == categoryId)
        .toList()
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return items;
  }

  int optionCountForAttribute(String attributeId) =>
      attributeOptionCounts[attributeId] ?? 0;

  @action
  Future<void> _runWithLoading(Future<void> Function() callback) async {
    isLoading = true;
    try {
      await callback();
    } catch (error) {
      errorStore.errorMessage = error.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  void _upsertCategory(Category category) {
    _upsert<Category>(
      list: categories,
      item: category,
      idSelector: (item) => item.id,
      compare: (left, right) {
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
      },
    );
  }

  @action
  void _upsertAttribute(Attribute attribute) {
    _upsert<Attribute>(
      list: attributes,
      item: attribute,
      idSelector: (item) => item.id,
      compare: (left, right) {
        final orderCompare = left.sortOrder.compareTo(right.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      },
    );
  }

  @action
  void _upsertAttributeOption(AttributeOption attributeOption) {
    _upsert<AttributeOption>(
      list: attributeOptions,
      item: attributeOption,
      idSelector: (item) => item.id,
      compare: (left, right) {
        final orderCompare = left.sortOrder.compareTo(right.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.value.toLowerCase().compareTo(right.value.toLowerCase());
      },
    );
  }

  @action
  void _upsertCategoryAttribute(CategoryAttribute item) {
    _upsert<CategoryAttribute>(
      list: categoryAttributes,
      item: item,
      idSelector: (entry) => entry.id,
      compare: (left, right) {
        final categoryCompare = left.categoryId.compareTo(right.categoryId);
        if (categoryCompare != 0) {
          return categoryCompare;
        }
        final orderCompare = left.sortOrder.compareTo(right.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.attributeId.compareTo(right.attributeId);
      },
    );
  }

  @action
  void _upsertBrand(Brand brand) {
    _upsert<Brand>(
      list: brands,
      item: brand,
      idSelector: (item) => item.id,
      compare: (left, right) {
        final orderCompare = left.sortOrder.compareTo(right.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      },
    );
  }

  @action
  void _upsertTag(Tag tag) {
    _upsert<Tag>(
      list: tags,
      item: tag,
      idSelector: (item) => item.id,
      compare: (left, right) {
        final orderCompare = left.sortOrder.compareTo(right.sortOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      },
    );
  }

  @action
  void _upsert<T>({
    required ObservableList<T> list,
    required T item,
    required String Function(T item) idSelector,
    required int Function(T left, T right) compare,
  }) {
    final index =
        list.indexWhere((existing) => idSelector(existing) == idSelector(item));
    if (index >= 0) {
      list[index] = item;
    } else {
      list.add(item);
    }
    final sorted = list.toList()..sort(compare);
    list
      ..clear()
      ..addAll(sorted);
  }

  T? _findById<T>(
    Iterable<T> items,
    String? id,
    String Function(T item) idSelector,
  ) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final item in items) {
      if (idSelector(item) == id) {
        return item;
      }
    }
    return null;
  }

  @action
  Future<void> _refreshAttributeOptionCount(String attributeId) async {
    final counts =
        await _repository.getAttributeOptionCounts(<String>[attributeId]);
    attributeOptionCounts[attributeId] = counts[attributeId] ?? 0;
  }
}
