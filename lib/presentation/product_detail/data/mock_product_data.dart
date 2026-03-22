import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class MockProductData {
  MockProductData._();

  static final List<ProductColor> _colors = [
    const ProductColor(name: 'Black', color: Color(0xFF212121)),
    const ProductColor(name: 'White', color: Color(0xFFFAFAFA)),
    const ProductColor(name: 'Navy', color: Color(0xFF1A237E)),
    const ProductColor(name: 'Red', color: Color(0xFFC62828)),
  ];

  static final List<String> _sizes = [
    'US 7',
    'US 8',
    'US 9',
    'US 10',
    'US 11',
    'US 12',
  ];

  static int _stockFor(String colorName, String size) {
    if (colorName == 'Black' && size == 'US 12') return 0;
    if (colorName == 'Red' && size == 'US 7') return 0;
    if (colorName == 'Red' && size == 'US 8') return 2;
    if (colorName == 'Navy' && size == 'US 11') return 3;
    if (colorName == 'White' && size == 'US 9') return 1;
    return 15;
  }

  static List<ProductVariant> _buildVariants() {
    final variants = <ProductVariant>[];
    var id = 1;
    for (final color in _colors) {
      for (final size in _sizes) {
        variants.add(ProductVariant(
          id: 'v${id}',
          sku:
              'NAM270-${color.name.substring(0, 2).toUpperCase()}-${size.replaceAll(' ', '')}',
          color: color,
          size: size,
          price: 3200000,
          salePrice: 2560000,
          stockQuantity: _stockFor(color.name, size),
        ));
        id++;
      }
    }
    return variants;
  }

  static final ProductDetail sampleProduct = ProductDetail(
    id: 'prod_001',
    name: 'Nike Air Max 270 React ENG',
    brandName: 'Nike',
    categoryName: 'Running Shoes',
    media: const [
      ProductMedia(
        url: 'https://picsum.photos/seed/nike1/800/800',
        type: MediaType.image,
      ),
      ProductMedia(
        url: 'https://picsum.photos/seed/nike2/800/800',
        type: MediaType.image,
      ),
      ProductMedia(
        url: 'https://picsum.photos/seed/nike3/800/800',
        type: MediaType.image,
      ),
      ProductMedia(
        url:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        type: MediaType.video,
        thumbnailUrl: 'https://picsum.photos/seed/nike4thumb/800/800',
      ),
      ProductMedia(
        url: 'https://picsum.photos/seed/nike5/800/800',
        type: MediaType.image,
      ),
    ],
    variants: _buildVariants(),
    descriptionHtml: '''
<h3>Nike Air Max 270 React ENG</h3>
<p>The Nike Air Max 270 React ENG combines two of Nike's best technologies to create a shoe that's as comfortable as it is stylish. The Nike React foam delivers an incredibly smooth ride, while the Max Air 270 unit provides unparalleled cushioning.</p>

<h4>Key Features</h4>
<ul>
  <li><b>React foam midsole</b> — lightweight, durable cushioning that springs back with every step.</li>
  <li><b>Max Air 270 unit</b> — Nike's tallest Air heel unit yet for plush, bouncy comfort.</li>
  <li><b>Engineered mesh upper</b> — breathable, flexible support that adapts to your foot.</li>
  <li><b>Rubber outsole</b> — durable traction on various surfaces.</li>
</ul>

<p>Whether you're running errands or going for a casual jog, the Air Max 270 React is the perfect companion for everyday comfort and head-turning style.</p>

<h4>Care Instructions</h4>
<p>Spot clean with a damp cloth. Allow to air dry away from direct heat. Do not machine wash or tumble dry.</p>
''',
    specifications: const [
      ProductSpecification(name: 'Brand', value: 'Nike'),
      ProductSpecification(name: 'Model', value: 'Air Max 270 React ENG'),
      ProductSpecification(name: 'Style Code', value: 'CD0113-001'),
      ProductSpecification(name: 'Gender', value: 'Unisex'),
      ProductSpecification(name: 'Upper Material', value: 'Engineered Mesh'),
      ProductSpecification(name: 'Midsole', value: 'React Foam + Air Max 270'),
      ProductSpecification(name: 'Outsole', value: 'Rubber'),
      ProductSpecification(name: 'Closure', value: 'Lace-up'),
      ProductSpecification(name: 'Weight', value: '~280g (US 9)'),
      ProductSpecification(name: 'Country of Origin', value: 'Vietnam'),
    ],
    reviews: [
      ProductReview(
        id: 'r1',
        userName: 'Minh Tran',
        rating: 5.0,
        comment:
            'Absolutely love these shoes! The React foam makes them incredibly comfortable for all-day wear. The Air Max unit gives a nice bouncy feel. Sizing is true to fit. Highly recommend!',
        date: DateTime(2026, 3, 10),
        imageUrls: [
          'https://picsum.photos/seed/rev1a/400/400',
          'https://picsum.photos/seed/rev1b/400/400',
        ],
      ),
      ProductReview(
        id: 'r2',
        userName: 'Linh Nguyen',
        rating: 4.0,
        comment:
            'Great shoes overall. Very comfortable and stylish. Took a couple of days to break in. The black colorway looks even better in person. Only minor issue is they run slightly warm in hot weather.',
        date: DateTime(2026, 3, 5),
      ),
      ProductReview(
        id: 'r3',
        userName: 'Huy Pham',
        rating: 5.0,
        comment:
            'Best sneakers I\'ve owned in years. Perfect for my daily commute. The cushioning is next-level and they look fantastic with both casual and sporty outfits.',
        date: DateTime(2026, 2, 28),
      ),
      ProductReview(
        id: 'r4',
        userName: 'Thao Le',
        rating: 3.0,
        comment:
            'Decent shoes but expected more for the price. The comfort is good but the mesh upper started showing wear after just 2 months of regular use. The color also faded a bit.',
        date: DateTime(2026, 2, 20),
        imageUrls: [
          'https://picsum.photos/seed/rev4/400/400',
        ],
      ),
      ProductReview(
        id: 'r5',
        userName: 'An Vo',
        rating: 4.5,
        comment:
            'Very happy with my purchase. The Navy colorway is gorgeous and the cushioning is excellent. Runs true to size. Would buy again!',
        date: DateTime(2026, 2, 15),
      ),
      ProductReview(
        id: 'r6',
        userName: 'Duc Hoang',
        rating: 5.0,
        comment:
            'These are amazing! I bought the red pair and get compliments everywhere I go. Super comfortable right out of the box. The React technology really makes a difference.',
        date: DateTime(2026, 2, 10),
      ),
    ],
    averageRating: 4.4,
    reviewCount: 128,
  );
}
