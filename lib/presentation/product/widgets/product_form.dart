import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/services.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/brand_dropdown.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/category_dropdown.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/tag_selector.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductForm extends StatefulWidget {
  final ProductFormStore formStore;

  const ProductForm({Key? key, required this.formStore}) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    
    // Sync controllers with form store values (especially important for edit mode)
    Future.microtask(() {
      if (mounted) {
        _syncControllers();
      }
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.formStore.name);
    _skuController = TextEditingController(text: widget.formStore.sku);
    _priceController = TextEditingController(text: widget.formStore.price);
    _descriptionController = TextEditingController(text: widget.formStore.description);
  }

  void _syncControllers() {
    // Sync controllers with form store values (for edit mode)
    _nameController.text = widget.formStore.name;
    _skuController.text = widget.formStore.sku;
    _priceController.text = widget.formStore.price;
    _descriptionController.text = widget.formStore.description;
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
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
              CategoryDropdown(
                selectedCategoryId: widget.formStore.categoryId,
                onCategoryChanged: widget.formStore.setCategoryId,
              ),
              SizedBox(height: 16),

              // Brand
              BrandDropdown(
                selectedBrandId: widget.formStore.brandId,
                onBrandChanged: widget.formStore.setBrandId,
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
