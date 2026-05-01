import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/services.dart';
// import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
// import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
// import 'package:mobile_ai_erp/data/network/exceptions/network_exceptions.dart';
// import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/brand_select_modal.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/category_select_modal.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/tag_selector.dart';
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
  late TextEditingController _descriptionController;
  late TextEditingController _barcodeController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _webTitleController;
  late TextEditingController _webDescriptionController;
  late TextEditingController _warranteeMonthsController;
  late TextEditingController _weightController;

  String? _selectedBrandName;
  String? _selectedCategoryName;

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

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.formStore.name);
    _skuController = TextEditingController(text: widget.formStore.sku);
    _priceController = TextEditingController(text: widget.formStore.price);
    _descriptionController = TextEditingController(text: widget.formStore.description);
    _barcodeController = TextEditingController(text: widget.formStore.barcode ?? '');
    _sellingPriceController = TextEditingController(text: widget.formStore.sellingPrice ?? '');
    _webTitleController = TextEditingController(text: widget.formStore.webTitle ?? '');
    _webDescriptionController = TextEditingController(text: widget.formStore.webDescription ?? '');
    _warranteeMonthsController = TextEditingController(text: widget.formStore.warranteeMonths ?? '');
    _weightController = TextEditingController(text: widget.formStore.weight ?? '');
  }

  void _syncControllers() {
    // Sync controllers with form store values (for edit mode)
    _nameController.text = widget.formStore.name;
    _skuController.text = widget.formStore.sku;
    _priceController.text = widget.formStore.price;
    _descriptionController.text = widget.formStore.description;
    _barcodeController.text = widget.formStore.barcode ?? '';
    _sellingPriceController.text = widget.formStore.sellingPrice ?? '';
    _webTitleController.text = widget.formStore.webTitle ?? '';
    _webDescriptionController.text = widget.formStore.webDescription ?? '';
    _warranteeMonthsController.text = widget.formStore.warranteeMonths ?? '';
    _weightController.text = widget.formStore.weight ?? '';
    _loadSelectedBrandName();
    _loadSelectedCategoryName();
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

  @override
  void didUpdateWidget(ProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the form store instance changed
    if (oldWidget.formStore != widget.formStore) {
      _nameController.dispose();
      _skuController.dispose();
      _priceController.dispose();
      _descriptionController.dispose();
      _barcodeController.dispose();
      _sellingPriceController.dispose();
      _webTitleController.dispose();
      _webDescriptionController.dispose();
      _warranteeMonthsController.dispose();
      _weightController.dispose();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _sellingPriceController.dispose();
    _webTitleController.dispose();
    _webDescriptionController.dispose();
    _warranteeMonthsController.dispose();
    _weightController.dispose();
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
                controller: _warranteeMonthsController,
                decoration: InputDecoration(
                  labelText: 'Warranty (Months)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: widget.formStore.setWarranteeMonths,
              ),
              SizedBox(height: 16),

              // Weight and Weight Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Observer(
                      builder: (context) {
                        return TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight',
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
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Observer(
                      builder: (context) {
                        return DropdownButtonFormField<int?>(
                          initialValue: widget.formStore.weightUnitId,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                            errorText: widget.formStore.weightUnitError.isEmpty
                                ? null
                                : widget.formStore.weightUnitError,
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None'),
                            ),
                            ...weightUnits.map((unit) {
                              return DropdownMenuItem<int?>(
                                value: unit['id'] as int,
                                child: Text(unit['name'] as String),
                              );
                            }),
                          ],
                          onChanged: widget.formStore.setWeightUnitId,
                        );
                      },
                    ),
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
              TagSelector(
                selectedTagIds: widget.formStore.tagIds,
                onTagToggled: widget.formStore.toggleTag,
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
