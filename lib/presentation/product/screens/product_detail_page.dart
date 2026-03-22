import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/quantity_selector.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/utils/routes/cart_routes.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';

/// Product Detail Page with cart integration
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final CartStore _cartStore;
  int _selectedQuantity = 1;
  late Map<String, dynamic> _product;

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
  }

  Future<void> _addToCart() async {
    final cartItem = CartItem(
      id: 'item_${_product['id']}',
      productId: _product['id'],
      productName: _product['name'],
      unitPrice: _product['price'].toDouble(),
      quantity: _selectedQuantity,
      stockAvailable: _product['inStock'] ? 100 : 0,
      itemDiscount: null,
    );

    await _cartStore.addItemToCart(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${_product['name']} (x$_selectedQuantity) added to cart!'),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _product =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Observer(
            builder: (context) => MiniCartBadge(
              itemCount: _cartStore.itemCount,
              onTap: () {
                CartRoutes.navigateToCart(context);
              },
              hasDiscount: _cartStore.hasCoupon,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product image
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[100],
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      _product['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, color: Colors.grey[400], size: 80),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _product['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${_product['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(_product['category']),
                        backgroundColor: Colors.grey[200],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${_product['rating']} (${(4 + (_product['id'].hashCode % 97)).toString()} reviews)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'High-quality product with excellent features. Carefully selected materials ensure durability and comfort. Perfect for everyday use.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stock status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _product['inStock']
                          ? Colors.green[50]
                          : Colors.red[50],
                      border: Border.all(
                        color: _product['inStock']
                            ? Colors.green[200]!
                            : Colors.red[200]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _product['inStock']
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _product['inStock']
                              ? Colors.green[600]
                              : Colors.red[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _product['inStock']
                              ? 'In Stock - Ready to ship'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _product['inStock']
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity selector
                  if (_product['inStock'])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        QuantitySelector(
                          currentQuantity: _selectedQuantity,
                          maxQuantity: 100,
                          onQuantityChanged: (quantity) {
                            setState(() => _selectedQuantity = quantity);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _product['inStock'] ? _addToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _product['inStock'] ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
