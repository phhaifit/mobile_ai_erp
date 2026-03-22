import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/utils/routes/cart_routes.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';

/// Product List Page with cart integration
class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final CartStore _cartStore;

  // Mock products data
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': 'prod_001',
      'name': 'Wireless Headphones',
      'price': 79.99,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Headphones',
      'category': 'Electronics',
      'rating': 4.5,
      'inStock': true,
    },
    {
      'id': 'prod_002',
      'name': 'USB-C Cable',
      'price': 12.99,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Cable',
      'category': 'Accessories',
      'rating': 4.2,
      'inStock': true,
    },
    {
      'id': 'prod_003',
      'name': 'Phone Case',
      'price': 24.99,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Case',
      'category': 'Accessories',
      'rating': 4.7,
      'inStock': true,
    },
    {
      'id': 'prod_004',
      'name': 'Screen Protector',
      'price': 9.99,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Protector',
      'category': 'Accessories',
      'rating': 4.4,
      'inStock': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final cartItem = CartItem(
      id: 'item_${product['id']}',
      productId: product['id'],
      productName: product['name'],
      unitPrice: product['price'].toDouble(),
      quantity: 1,
      stockAvailable: product['inStock'] ? 100 : 0,
      itemDiscount: null,
    );

    await _cartStore.addItemToCart(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Observer(
            builder: (context) {
              final count = _cartStore.cart.itemCount;
              final hasCoupon = _cartStore.cart.appliedCoupon != null;

              return MiniCartBadge(
                itemCount: count,
                onTap: () => CartRoutes.navigateToCart(context),
                hasDiscount: hasCoupon,
              );
            },
          ),
        ],
      ),
      body: Observer(
        builder: (context) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _mockProducts.length,
          itemBuilder: (context, index) {
            final product = _mockProducts[index];
            return _buildProductCard(product);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/product-detail',
            arguments: product,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image, color: Colors.grey[400]),
                      ),
                    ),
                    // Out of stock badge
                    if (!product['inStock'])
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    '\$${product['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber[600]),
                      const SizedBox(width: 2),
                      Text(
                        '${product['rating']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          product['inStock'] ? () => _addToCart(product) : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        product['inStock'] ? 'Add to Cart' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              product['inStock'] ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
