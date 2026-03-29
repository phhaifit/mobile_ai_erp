import 'package:mobile_ai_erp/domain/entity/product/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product/category.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/product/tag.dart';

class MockProductDataSource {
  // Static mock data
  static final List<Category> mockCategories = [
    Category(id: 1, name: "Electronics"),
    Category(id: 2, name: "Accessories"),
    Category(id: 3, name: "Computers"),
  ];

  static final List<Brand> mockBrands = [
    Brand(id: 1, name: "Dell"),
    Brand(id: 2, name: "Logitech"),
    Brand(id: 3, name: "Anker"),
    Brand(id: 4, name: "Apple"),
    Brand(id: 5, name: "HP"),
  ];

  static final List<Tag> mockTags = [
    Tag(id: 1, name: "Electronics"),
    Tag(id: 2, name: "Computers"),
    Tag(id: 3, name: "Accessories"),
    Tag(id: 4, name: "Tech"),
    Tag(id: 5, name: "Wireless"),
    Tag(id: 6, name: "Portable"),
    Tag(id: 7, name: "Gaming"),
    Tag(id: 8, name: "Office"),
  ];

  static final List<Product> mockProducts = [
    Product(
      id: 1,
      name: "Laptop Dell XPS 13",
      sku: "DELL-XPS-13-001",
      price: 1299.99,
      description: "High-performance 13-inch laptop with InfinityEdge display, Intel Core i7, 16GB RAM, 512GB SSD",
      status: ProductStatus.ACTIVE,
      categoryId: 3,
      brandId: 1,
      tagIds: [1, 2, 8],
      imageUrls: ['https://picsum.photos/200/200?random=1', 'https://picsum.photos/200/200?random=2'],
      createdAt: DateTime(2026, 1, 15),
    ),
    Product(
      id: 2,
      name: "Wireless Mouse Logitech MX Master",
      sku: "LOG-MX-MASTER-001",
      price: 99.99,
      description: "Advanced wireless mouse with customizable buttons, precision scrolling, and multi-device connectivity",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 2,
      tagIds: [3, 4, 5, 6],
      imageUrls: ['https://picsum.photos/200/200?random=3'],
      createdAt: DateTime(2026, 1, 20),
    ),
    Product(
      id: 3,
      name: "USB-C Cable Anker 3ft",
      sku: "ANKER-USB-C-002",
      price: 19.99,
      description: "Durable USB-C cable with 60W charging capability, tested for 10,000+ bends",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 3,
      tagIds: [3, 4, 6],
      imageUrls: ['https://picsum.photos/200/200?random=4'],
      createdAt: DateTime(2026, 1, 10),
    ),
    Product(
      id: 4,
      name: "iPad Pro 12.9 Apple",
      sku: "APPLE-IPAD-PRO-001",
      price: 1099.99,
      description: "Powerful tablet with M2 chip, stunning Liquid Retina XDR display, and Apple Pencil support",
      status: ProductStatus.ACTIVE,
      categoryId: 1,
      brandId: 4,
      tagIds: [1, 2, 6],
      imageUrls: ['https://picsum.photos/200/200?random=5', 'https://picsum.photos/200/200?random=6'],
      createdAt: DateTime(2026, 2, 1),
    ),
    Product(
      id: 5,
      name: "Gaming Headset RGB",
      sku: "GAMING-HS-RGB-001",
      price: 149.99,
      description: "Professional gaming headset with 7.1 surround sound, RGB lighting, and noise-cancelling microphone",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 5,
      tagIds: [3, 4, 7, 8],
      imageUrls: ['https://picsum.photos/200/200?random=7'],
      createdAt: DateTime(2026, 2, 3),
    ),
    Product(
      id: 6,
      name: "Monitor HP UltraWide 34",
      sku: "HP-ULTRA-34-001",
      price: 599.99,
      description: "Curved ultrawide 34-inch monitor with 3440x1440 resolution, perfect for productivity and gaming",
      status: ProductStatus.OUT_OF_STOCK,
      categoryId: 1,
      brandId: 5,
      tagIds: [1, 2, 7, 8],
      imageUrls: ['https://picsum.photos/200/200?random=8', 'https://picsum.photos/200/200?random=9', 'https://picsum.photos/200/200?random=10'],
      createdAt: DateTime(2026, 1, 25),
    ),
    Product(
      id: 7,
      name: "Mechanical Keyboard RGB",
      sku: "KEY-MECH-RGB-001",
      price: 129.99,
      description: "Cherry MX mechanical switches with RGB backlighting, aluminum frame, and programmable keys",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 2,
      tagIds: [3, 7, 8],
      imageUrls: ['https://picsum.photos/200/200?random=11'],
      createdAt: DateTime(2026, 2, 5),
    ),
    Product(
      id: 8,
      name: "Laptop HP Pavilion 15",
      sku: "HP-PAV-15-001",
      price: 579.99,
      description: "Reliable 15-inch laptop with Intel Core i5, 8GB RAM, 256GB SSD for everyday computing",
      status: ProductStatus.ACTIVE,
      categoryId: 3,
      brandId: 5,
      tagIds: [2, 8],
      imageUrls: ['https://picsum.photos/200/200?random=12', 'https://picsum.photos/200/200?random=13'],
      createdAt: DateTime(2026, 2, 2),
    ),
    Product(
      id: 9,
      name: "Portable SSD Anker 1TB",
      sku: "ANKER-SSD-1TB-001",
      price: 99.99,
      description: "Ultra-fast portable SSD with 1TB storage, USB-C 3.1 Gen 2, and rugged design",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 3,
      tagIds: [4, 5, 6],
      imageUrls: ['https://picsum.photos/200/200?random=14'],
      createdAt: DateTime(2026, 1, 30),
    ),
    Product(
      id: 10,
      name: "HDMI Cable Premium",
      sku: "HDMI-CABLE-PREM-001",
      price: 29.99,
      description: "High-speed HDMI 2.1 cable supporting 4K@120Hz and 8K@60Hz, 10ft length",
      status: ProductStatus.ACTIVE,
      categoryId: 2,
      brandId: 3,
      tagIds: [3, 4],
      imageUrls: ['https://picsum.photos/200/200?random=15'],
      createdAt: DateTime(2026, 1, 28),
    ),
  ];

