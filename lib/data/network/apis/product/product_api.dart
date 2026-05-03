import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';

/// ProductApi handles all product-related network requests
class ProductApi {
  ProductApi(this._dioClient);

  final DioClient _dioClient;

  /// Saves a product by sending a POST request for new products or PATCH for updates
  /// Returns the saved Product entity
  Future<Product> saveProduct(Product product) async {
    try {
      final payload = _buildProductPayload(product);

      final response = product.id == null || product.id!.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/erp/products',
              data: payload,
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/erp/products/${product.id}',
              data: payload,
              options: Options(contentType: Headers.jsonContentType),
            );

      return _mapProduct(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw _mapProductError(error);
    }
  }

  /// Builds the request payload from a Product entity
  Map<String, dynamic> _buildProductPayload(Product product) {
    final payload = <String, dynamic>{
      'sku': product.sku,
      'name': product.name,
    };

    // Add optional fields if they are not null or empty
    if (product.barcode != null && product.barcode!.isNotEmpty) {
      payload['barcode'] = product.barcode;
    }
    if (product.description != null && product.description!.isNotEmpty) {
      payload['description'] = product.description;
    }
    if (product.webTitle != null && product.webTitle!.isNotEmpty) {
      payload['web_title'] = product.webTitle;
    }
    if (product.webDescription != null && product.webDescription!.isNotEmpty) {
      payload['web_description'] = product.webDescription;
    }
    if (product.brandId != null && product.brandId!.isNotEmpty) {
      payload['brand_id'] = product.brandId;
    }
    if (product.categoryId != null && product.categoryId!.isNotEmpty) {
      payload['category_id'] = product.categoryId;
    }
    
    payload['type'] = product.type.name;
    payload['status'] = _mapProductStatusToString(product.status);
    payload['warranty_months'] = product.warrantyMonths ?? 0;

    // Dimensions
    if (product.lengthCm != null) {
      payload['length_cm'] = product.lengthCm;
    }
    if (product.widthCm != null) {
      payload['width_cm'] = product.widthCm;
    }
    if (product.heightCm != null) {
      payload['height_cm'] = product.heightCm;
    }
    if (product.weightG != null) {
      payload['weight_g'] = product.weightG;
    }

    payload['base_price'] = product.basePrice;
    if (product.costPrice != null) {
      payload['cost_price'] = product.costPrice;
    }
    payload['selling_price'] = product.sellingPrice;

    // Images
    if (product.images.isNotEmpty) {
      payload['images'] = product.images
          .asMap()
          .entries
          .map((entry) => {
                'url': entry.value,
                'isPrimary': entry.key == 0,
                'sortOrder': entry.key,
              })
          .toList();
    }

    // Tags
    if (product.tagIds != null && product.tagIds!.isNotEmpty) {
      payload['tag_ids'] = product.tagIds;
    }

    // Suppliers
    if (product.suppliers.isNotEmpty) {
      payload['suppliers'] = product.suppliers;
    }

    // Variants
    if (product.variants.isNotEmpty) {
      payload['variants'] = product.variants;
    }

    return payload;
  }

  /// Maps the API response to a Product entity
  Product _mapProduct(Map<String, dynamic> json) {
    return Product.fromMap(json);
  }

  /// Maps DioException to a readable error message
  Exception _mapProductError(DioException error) {
    // Handle connection errors
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }

    final message = _extractErrorMessage(error.response?.data);
    if (message != null && message.isNotEmpty) {
      return Exception(message);
    }

    return Exception(
      error.message ?? 'An unknown error occurred while saving the product.',
    );
  }

  /// Extracts error message from response data
  String? _extractErrorMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final directMessage = data['message']?.toString();
      if (directMessage != null && directMessage.isNotEmpty) {
        return directMessage;
      }

      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final nestedMessage = error['message']?.toString();
        if (nestedMessage != null && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return null;
  }

  /// Maps ProductStatus enum to API string format
  String _mapProductStatusToString(ProductStatus status) {
    return switch (status) {
      ProductStatus.NEW => 'new',
      ProductStatus.ACTIVE => 'selling',
      ProductStatus.OUT_OF_STOCK => 'out_of_stock',
      ProductStatus.DISCONTINUED => 'discontinued',
    };
  }
}