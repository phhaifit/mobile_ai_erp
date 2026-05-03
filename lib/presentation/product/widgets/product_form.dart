import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/services.dart';
// import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
// import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
// import 'package:mobile_ai_erp/data/network/exceptions/network_exceptions.dart';
// import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/supplier/supplier_usecases.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/brand_select_modal.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/category_select_modal.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/tag_select_modal.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/paginated_selection_modal.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductForm extends StatefulWidget {
  final ProductFormStore formStore;

  const ProductForm({super.key, required this.formStore});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  // final BrandApi _brandApi = BrandApi(RestClient());
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _barcodeController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _webTitleController;
  late TextEditingController _webDescriptionController;
  late TextEditingController _warrantyMonthsController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _widthController;
  late TextEditingController _lengthController;

  String? _selectedBrandName;
  String? _selectedCategoryName;
  List<String> _selectedTagNames = [];

  // Mock weight units data
  final List<Map<String, dynamic>> weightUnits = [
    {'id': 1, 'name': 'kg'},
    {'id': 2, 'name': 'g'},
    {'id': 3, 'name': 'lb'},
    {'id': 4, 'name': 'oz'},
  ];

  // void fetchBrands() async {
  //   try {
  //     final test = await _brandApi.getBrands();
  //     log(test.toString());
  //   }
  //   on NetworkException catch(e) {
  //     log('Error fetching brands: ${e.message} - status ${e.statusCode}');
  //   }
  //   catch (e) {
  //     log('Unexpected error: ${e.toString()}');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // fetchBrands();
    _initializeControllers();
    _loadSelectedBrandName();
    _loadSelectedCategoryName();
    _loadSelectedTagNames();
    
    // Sync controllers with form store values (especially important for edit mode)
    Future.microtask(() {
      if (mounted) {
        _syncControllers();
      }
    });
  }

  Future<void> _loadSelectedBrandName() async {
    if (widget.formStore.brandId == null) {
      setState(() {
        _selectedBrandName = null;
      });
      return;
    }

    try {
      final repository = getIt<ProductMetadataRepository>();
      final response = await repository.getBrands(page: 1, pageSize: 100);
      var foundBrand = response.items
          .where((b) => b.id == widget.formStore.brandId)
          .firstOrNull;
      
      if (foundBrand != null && mounted) {
        setState(() {
          _selectedBrandName = foundBrand.name;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSelectedCategoryName() async {
    if (widget.formStore.categoryId == null) {
      setState(() {
        _selectedCategoryName = null;
      });
      return;
    }

    try {
      final repository = getIt<ProductMetadataRepository>();
      final response = await repository.getCategories(page: 1, pageSize: 100);
      var foundCategory = response.items
          .where((c) => c.id == widget.formStore.categoryId)
          .firstOrNull;
      
      if (foundCategory != null && mounted) {
        setState(() {
          _selectedCategoryName = foundCategory.name;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSelectedTagNames() async {
    if (widget.formStore.tagIds.isEmpty) {
      setState(() {
        _selectedTagNames = [];
      });
      return;
    }

    try {
      final repository = getIt<ProductMetadataRepository>();
      final response = await repository.getTags(page: 1, pageSize: 100);
      final selectedTags = response.items
          .where((t) => widget.formStore.tagIds.contains(t.id))
          .map((t) => t.name)
          .toList();
      
      if (mounted) {
        setState(() {
          _selectedTagNames = selectedTags;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.formStore.name);
    _skuController = TextEditingController(text: widget.formStore.sku);
    _priceController = TextEditingController(text: widget.formStore.price);
    _costPriceController = TextEditingController(text: widget.formStore.costPrice ?? '');
    _descriptionController = TextEditingController(text: widget.formStore.description);
    _barcodeController = TextEditingController(text: widget.formStore.barcode ?? '');
    _sellingPriceController = TextEditingController(text: widget.formStore.sellingPrice ?? '');
    _webTitleController = TextEditingController(text: widget.formStore.webTitle ?? '');
    _webDescriptionController = TextEditingController(text: widget.formStore.webDescription ?? '');
    _warrantyMonthsController = TextEditingController(text: widget.formStore.warrantyMonths ?? '');
    _weightController = TextEditingController(text: widget.formStore.weight ?? '');
    _heightController = TextEditingController(text: widget.formStore.height ?? '');
    _widthController = TextEditingController(text: widget.formStore.width ?? '');
    _lengthController = TextEditingController(text: widget.formStore.length ?? '');
  }

  void _syncControllers() {
    // Sync controllers with form store values (for edit mode)
    _nameController.text = widget.formStore.name;
    _skuController.text = widget.formStore.sku;
    _priceController.text = widget.formStore.price;
    _costPriceController.text = widget.formStore.costPrice ?? '';
    _descriptionController.text = widget.formStore.description;
    _barcodeController.text = widget.formStore.barcode ?? '';
    _sellingPriceController.text = widget.formStore.sellingPrice ?? '';
    _webTitleController.text = widget.formStore.webTitle ?? '';
    _webDescriptionController.text = widget.formStore.webDescription ?? '';
    _warrantyMonthsController.text = widget.formStore.warrantyMonths ?? '';
    _weightController.text = widget.formStore.weight ?? '';
    _heightController.text = widget.formStore.height ?? '';
    _widthController.text = widget.formStore.width ?? '';
    _lengthController.text = widget.formStore.length ?? '';
    _loadSelectedBrandName();
    _loadSelectedCategoryName();
    _loadSelectedTagNames();
  }

  void _openBrandModal() {
    showDialog(
      context: context,
      builder: (context) => BrandSelectModal(
        initialBrandId: widget.formStore.brandId,
        initialBrandName: _selectedBrandName,
        onBrandSelected: (brandId) {
          widget.formStore.setBrandId(brandId);
          _loadSelectedBrandName();
        },
      ),
    );
  }

  void _openCategoryModal() {
    showDialog(
      context: context,
      builder: (context) => CategorySelectModal(
        initialCategoryId: widget.formStore.categoryId,
        initialCategoryName: _selectedCategoryName,
        onCategorySelected: (categoryId) {
          widget.formStore.setCategoryId(categoryId);
          _loadSelectedCategoryName();
        },
      ),
    );
  }

  void _openTagsModal() {
    showDialog(
      context: context,
      builder: (context) => TagSelectModal(
        initialSelectedTagIds: widget.formStore.tagIds,
        onTagsSelected: (selectedTagIds) {
          widget.formStore.setTagIds(selectedTagIds);
          _loadSelectedTagNames();
        },
      ),
    );
  }

  void _openSupplierSelectionModal() {
    showDialog(
      context: context,
      builder: (context) => PaginatedSelectionModal<Supplier>(
        initialSelectionId: null,
        initialSelectionName: null,
        title: 'Select Supplier',
        selectedLabel: 'Selected',
        noItemsMessage: 'No suppliers found',
        noSelectionText: 'No supplier selected',
        fetchItems: (page, pageSize) async {
          final result = await widget.formStore.fetchSuppliers(page, pageSize);
          return result;
        },
        getItemId: (supplier) => supplier.id,
        getItemName: (supplier) => supplier.name,
        onSelectionChanged: (supplierId) {
          if (supplierId != null) {
            // Find the supplier name from the list
            // We need to fetch the supplier details, so we'll use a simple approach
            _addSupplierToForm(supplierId);
          }
        },
      ),
    );
  }

  void _openSupplierModal(int supplierIndex) {
    final supplier = widget.formStore.suppliers[supplierIndex];
    
    showDialog(
      context: context,
      builder: (context) => PaginatedSelectionModal<Supplier>(
        initialSelectionId: supplier.supplierId,
        initialSelectionName: supplier.supplierName,
        title: 'Select Supplier',
        selectedLabel: 'Selected',
        noItemsMessage: 'No suppliers found',
        noSelectionText: 'No supplier selected',
        fetchItems: (page, pageSize) async {
          final result = await widget.formStore.fetchSuppliers(page, pageSize);
          return result;
        },
        getItemId: (s) => s.id,
        getItemName: (s) => s.name,
        onSelectionChanged: (newSupplierId) {
          if (newSupplierId != null && newSupplierId != supplier.supplierId) {
            // Remove the old supplier and add the new one
            widget.formStore.removeSupplier(supplier.supplierId);
            _addSupplierToForm(newSupplierId);
          }
        },
      ),
    );
  }

  void _addSupplierToForm(String supplierId) async {
    try {
      final getSuppliersUseCase = getIt<GetSuppliersUseCase>();
      final result = await getSuppliersUseCase(page: 1, pageSize: 100);
      
      final supplier = result.data.firstWhere(
        (s) => s.id == supplierId,
        orElse: () => null as dynamic,
      );
      
      if (supplier != null) {
        widget.formStore.addSupplier(supplierId, supplier.name);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void didUpdateWidget(ProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the form store instance changed
    if (oldWidget.formStore != widget.formStore) {
      _nameController.dispose();
      _skuController.dispose();
      _priceController.dispose();
      _costPriceController.dispose();
      _descriptionController.dispose();
      _barcodeController.dispose();
      _sellingPriceController.dispose();
      _webTitleController.dispose();
      _webDescriptionController.dispose();
      _warrantyMonthsController.dispose();
      _weightController.dispose();
      _heightController.dispose();
      _widthController.dispose();
      _lengthController.dispose();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _sellingPriceController.dispose();
    _webTitleController.dispose();
    _webDescriptionController.dispose();
    _warrantyMonthsController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              Observer(
                builder: (context) {
                  return TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '${ProductStrings.name} *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                      // helperText:
                      //     '${widget.formStore.name.length}/100 characters',
                      errorText: widget.formStore.nameError.isEmpty
                          ? null
                          : widget.formStore.nameError,
                    ),
                    maxLength: 100,
                    onChanged: widget.formStore.setName,
                  );
                },
              ),
              SizedBox(height: 16),

              // SKU
              Observer(
                builder: (context) {
                  return TextField(
                    controller: _skuController,
                    decoration: InputDecoration(
                      labelText: '${ProductStrings.sku} *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                      errorText: widget.formStore.skuError.isEmpty
                          ? null
                          : widget.formStore.skuError,
                    ),
                    onChanged: widget.formStore.setSku,
                    maxLength: 50,
                  );
                },
              ),
              SizedBox(height: 16),

              // Price
              Observer(
                builder: (context) {
                  return TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: '${ProductStrings.price} *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      errorText: widget.formStore.priceError.isEmpty
                          ? null
                          : widget.formStore.priceError,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: widget.formStore.setPrice,
                  );
                },
              ),
              SizedBox(height: 16),

              // Cost Price
              TextField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: 'Cost Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.price_check),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                onChanged: widget.formStore.setCostPrice,
              ),
              SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: ProductStrings.description,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                onChanged: widget.formStore.setDescription,
                maxLength: 300,
              ),
              SizedBox(height: 16),

              // Barcode
              TextField(
                controller: _barcodeController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.barcode_reader),
                ),
                onChanged: widget.formStore.setBarcode,
              ),
              SizedBox(height: 16),

              // Selling Price
              TextField(
                controller: _sellingPriceController,
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sell),
                  // errorText: widget.formStore.sellingPriceError.isEmpty
                  //     ? null
                  //     : widget.formStore.sellingPriceError,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                onChanged: widget.formStore.setSellingPrice,
              ),
              SizedBox(height: 16),

              // Web Title
              TextField(
                controller: _webTitleController,
                decoration: InputDecoration(
                  labelText: 'Web Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                onChanged: widget.formStore.setWebTitle,
                maxLength: 255,
              ),
              SizedBox(height: 16),

              // Web Description
              TextField(
                controller: _webDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Web Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                onChanged: widget.formStore.setWebDescription,
                maxLength: 1000,
              ),
              SizedBox(height: 16),

              // Warranty Months
              TextField(
                controller: _warrantyMonthsController,
                decoration: InputDecoration(
                  labelText: ProductStrings.warranty,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: widget.formStore.setWarrantyMonths,
              ),
              SizedBox(height: 16),

              // Weight
              Observer(
                builder: (context) {
                  return TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: ProductStrings.weight,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      errorText: widget.formStore.weightError.isEmpty
                          ? null
                          : widget.formStore.weightError,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,4}'),
                      ),
                    ],
                    onChanged: widget.formStore.setWeight,
                  );
                }
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: ProductStrings.height,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                      ],
                      onChanged: widget.formStore.setHeight,
                    )
                  ),
                  SizedBox(width: 10),

                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _widthController,
                      decoration: InputDecoration(
                        labelText: ProductStrings.width,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.swap_horiz),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                      ],
                      onChanged: widget.formStore.setWidth,
                    )
                  ),
                  SizedBox(width: 10),

                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _lengthController,
                      decoration: InputDecoration(
                        labelText: ProductStrings.length,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.expand),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                      ],
                      onChanged: widget.formStore.setLength,
                    )
                  ),
                ],
              ),
                  
              SizedBox(height: 16),

              // Status
              DropdownButtonFormField<ProductStatus>(
                initialValue: widget.formStore.status,
                decoration: InputDecoration(
                  labelText: '${ProductStrings.status} *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: ProductStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (status) {
                  if (status != null) {
                    widget.formStore.setStatus(status);
                  }
                },
              ),
              SizedBox(height: 16),

              // Category
              GestureDetector(
                onTap: _openCategoryModal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: ProductStrings.category,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                    suffixIcon: Icon(Icons.open_in_new, size: 18),
                  ),
                  child: Text(
                    _selectedCategoryName ?? 'No category selected',
                    style: TextStyle(
                      color: _selectedCategoryName != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Brand
              GestureDetector(
                onTap: _openBrandModal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: ProductStrings.brand,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                    suffixIcon: Icon(Icons.open_in_new, size: 18),
                  ),
                  child: Text(
                    _selectedBrandName ?? 'No brand selected',
                    style: TextStyle(
                      color: _selectedBrandName != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Tags
              GestureDetector(
                onTap: _openTagsModal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: ProductStrings.tags,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sell),
                    suffixIcon: Icon(Icons.open_in_new, size: 18),
                  ),
                  child: Text(
                    _selectedTagNames.isEmpty
                        ? ProductStrings.noTagsSelectedText
                        : '${_selectedTagNames.length} tag(s) selected',
                    style: TextStyle(
                      color: _selectedTagNames.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Suppliers
              Text(
                'Product Suppliers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12),
              Observer(
                builder: (context) {
                  return Column(
                    children: [
                      ...widget.formStore.suppliers.map((supplierEntry) {
                        final supplierIndex = widget.formStore.suppliers.indexOf(supplierEntry);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Supplier name (clickable)
                                GestureDetector(
                                  onTap: () => _openSupplierModal(supplierIndex),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            supplierEntry.supplierName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.edit, size: 18, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),

                                // Supplier SKU
                                TextField(
                                  controller: TextEditingController(
                                    text: supplierEntry.supplierSku ?? '',
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Supplier SKU',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.qr_code),
                                  ),
                                  onChanged: (value) {
                                    widget.formStore.updateSupplierSku(
                                      supplierEntry.supplierId,
                                      value,
                                    );
                                  },
                                ),
                                SizedBox(height: 12),

                                // Cost Price
                                TextField(
                                  controller: TextEditingController(
                                    text: supplierEntry.costPrice ?? '',
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Cost Price',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.price_check),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    widget.formStore.updateSupplierCostPrice(
                                      supplierEntry.supplierId,
                                      value,
                                    );
                                  },
                                ),
                                SizedBox(height: 12),

                                // Primary button / badge and remove button
                                Row(
                                  children: [
                                    if (supplierEntry.isPrimary)
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            border: Border.all(color: Colors.green),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Primary Supplier',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => widget.formStore
                                              .setPrimarySupplier(supplierEntry.supplierId),
                                          child: Text('Set as Primary'),
                                        ),
                                      ),
                                    SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => widget.formStore
                                          .removeSupplier(supplierEntry.supplierId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      ElevatedButton.icon(
                        onPressed: () => _openSupplierSelectionModal(),
                        icon: Icon(Icons.add),
                        label: Text('Add Supplier'),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16),

              // Images
              Text(
                'Product Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12),
              Observer(
                builder: (context) {
                  return Column(
                    children: [
                      ...widget.formStore.imageUrls.asMap().entries.map((entry) {
                        final index = entry.key;
                        final url = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(text: url),
                                  decoration: InputDecoration(
                                    labelText: 'Image URL ${index + 1}',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.image),
                                  ),
                                  onChanged: (value) {
                                    final newUrls = List<String>.from(widget.formStore.imageUrls);
                                    newUrls[index] = value;
                                    widget.formStore.setImageUrls(newUrls);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => widget.formStore.removeImageUrl(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.formStore.addImageUrl('');
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Image'),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 32),

              // Buttons
              Observer(
                builder: (context) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(Strings.cancel),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.formStore.isFormValid
                              ? () async {
                                  final navigator = Navigator.of(context);
                                  final product = await widget.formStore.submitForm();
                                  final productStore = getIt<ProductStore>();
                                  if (widget.formStore.success) {
                                    await productStore.fetchProducts();
                                    if (widget.formStore.editingProduct != null && product != null) {
                                      productStore.setSelectedProduct(product);
                                    }
                                    navigator.pop(context);
                                  }

                                  if (!widget.formStore.success && mounted) {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(widget.formStore.errorStore.errorMessage),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Text(widget.formStore.isEditing ? ProductStrings.updateButton : ProductStrings.createButton),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
