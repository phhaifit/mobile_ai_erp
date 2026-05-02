import 'dart:developer';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobx/mobx.dart';

part 'product_form_store.g.dart';

class ProductFormStore = _ProductFormStore with _$ProductFormStore;

abstract class _ProductFormStore with Store {
  final String TAG = "_ProductFormStore";
  
  // Constants for validation
  static const int MAX_PRODUCT_NAME_LENGTH = 100;

  // repository instance
  final ProductManagementRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  @observable
  String name = ""; // internal product name

  @observable
  String sku = "";

  @observable
  String? barcode;

  @observable
  String price = ""; // base price

  @observable
  String? sellingPrice;

  @observable
  String description = ""; // internal product description

  @observable
  String? webTitle; // product name (title) displayed to customers

  @observable
  String? webDescription; // product description displayed to customers and for SEO

  @observable
  ProductStatus status = ProductStatus.ACTIVE;

  @observable
  String? categoryId; // category ID of product (UUID string from backend). product can have no category (send null)

  @observable
  String? brandId; // brand ID of product (UUID string from backend). product can have no brand (send null)

  @observable
  String? warrantyMonths; // warranty time for product, in months

  @observable
  String? weight;

  @observable
  String? weightUnitId;

  @observable
  List<String> tagIds = [];

  @observable
  List<String> imageUrls = [];

  @observable
  bool isSubmitting = false;

  @observable
  bool success = false;

  @observable
  Product? editingProduct;
  
  // Validation errors
  @observable
  String nameError = "";

  @observable
  String skuError = "";

  @observable
  String priceError = "";

  // @observable
  // String sellingPriceError = "";

  @observable
  String categoryBrandError = "";

  @observable
  String weightError = "";

  @observable
  String weightUnitError = "";

  // computed:------------------------------------------------------------------
  @computed
  bool get isFormValid {
    return nameError.isEmpty &&
        skuError.isEmpty &&
        priceError.isEmpty &&
        categoryBrandError.isEmpty &&
        name.isNotEmpty &&
        sku.isNotEmpty;
  }

  @computed
  bool get isEditing => editingProduct != null;

  // constructor:---------------------------------------------------------------
  _ProductFormStore(this._repository, this.errorStore);

  // actions:-------------------------------------------------------------------
  
  /// Fast validation function - validates all form fields (no async calls)
  /// Called on every input change and during form submission
  @action
  void validateForm() {
    // Validate name
    if (name.isEmpty) {
      nameError = 'Product name is required';
    } else if (name.length > MAX_PRODUCT_NAME_LENGTH) {
      nameError =
          'Product name exceeds maximum length of $MAX_PRODUCT_NAME_LENGTH characters';
    } else {
      nameError = "";
    }

    // Validate SKU (required field only, uniqueness checked separately in submitForm)
    if (sku.isEmpty) {
      skuError = 'SKU is required';
    } else {
      skuError = "";
    }

    // Validate price
    if (price.isEmpty) {
      priceError = 'Price is required';
    } else {
      final parsedPrice = double.tryParse(price);
      if (parsedPrice == null) {
        priceError = 'Price must be a valid number';
      } else if (parsedPrice < 0) {
        priceError = 'Price cannot be negative';
      } else if (parsedPrice == 0) {
        priceError = 'Price must be greater than 0';
      } else if (!RegExp(r'^\d+(\.(\d{1,2})?)?$').hasMatch(price)) {
        priceError = 'Only up to 2 decimal places allowed';
      } else {
        priceError = "";
      }
    }

    // Validate selling price
    // if (sellingPrice != null && sellingPrice!.isNotEmpty) {
    //   final parsedSellingPrice = double.tryParse(sellingPrice!);
    //   if (parsedSellingPrice == null || parsedSellingPrice < 0) {
    //     sellingPriceError = "Selling price must not be negative";
    //   }
    // } else {
    //   sellingPriceError = "";
    // }


    // Validate weight and unit
    weightError = "";
    weightUnitError = "";
    if (weight != null && weight!.isNotEmpty) {
      if (weightUnitId == null) { // weight unit only required if weight is provided, unit is dropped if weight is empty
        weightUnitError = 'Please select a weight unit.';
      }

      final parsedWeight = double.tryParse(weight!);
      if (parsedWeight == null || parsedWeight <= 0) {
        weightError = 'Weight must be greater than 0.';
      }
      log(weightError + " " + weightUnitError);
    }
    log('Validating weight: weight="$weight", weightUnitId="$weightUnitId"', name: TAG);

  }

  /// Check SKU uniqueness - only called during form submission
  /// This is separated because it requires an async call to the repository
  @action
  Future<void> _validateSkuUniqueness() async {
    if (sku.isEmpty) {
      skuError = 'SKU is required';
      return;
    }

    try {
      final products = await _repository.getProducts();
      bool isDuplicate = false;
      for (final p in products) {
        if (editingProduct != null && p.id == editingProduct!.id) {
          continue; // Skip the current product if editing
        }
        if (p.sku.toUpperCase() == sku.toUpperCase()) {
          isDuplicate = true;
          break;
        }
      }
      skuError = isDuplicate ? 'SKU already exists. Please use a unique SKU.' : "";
    } catch (e) {
      skuError = ""; // Keep current SKU if validation fails
    }
  }

