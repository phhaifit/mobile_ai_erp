import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/usecase/product/get_products_usecase.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/product_card.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final GetProductsUseCase _getProductsUseCase = getIt<GetProductsUseCase>();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalPages = 1;
  bool _loading = false;
  String? _error;
  List<Product> _products = [];
  List<Product> _displayedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _getProductsUseCase.call(
        params: GetProductsParams(page: page, pageSize: _pageSize),
      );

      if (!mounted) return;

      setState(() {
        _currentPage = result.page;
        _totalPages = result.totalPages;
        _products = result.data;
        _applySearchFilter(_searchController.text);
        _loading = false;
      });
    } catch (error) {
      log(error.toString());
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _applySearchFilter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      _displayedProducts = _products;
      return;
    }

    _displayedProducts = _products.where((product) {
      final name = product.name.toLowerCase();
      final sku = product.sku.toLowerCase();
      final description = product.description?.toLowerCase() ?? '';
      return name.contains(normalized) ||
          sku.contains(normalized) ||
          description.contains(normalized);
    }).toList(growable: false);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _applySearchFilter(value);
    });
  }

  List<int> _getPaginationPages() {
    if (_totalPages <= 5) {
      return List.generate(_totalPages, (index) => index + 1);
    }

    if (_currentPage <= 3) {
      return [1, 2, 3, 4, 5];
    }

    if (_currentPage >= _totalPages - 2) {
      return [
        _totalPages - 4,
        _totalPages - 3,
        _totalPages - 2,
        _totalPages - 1,
        _totalPages,
      ];
    }

    return [
      _currentPage - 2,
      _currentPage - 1,
      _currentPage,
      _currentPage + 1,
      _currentPage + 2,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final products = _searchController.text.isEmpty
        ? _products
        : _displayedProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(ProductStrings.screenTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: ProductStrings.refreshTooltip,
            onPressed: () async {
              await _loadProducts(page: _currentPage);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: ProductStrings.searchPlaceholder,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.productManagementFilter);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  ProductStrings.noProductsFound,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductCard(
                                      product: product,
                                      onTap: () {
                                        // Navigator.of(context).pushNamed(
                                        //   Routes.productManagementInfo,
                                        //   arguments: product.id,
                                        // );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    tooltip: ProductStrings.editTitle,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        Routes.productManagementCreateEdit,
                                        arguments: product,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
          ),
          if (!_loading)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _currentPage > 1
                        ? () => _loadProducts(page: _currentPage - 1)
                        : null,
                    child: Text('Previous'),
                  ),
                  ..._getPaginationPages().map((page) {
                    final isCurrent = page == _currentPage;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: isCurrent
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        onPressed: page == _currentPage ? null : () => _loadProducts(page: page),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Theme.of(context).primaryColor,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                  TextButton(
                    onPressed: _currentPage < _totalPages
                        ? () => _loadProducts(page: _currentPage + 1)
                        : null,
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.productManagementCreateEdit);
        },
        tooltip: ProductStrings.createTooltip,
        child: Icon(Icons.add),
      ),
    );
  }
}
