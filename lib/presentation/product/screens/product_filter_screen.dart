import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_filter.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductFilterScreen extends StatefulWidget {
  @override
  State<ProductFilterScreen> createState() => _ProductFilterScreenState();
}

class _ProductFilterScreenState extends State<ProductFilterScreen> {
  final ProductStore _productStore = getIt<ProductStore>();
  final MockProductDataSource _dataSource = MockProductDataSource();

  ProductStatus? _selectedStatus;
  int? _selectedCategoryId;
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    if (_productStore.currentFilter != null) {
      _selectedStatus = _productStore.currentFilter!.status;
      _selectedCategoryId = _productStore.currentFilter!.categoryId;
      _selectedBrandId = _productStore.currentFilter!.brandId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ProductStrings.filterTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filter
            Text(
              ProductStrings.status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ProductStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(status.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 24),

            // Category filter
            Text(
              ProductStrings.category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            FutureBuilder(
              future: _dataSource.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final categories = snapshot.data ?? [];
                return Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text(ProductStrings.all),
                      selected: _selectedCategoryId == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    ...categories.map((category) {
                      final isSelected = _selectedCategoryId == category.id;
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            SizedBox(height: 24),

            // Brand filter
            Text(
              ProductStrings.brand,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            FutureBuilder(
              future: _dataSource.getBrands(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final brands = snapshot.data ?? [];
                return Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text(ProductStrings.all),
                      selected: _selectedBrandId == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBrandId = null;
                        });
                      },
                    ),
                    ...brands.map((brand) {
                      final isSelected = _selectedBrandId == brand.id;
                      return FilterChip(
                        label: Text(brand.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBrandId = selected ? brand.id : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                        _selectedCategoryId = null;
                        _selectedBrandId = null;
                      });
                      _productStore.clearFilter();
                      Navigator.pop(context);
                    },
                    child: Text(ProductStrings.clear),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final filter = ProductFilter(
                        status: _selectedStatus,
                        categoryId: _selectedCategoryId,
                        brandId: _selectedBrandId,
                      );
                      _productStore.filterProducts(filter);
                      Navigator.pop(context);
                    },
                    child: Text(ProductStrings.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
