import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/product_detail/data/mock_product_data.dart';
import 'package:mobile_ai_erp/utils/routes/cart_routes.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final CartStore _cartStore;
  late final List<Map<String, dynamic>> _products;

  String? _addingVariantId;

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
    _products = _buildMockProducts();
  }

  List<Map<String, dynamic>> _buildMockProducts() {
    final mainProduct = MockProductData.sampleProduct;

    ProductVariant? findMainVariant(String colorName, String size) {
      try {
        return mainProduct.variants.firstWhere(
          (v) => v.color?.name == colorName && v.size == size,
        );
      } catch (_) {
        return null;
      }
    }

    final firstVariant =
        findMainVariant('Red', 'US 9') ??
        (mainProduct.variants.isNotEmpty ? mainProduct.variants.first : null);

    final list = <Map<String, dynamic>>[];

    if (firstVariant != null) {
      list.add({
        'productId': mainProduct.id,
        'name': mainProduct.name,
        'brandName': mainProduct.brandName,
        'categoryName': mainProduct.categoryName,
        'imageUrl': mainProduct.media.isNotEmpty
            ? mainProduct.media.first.url
            : '',
        'rating': mainProduct.averageRating,
        'reviewCount': mainProduct.reviewCount,
        'variantId': firstVariant.id,
        'sku': firstVariant.sku,
        'colorName': firstVariant.color?.name ?? '',
        'size': firstVariant.size ?? '',
        'price': firstVariant.price,
        'salePrice': firstVariant.salePrice,
        'stockQuantity': firstVariant.stockQuantity,
        'inStock': firstVariant.inStock,
        'useOfficialDetail': true,
        'variant': firstVariant,
      });
    }

    list.addAll([
      {
        'productId': 'prod_002',
        'name': 'Adidas Ultraboost Light',
        'brandName': 'Adidas',
        'categoryName': 'Running Shoes',
        'imageUrl':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        'rating': 4.7,
        'reviewCount': 86,
        'variantId': 'mock_adidas_white_42',
        'sku': 'AD-ULTRA-WH-42',
        'colorName': 'White',
        'size': 'EU 42',
        'price': 2890000.0,
        'salePrice': 2490000.0,
        'stockQuantity': 12,
        'inStock': true,
        'useOfficialDetail': false,
        'variant': ProductVariant(
          id: 'mock_adidas_white_42',
          sku: 'AD-ULTRA-WH-42',
          color: const ProductColor(name: 'White', color: Color(0xFFF5F5F5)),
          size: 'EU 42',
          price: 2890000.0,
          salePrice: 2490000.0,
          stockQuantity: 12,
        ),
      },
      {
        'productId': 'prod_003',
        'name': 'Puma Velocity Nitro',
        'brandName': 'Puma',
        'categoryName': 'Training Shoes',
        'imageUrl':
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=800',
        'rating': 4.5,
        'reviewCount': 61,
        'variantId': 'mock_puma_blue_41',
        'sku': 'PM-NITRO-BL-41',
        'colorName': 'Blue',
        'size': 'EU 41',
        'price': 2190000.0,
        'salePrice': null,
        'stockQuantity': 7,
        'inStock': true,
        'useOfficialDetail': false,
        'variant': ProductVariant(
          id: 'mock_puma_blue_41',
          sku: 'PM-NITRO-BL-41',
          color: const ProductColor(name: 'Blue', color: Color(0xFF2446B8)),
          size: 'EU 41',
          price: 2190000.0,
          salePrice: null,
          stockQuantity: 7,
        ),
      },
      {
        'productId': 'prod_004',
        'name': 'New Balance 530',
        'brandName': 'New Balance',
        'categoryName': 'Lifestyle Shoes',
        'imageUrl':
            'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800',
        'rating': 4.6,
        'reviewCount': 104,
        'variantId': 'mock_nb_silver_40',
        'sku': 'NB-530-SL-40',
        'colorName': 'Silver',
        'size': 'EU 40',
        'price': 2590000.0,
        'salePrice': 2290000.0,
        'stockQuantity': 0,
        'inStock': false,
        'useOfficialDetail': false,
        'variant': ProductVariant(
          id: 'mock_nb_silver_40',
          sku: 'NB-530-SL-40',
          color: const ProductColor(name: 'Silver', color: Color(0xFFB8B8C0)),
          size: 'EU 40',
          price: 2590000.0,
          salePrice: 2290000.0,
          stockQuantity: 0,
        ),
      },
      {
        'productId': 'prod_005',
        'name': 'Converse Chuck 70 High',
        'brandName': 'Converse',
        'categoryName': 'Casual Sneakers',
        'imageUrl':
            'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800',
        'rating': 4.4,
        'reviewCount': 73,
        'variantId': 'mock_cv_black_43',
        'sku': 'CV-70-BK-43',
        'colorName': 'Black',
        'size': 'EU 43',
        'price': 1790000.0,
        'salePrice': 1590000.0,
        'stockQuantity': 5,
        'inStock': true,
        'useOfficialDetail': false,
        'variant': ProductVariant(
          id: 'mock_cv_black_43',
          sku: 'CV-70-BK-43',
          color: const ProductColor(name: 'Black', color: Color(0xFF1F1F1F)),
          size: 'EU 43',
          price: 1790000.0,
          salePrice: 1590000.0,
          stockQuantity: 5,
        ),
      },
    ]);

    return list;
  }

  Future<void> _quickAddToCart(Map<String, dynamic> product) async {
    final inStock = product['inStock'] == true;
    if (!inStock) return;

    final variant = product['variant'] as ProductVariant?;
    final productId = product['productId'] as String?;
    final productName = product['name'] as String?;
    final imageUrl = product['imageUrl'] as String?;
    final variantId = product['variantId'] as String?;

    if (variant == null ||
        productId == null ||
        productName == null ||
        variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing product variant information'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _addingVariantId = variantId;
    });

    try {
      await _cartStore.addVariantToCart(
        productId: productId,
        productName: productName,
        variant: variant,
        imageUrl: imageUrl,
        qty: 1,
      );

      if (!mounted) return;

      if (_cartStore.errorMessage != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_cartStore.errorMessage!),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final colorName = product['colorName'] as String? ?? '';
      final size = product['size'] as String? ?? '';

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$productName${colorName.isNotEmpty ? ' ($colorName' : ''}${size.isNotEmpty ? ' / $size' : ''}${colorName.isNotEmpty ? ')' : ''} added to cart',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingVariantId = null;
        });
      }
    }
  }

  void _openProductDetail(Map<String, dynamic> product) {
    final useOfficialDetail = product['useOfficialDetail'] == true;

    if (!useOfficialDetail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Detailed page is only available for the first product',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/product-detail',
      arguments: {
        'productId': product['productId'],
        'defaultVariantId': product['variantId'],
      },
    );
  }

  String _buildPriceText(Map<String, dynamic> product) {
    final salePrice = product['salePrice'] as double?;
    final price = (product['price'] as num).toDouble();

    if (salePrice != null && salePrice < price) {
      return '₫${salePrice.toStringAsFixed(0)}';
    }

    return '₫${price.toStringAsFixed(0)}';
  }

  int? _discountPercent(Map<String, dynamic> product) {
    final salePrice = product['salePrice'] as double?;
    final price = (product['price'] as num).toDouble();

    if (salePrice == null || salePrice >= price) return null;
    return (((price - salePrice) / price) * 100).round();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 800
              ? 3
              : 2;

          final childAspectRatio = constraints.maxWidth >= 1100
              ? 0.72
              : constraints.maxWidth >= 800
              ? 0.70
              : 0.72;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductCard(product, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final inStock = product['inStock'] == true;
    final discount = _discountPercent(product);
    final salePrice = product['salePrice'] as double?;
    final originalPrice = (product['price'] as num).toDouble();
    final isOfficialProduct = index == 0;
    final variantId = product['variantId'] as String?;
    final isAdding = _addingVariantId != null && _addingVariantId == variantId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openProductDetail(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                        child: Image.network(
                          product['imageUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (isOfficialProduct)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DETAIL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!inStock)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(6),
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['brandName'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['name'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['colorName']} / ${product['size']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['categoryName'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buildPriceText(product),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (salePrice != null && salePrice < originalPrice) ...[
                    const SizedBox(height: 2),
                    Text(
                      '₫${originalPrice.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 13, color: Colors.amber[600]),
                      const SizedBox(width: 3),
                      Text(
                        '${product['rating']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Stock ${product['stockQuantity']}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: (product['stockQuantity'] as int) <= 5
                                ? Colors.orange[700]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: inStock && !isAdding
                          ? () => _quickAddToCart(product)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isAdding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              inStock ? 'Add to Cart' : 'Unavailable',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: inStock
                                    ? Colors.white
                                    : Colors.grey[700],
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
