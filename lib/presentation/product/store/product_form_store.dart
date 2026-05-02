import 'package:flutter/cupertino.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
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
  String name = "";

  @observable
  String sku = "";

  @observable
  String price = "";

  @observable
  String description = "";

  @observable
  ProductStatus status = ProductStatus.ACTIVE;

  @observable
  int categoryId = 1;

  @observable
  int brandId = 1;

  @observable
  List<int> tagIds = [];

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

  @observable
  String categoryBrandError = "";

  // computed:------------------------------------------------------------------
  @computed
  bool get isFormValid {
    return nameError.isEmpty &&
        skuError.isEmpty &&
        priceError.isEmpty &&
        categoryBrandError.isEmpty &&
        name.isNotEmpty &&
        sku.isNotEmpty &&
        categoryId > 0 &&
        brandId > 0;
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

    // Validate category and brand
    if (categoryId <= 0 || brandId <= 0) {
      categoryBrandError = 'Please select a category and brand';
    } else {
      categoryBrandError = "";
    }
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
  void setCategoryId(int value) {
    categoryId = value;
    validateForm();
  }

  @action
  void setBrandId(int value) {
    brandId = value;
    validateForm();
  }

  @action
  void setTagIds(List<int> value) {
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
  void toggleTag(int tagId) {
    if (tagIds.contains(tagId)) {
      tagIds.remove(tagId);
    } else {
      tagIds.add(tagId);
    }
    tagIds = List.from(tagIds); // Trigger update
    validateForm();
  }

  @action
  void initializeForEdit(Product product) {
    editingProduct = product;
    name = product.name;
    sku = product.sku;
    price = product.price.toString();
    description = product.description;
    status = product.status;
    categoryId = product.categoryId;
    brandId = product.brandId;
    tagIds = List.from(product.tagIds);
    imageUrls = List.from(product.imageUrls);
    
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
      result = Product(
        id: editingProduct?.id,
        name: name,
        sku: sku,
        price: parsedPrice,
        currency: 'USD', // placeholder,
        rating: editingProduct?.rating ?? 0.0, // keep existing rating if editing
        description: description,
        status: status,
        categoryId: categoryId,
        brandId: brandId,
        tagIds: tagIds,
        imageUrls: imageUrls,
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
    status = ProductStatus.ACTIVE;
    categoryId = 1;
    brandId = 1;
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
