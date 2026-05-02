import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart' as domain;
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/status_badge.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductInfoScreen extends StatefulWidget {
  final int productId;

  const ProductInfoScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final ProductStore _productStore = getIt<ProductStore>();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    final products = _productStore.productsList;
    final matchingProduct = products
        .where((p) => p.id == widget.productId)
        .isNotEmpty
        ? products.firstWhere((p) => p.id == widget.productId)
        : null;

    if (matchingProduct != null) {
      _productStore.setSelectedProduct(matchingProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final product = _productStore.selectedProduct;

        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: Text(ProductStrings.detailTitle)),
            body: Center(child: Text(ProductStrings.productNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(ProductStrings.detailTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.productManagementCreateEdit,
                    arguments: product,
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(context, product),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with enhanced typography
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Text(
                  '\$${product.sellingPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 6),

                // Status section - near header for visibility
                Row(
                  children: [
                    Text(
                      '${ProductStrings.status}: ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    StatusBadge(status: product.status),
                  ],
                ),
                SizedBox(height: 6),
                if (product.createdAt != null)
                  Text(
                    '${ProductStrings.created}: ${_formatDate(product.createdAt!)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                SizedBox(height: 20),

                // Images section
                if (product.images.isNotEmpty) ...[
                  Text(
                    'Images',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Details section - simplified layout
                Text(
                  ProductStrings.details,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 20),
                _buildDetailRow(ProductStrings.skuLabel, product.sku),
                SizedBox(height: 16),
                _buildDetailRow(ProductStrings.category, MockProductDataSource.getCategoryName(int.parse(product.categoryId ?? '0'))),
                SizedBox(height: 16),
                _buildDetailRow(ProductStrings.brand, MockProductDataSource.getBrandName(int.parse(product.brandId ?? '0'))),
                SizedBox(height: 16),
                _buildDetailRow(
                  ProductStrings.tags,
                  product.tags.isEmpty
                      ? ProductStrings.noneValue
                      : "MockProductDataSource.getTagNames(product.tags).join(', ')",
                ),
                SizedBox(height: 28),

                // Description section - improved styling
                Text(
                  ProductStrings.description,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12),
                Text(
                  product.description ?? "No description available.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showDeleteDialog(BuildContext context, domain.Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ProductStrings.deleteTitle),
        content: Text('${ProductStrings.deleteMessage} "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              // _productStore.deleteProduct(product.id ?? 0);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(Strings.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
