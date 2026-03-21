import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/product_card.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductStore _productStore = getIt<ProductStore>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productStore.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ProductStrings.screenTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: ProductStrings.refreshTooltip,
            onPressed: () async {
              await _productStore.fetchProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
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
                    onChanged: (value) {
                      _productStore.searchProducts(value);
                    },
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
          // Product list
          Expanded(
            child: Observer(
              builder: (context) {
                if (_productStore.loading) {
                  return Center(child: CircularProgressIndicator());
                }

                final products = _productStore.displayList;

                if (products.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.productManagementInfo,
                          arguments: product.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.productManagementCreateEdit);
        },
        child: Icon(Icons.add),
        tooltip: ProductStrings.createTooltip,
      ),
    );
  }
}
