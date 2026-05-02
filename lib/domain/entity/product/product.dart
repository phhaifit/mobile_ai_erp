import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';

enum ProductType {
  standalone,
  group,
  variant
}

/// Product entity class. Mainly contains information shown to customers of the store
/// Used in storefront pages
class Product {
  final String? id;
  final String name;
  final String sku;
  final String? barcode;
  final String? description;
  final String? webTitle;
  final String? webDescription;
  final String? brandId;
  final String? brandName;
  final String? categoryId;
  final String? categoryName;
  final String? parentId;
  final String? attributeSetId;
  final ProductType type; // e.g., "standalone"
  final ProductStatus status; // e.g., "selling"
  final int? warrantyMonths;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightG;
  final double basePrice;
  final double sellingPrice;
  final String? imageUrl;
  final List<String> images;
  final List<String> attributeValueIds;
  final List<dynamic> variants;
  final List<dynamic> suppliers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Metadata 
  // final Category? category;
  // final Brand? brand;
  final List<Tag> tags; // list of tags, can be empty
  final List<AttributeSet> attributes; // list of attributes, can be empty
  final dynamic productMetadata;
  final bool isFlashSale;
  final DateTime? flashSaleFrom;
  final DateTime? flashSaleTo;



  Product({
    this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.description,
    this.webTitle,
    this.webDescription,
    this.brandId,
    this.brandName,
    this.categoryId,
    this.categoryName,
    this.parentId,
    this.attributeSetId,
    required this.type,
    required this.status,
    required this.warrantyMonths,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightG,
    required this.basePrice,
    required this.sellingPrice,
    this.imageUrl,
    this.images = const <String>[],
    this.attributeValueIds = const <String>[],
    this.variants = const <dynamic>[],
    this.suppliers = const <dynamic>[],
    this.createdAt,
    this.updatedAt,
    // this.category,
    // this.brand,
    this.tags = const <Tag>[],
    this.attributes = const <AttributeSet>[],
    this.productMetadata,
    this.isFlashSale = false,
    this.flashSaleFrom,
    this.flashSaleTo,
  }) {
    // Validation
    if (basePrice < 0) {
      throw ArgumentError('Base price cannot be negative');
    }
    if (sellingPrice < 0) {
      throw ArgumentError('Selling price cannot be negative');
    }
  }

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"] ?? "",
        sku: json["sku"] ?? "",
        barcode: json["barcode"],
        description: json["description"],
        webTitle: json["webTitle"],
        webDescription: json["webDescription"],
        brandId: json["brandId"],
        brandName: json["brandName"],
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        parentId: json["parentId"],
        attributeSetId: json["attributeSetId"],
        type: ProductType.values.byName(json["type"] ?? "standalone"),
        status: switch (json["status"] ?? "selling") {
          "new" => ProductStatus.NEW,
          "selling" => ProductStatus.ACTIVE,
          "out_of_stock" => ProductStatus.OUT_OF_STOCK,
          "discontinued" => ProductStatus.DISCONTINUED,
          _ => ProductStatus.ACTIVE,
        },
        warrantyMonths: json["warrantyMonths"] ?? 0,
        lengthCm: (json["lengthCm"] as num?)?.toDouble(),
        widthCm: (json["widthCm"] as num?)?.toDouble(),
        heightCm: (json["heightCm"] as num?)?.toDouble(),
        weightG: (json["weightG"] as num?)?.toDouble(),
        basePrice: (json["basePrice"] as num?)?.toDouble() ?? 0.0,
        sellingPrice: (json["sellingPrice"] as num?)?.toDouble() ?? 0.0,
        imageUrl: json["imageUrl"],
        images: List<String>.from(json["images"] ?? []),
        attributeValueIds: List<String>.from(json["attributeValueIds"] ?? []),
        variants: json["variants"] ?? [],
        suppliers: json["suppliers"] ?? [],
        createdAt: json["createdAt"] != null 
            ? DateTime.parse(json["createdAt"] as String)
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"] as String)
            : null,
        productMetadata: json["productMetadata"],
        isFlashSale: json["isFlashSale"] ?? false,
        flashSaleFrom: json["flashSaleFrom"] != null
            ? DateTime.parse(json["flashSaleFrom"] as String)
            : null,
        flashSaleTo: json["flashSaleTo"] != null
            ? DateTime.parse(json["flashSaleTo"] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "sku": sku,
        "barcode": barcode,
        "description": description,
        "webTitle": webTitle,
        "webDescription": webDescription,
        "brandId": brandId,
        "brandName": brandName,
        "categoryId": categoryId,
        "categoryName": categoryName,
        "parentId": parentId,
        "attributeSetId": attributeSetId,
        "type": type,
        "status": status,
        "warrantyMonths": warrantyMonths,
        "lengthCm": lengthCm,
        "widthCm": widthCm,
        "heightCm": heightCm,
        "weightG": weightG,
        "basePrice": basePrice,
        "sellingPrice": sellingPrice,
        "imageUrl": imageUrl,
        "images": images,
        "attributeValueIds": attributeValueIds,
        "variants": variants,
        "suppliers": suppliers,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "productMetadata": productMetadata,
        "isFlashSale": isFlashSale,
        "flashSaleFrom": flashSaleFrom?.toIso8601String(),
        "flashSaleTo": flashSaleTo?.toIso8601String(),
      };

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? description,
    String? webTitle,
    String? webDescription,
    String? brandId,
    String? brandName,
    String? categoryId,
    String? categoryName,
    String? parentId,
    String? attributeSetId,
    ProductType? type,
    ProductStatus? status,
    int? warrantyMonths,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? weightG,
    double? basePrice,
    double? sellingPrice,
    String? imageUrl,
    List<String>? images,
    List<String>? attributeValueIds,
    List<dynamic>? variants,
    List<dynamic>? suppliers,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
    Brand? brand,
    List<Tag>? tags,
    List<AttributeSet>? attributes,
    dynamic productMetadata,
    bool? isFlashSale,
    DateTime? flashSaleFrom,
    DateTime? flashSaleTo,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      webTitle: webTitle ?? this.webTitle,
      webDescription: webDescription ?? this.webDescription,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      parentId: parentId ?? this.parentId,
      attributeSetId: attributeSetId ?? this.attributeSetId,
      type: type ?? this.type,
      status: status ?? this.status,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      weightG: weightG ?? this.weightG,
      basePrice: basePrice ?? this.basePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      attributeValueIds: attributeValueIds ?? this.attributeValueIds,
      variants: variants ?? this.variants,
      suppliers: suppliers ?? this.suppliers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // category: category ?? this.category,
      // brand: brand ?? this.brand,
      tags: tags ?? this.tags,
      attributes: attributes ?? this.attributes,
      productMetadata: productMetadata ?? this.productMetadata,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      flashSaleFrom: flashSaleFrom ?? this.flashSaleFrom,
      flashSaleTo: flashSaleTo ?? this.flashSaleTo,
    );
  }
}