  @action
  void setName(String value) {
    name = value;
    validateForm();
  }

  @action
  void setSku(String value) {
    sku = value;
    validateForm();
  }

  @action
  void setPrice(String value) {
    price = value;
    validateForm();
  }

  @action
  void setDescription(String value) {
    description = value;
    validateForm();
  }

  @action
  void setStatus(ProductStatus value) {
    status = value;
    validateForm();
  }

  @action
  void setCategoryId(String? value) {
    categoryId = value;
    validateForm();
  }

  @action
  void setBrandId(String? value) {
    brandId = value;
    validateForm();
  }

  @action
  void setTagIds(List<String> value) {
    tagIds = value;
    validateForm();
  }

  @action
  void setImageUrls(List<String> value) {
    imageUrls = value;
    validateForm();
  }

  @action
  void addImageUrl(String url) {
    imageUrls.add(url);
    imageUrls = List.from(imageUrls); // Trigger update
    validateForm();
  }

  @action
  void removeImageUrl(int index) {
    if (index >= 0 && index < imageUrls.length) {
      imageUrls.removeAt(index);
      imageUrls = List.from(imageUrls); // Trigger update
      validateForm();
    }
  }

  @action
  void toggleTag(String tagId) {
    if (tagIds.contains(tagId)) {
      tagIds.remove(tagId);
    } else {
      tagIds.add(tagId);
    }
    tagIds = List.from(tagIds); // Trigger update
    validateForm();
  }

  @action
  void setBarcode(String value) {
    barcode = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setSellingPrice(String value) {
    sellingPrice = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWebTitle(String value) {
    webTitle = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWebDescription(String value) {
    webDescription = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWarranteeMonths(String value) {
    warrantyMonths = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWeight(String value) {
    weight = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWeightUnitId(String? value) {
    weightUnitId = value;
    validateForm();
  }

  @action
  void initializeForEdit(Product product) {
    editingProduct = product;
    name = product.name;
    sku = product.sku;
    price = product.basePrice.toString();
    description = product.description ?? "";
    status = product.status;
    categoryId = product.categoryId;
    brandId = product.brandId;
    // Product model now stores images as `images` and tags as `Tag` objects.
    // For now, keep existing UI lists in store but map from new fields where possible.
    tagIds = [];
    imageUrls = List.from(product.images);
    sellingPrice = product.sellingPrice.toString();
    // barcode = product.barcode;
    // sellingPrice = product.sellingPrice;
    // webTitle = product.webTitle;
    // webDescription = product.webDescription;
    warrantyMonths = product.warrantyMonths?.toString();
    // weight and weight unit handling omitted (conversion needed)
    
    // Clear validation errors when initializing for edit
    nameError = "";
    skuError = "";
    priceError = "";
    categoryBrandError = "";
  }

  @action
  Future<Product?> submitForm() async {
    isSubmitting = true;

    var result = null;
    try {
      // Run fast validation
      validateForm();

      // Check basic form validity (before expensive async checks)
      if (!isFormValid) {
        success = false;
        return null;
      }

      // Check SKU uniqueness (expensive async call)
      await _validateSkuUniqueness();

      // Re-check form validity after SKU uniqueness check
      if (!isFormValid) {
        success = false;
        return null;
      }

      // Create product and submit
      final parsedPrice = double.parse(price); // Safe to parse since validation passed
      final parsedSelling = (sellingPrice != null && sellingPrice!.isNotEmpty)
          ? double.tryParse(sellingPrice!)
          : null;

      result = Product(
        id: editingProduct?.id,
        name: name,
        sku: sku,
        description: description,
        type: ProductType.standalone,
        status: status,
        warrantyMonths: warrantyMonths != null ? int.tryParse(warrantyMonths!) : null,
        basePrice: parsedPrice,
        sellingPrice: parsedSelling ?? parsedPrice,
        categoryId: categoryId,
        brandId: brandId,
        images: imageUrls,
        tags: const <Tag>[],
        createdAt: editingProduct?.createdAt,
      );

      if (isEditing) {
        await _repository.updateProduct(result);
      } else {
        await _repository.createProduct(result);
        reset();
      }

      success = true;
    } catch (error) {
      errorStore.errorMessage = error.toString();
      success = false;
      result = null;
    } finally {
      isSubmitting = false;
    }
    return result;
  }

  @action
  void reset() {
    name = "";
    sku = "";
    price = "";
    description = "";
    barcode = null;
    sellingPrice = null;
    webTitle = null;
    webDescription = null;
    warrantyMonths = null;
    weight = null;
    weightUnitId = null;
    status = ProductStatus.ACTIVE;
    categoryId = null;
    brandId = null;
    tagIds = [];
    imageUrls = [];
    editingProduct = null;
    success = false;
    nameError = "";
    skuError = "";
    priceError = "";
    categoryBrandError = "";
  }

  // dispose:-------------------------------------------------------------------
  void dispose() {}
}
