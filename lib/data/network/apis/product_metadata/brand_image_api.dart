import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';

const int _maxBrandImageMB = 10;
const int _maxBrandImageBytes = _maxBrandImageMB * 1024 * 1024;
const String _missingBrandImageDataMessage =
    'Unable to access the selected image file. Please try selecting the image again.';
const String _oversizedBrandImageMessage =
    'Selected image is too large. Choose an image smaller than $_maxBrandImageMB MB.';

class BrandImageApi {
  BrandImageApi(this._dioClient);

  final DioClient _dioClient;

  Future<BrandImage?> getBrandImage(String brandId) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        erpMetadataPath('/brands/$brandId/images'),
      );
      final data = response.data;
      if (data == null || data is String) {
        return null;
      }
      if (data is! Map<String, dynamic>) {
        return null;
      }
      return _mapBrandImage(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw mapMetadataWriteError(error);
    }
  }

  Future<BrandImage> uploadBrandImage({
    required String brandId,
    required PlatformFile file,
  }) async {
    try {
      final multipartFile = await _buildMultipartFile(file);
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        erpMetadataPath('/brands/$brandId/images/upload'),
        data: FormData.fromMap(<String, dynamic>{'file': multipartFile}),
      );
      return _mapBrandImage(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteBrandImage(String brandId) async {
    try {
      await _dioClient.dio.delete<void>(erpMetadataPath('/brands/$brandId/images'));
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<MultipartFile> _buildMultipartFile(PlatformFile file) async {
    if (file.size > _maxBrandImageBytes) {
      throw const FormatException(_oversizedBrandImageMessage);
    }

    final bytes = file.bytes;
    if (bytes != null) {
      return MultipartFile.fromBytes(bytes, filename: file.name);
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      throw const FormatException(_missingBrandImageDataMessage);
    }

    try {
      return await MultipartFile.fromFile(path, filename: file.name);
    } on Object {
      throw const FormatException(_missingBrandImageDataMessage);
    }
  }

  BrandImage _mapBrandImage(Map<String, dynamic> json) {
    return BrandImage(
      brandId: json['brandId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      createdAt: parseRequiredMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Brand image',
      ),
      updatedAt: parseRequiredMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Brand image',
      ),
    );
  }
}
