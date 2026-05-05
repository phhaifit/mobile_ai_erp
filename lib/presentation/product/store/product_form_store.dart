import 'dart:developer';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/product/save_product_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/supplier/supplier_usecases.dart';
import 'package:mobx/mobx.dart';

part 'product_form_store.g.dart';

/// Represents a supplier entry in the product form
class SupplierEntry {
  final String supplierId;
  final String supplierName;
  String? supplierSku;
  String? costPrice;
  final bool isPrimary;

  SupplierEntry({
    required this.supplierId,
    required this.supplierName,
    this.supplierSku,
    this.costPrice,
    this.isPrimary = false,
  });

  SupplierEntry copyWith({
    String? supplierId,
    String? supplierName,
    String? supplierSku,
    String? costPrice,
    bool? isPrimary,
  }) {
    return SupplierEntry(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierSku: supplierSku ?? this.supplierSku,
      costPrice: costPrice ?? this.costPrice,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class ProductFormStore = _ProductFormStore with _$ProductFormStore;

abstract class _ProductFormStore with Store {
  final String TAG = "_ProductFormStore";
  
  // Constants for validation
  static const int MAX_PRODUCT_NAME_LENGTH = 100;

  // repository and usecase instances
  final ProductManagementRepository _repository;
  final GetSuppliersUseCase _getSuppliersUseCase;
  final SaveProductUseCase _saveProductUseCase;

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
  String? costPrice;

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
  String? weight; // weight of product in grams (g)

  @observable
  String? height; // height of product in centimeters (cm)

  @observable
  String? width; // width of product in centimeters (cm)

  @observable
  String? length; // length of product in centimeters (cm)

  @observable
  List<String> tagIds = [];

  @observable
  List<String> imageUrls = [];

  @observable
  List<SupplierEntry> suppliers = [];

  @observable
  String? primarySupplierId; // ID of the primary supplier (can be null)

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
  _ProductFormStore(this._repository, this._getSuppliersUseCase, this.errorStore, this._saveProductUseCase);

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
    if (weight != null && weight!.isNotEmpty) {
      final parsedWeight = double.tryParse(weight!);
      if (parsedWeight == null || parsedWeight <= 0) {
        weightError = 'Weight must be greater than 0.';
      }
    }

    // validate height, width, length
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
  void setCostPrice(String value) {
    costPrice = value.isEmpty ? null : value;
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
  void setWarrantyMonths(String value) {
    warrantyMonths = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWeight(String value) {
    weight = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setHeight(String value) {
    height = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setWidth(String value) {
    width = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void setLength(String value) {
    length = value.isEmpty ? null : value;
    validateForm();
  }

  @action
  void addSupplier(String supplierId, String supplierName) {
    // Check if supplier already exists
    if (suppliers.any((s) => s.supplierId == supplierId)) {
      return;
    }
    
    suppliers = List.from(suppliers)
      ..add(SupplierEntry(
        supplierId: supplierId,
        supplierName: supplierName,
      ));
  }

  @action
  void removeSupplier(String supplierId) {
    suppliers = suppliers.where((s) => s.supplierId != supplierId).toList();
    
    // If this was the primary supplier, remove the primary flag
    if (primarySupplierId == supplierId) {
      primarySupplierId = null;
    }
  }

  @action
  void updateSupplierSku(String supplierId, String sku) {
    final index = suppliers.indexWhere((s) => s.supplierId == supplierId);
    if (index != -1) {
      final updatedSupplier = suppliers[index].copyWith(
        supplierSku: sku.isEmpty ? null : sku,
      );
      suppliers = List.from(suppliers)..[index] = updatedSupplier;
    }
  }

  @action
  void updateSupplierCostPrice(String supplierId, String costPrice) {
    final index = suppliers.indexWhere((s) => s.supplierId == supplierId);
    if (index != -1) {
      final updatedSupplier = suppliers[index].copyWith(
        costPrice: costPrice.isEmpty ? null : costPrice,
      );
      suppliers = List.from(suppliers)..[index] = updatedSupplier;
    }
  }

  @action
  void setPrimarySupplier(String supplierId) {
    // If setting the same supplier as primary, just return
    if (primarySupplierId == supplierId) {
      return;
    }
    
    // Update the supplier list to mark the new primary and unmark the old one
    suppliers = suppliers.map((supplier) {
      if (supplier.supplierId == supplierId) {
        return supplier.copyWith(isPrimary: true);
      } else if (supplier.isPrimary) {
        return supplier.copyWith(isPrimary: false);
      }
      return supplier;
    }).toList();
    
    primarySupplierId = supplierId;
  }

  @action
  void removePrimarySupplier() {
    primarySupplierId = null;
    suppliers = suppliers
        .map((s) => s.isPrimary ? s.copyWith(isPrimary: false) : s)
        .toList();
  }

  Future<(List<Supplier>, int)> fetchSuppliers(int page, int pageSize) async {
    final result = await _getSuppliersUseCase(
      page: page,
      pageSize: pageSize,
    );
    
    return (result.data, result.totalPages);
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
    costPrice = product.costPrice?.toString();
    // barcode = product.barcode;
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
    log("Submitting");
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
      final parsedCostPrice = (costPrice != null && costPrice!.isNotEmpty)
          ? double.tryParse(costPrice!)
          : null;
      final parsedSelling = (sellingPrice != null && sellingPrice!.isNotEmpty)
          ? double.tryParse(sellingPrice!)
          : null;

      result = Product(
        id: editingProduct?.id,
        name: name,
        sku: sku,
        barcode: barcode,
        description: description,
        webTitle: webTitle,
        webDescription: webDescription,
        brandId: brandId,
        categoryId: categoryId,
        type: ProductType.standalone,
        status: status,
        warrantyMonths: warrantyMonths != null ? int.tryParse(warrantyMonths!) : null,
        lengthCm: length != null ? double.tryParse(length!) : null,
        widthCm: width != null ? double.tryParse(width!) : null,
        heightCm: height != null ? double.tryParse(height!) : null,
        weightG: weight != null ? double.tryParse(weight!) : null,
        basePrice: parsedPrice,
        costPrice: parsedCostPrice,
        sellingPrice: parsedSelling,
        images: imageUrls,
        tagIds: tagIds,
        suppliers: suppliers
          .map((s) => {
                'supplierId': s.supplierId,
                'supplierSku': s.supplierSku,
                'costPrice': s.costPrice,
                'isPrimary': s.isPrimary,
              })
          .toList(),
        
      );

      // if (isEditing) {
      //   await _repository.updateProduct(result);
      // } else {
      //   await _repository.createProduct(result);
      //   reset();
      // }

      log("cp1");
      await _saveProductUseCase.call(params: result);
      if (!isEditing) {
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
    costPrice = null;
    sellingPrice = null;
    webTitle = null;
    webDescription = null;
    warrantyMonths = null;
    weight = null;
    status = ProductStatus.ACTIVE;
    categoryId = null;
    brandId = null;
    tagIds = [];
    imageUrls = [];
    suppliers = [];
    primarySupplierId = null;
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