  // Simulate incremental ID for new products
  static int _nextId = 11;

  // Get all products
  Future<List<Product>> getProducts() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return mockProducts;
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create product
  Future<int> createProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 400));
    final newProduct = product.copyWith(
      id: _nextId,
      createdAt: DateTime.now(),
    );
    mockProducts.add(newProduct);
    _nextId++;
    return newProduct.id ?? 0;
  }

  // Update product
  Future<int> updateProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 400));
    final index = mockProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      mockProducts[index] = product;
      return 1;
    }
    return 0;
  }

  // Delete product
  Future<int> deleteProduct(int id) async {
    await Future.delayed(Duration(milliseconds: 400));
    final initialLength = mockProducts.length;
    mockProducts.removeWhere((p) => p.id == id);
    return mockProducts.length < initialLength ? 1 : 0;
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    await Future.delayed(Duration(milliseconds: 200));
    return mockCategories;
  }

  // Get all brands
  Future<List<Brand>> getBrands() async {
    await Future.delayed(Duration(milliseconds: 200));
    return mockBrands;
  }

  // Get all tags
  Future<List<Tag>> getTags() async {
    await Future.delayed(Duration(milliseconds: 200));
    return mockTags;
  }

  // Helper: Get tag name by ID
  static String getTagName(int tagId) {
    try {
      return mockTags.firstWhere((tag) => tag.id == tagId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper: Get tag names from tag IDs
  static List<String> getTagNames(List<int> tagIds) {
    return tagIds.map((id) => getTagName(id)).toList();
  }

  // Helper: Get category name by ID
  static String getCategoryName(int categoryId) {
    try {
      return mockCategories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper: Get brand name by ID
  static String getBrandName(int brandId) {
    try {
      return mockBrands.firstWhere((brand) => brand.id == brandId).name;
    } catch (e) {
      return 'Unknown';
    }
  }
}
