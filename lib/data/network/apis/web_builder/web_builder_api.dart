import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class WebBuilderApi {
  final DioClient _dioClient;

  WebBuilderApi(this._dioClient);

  // ─── Store Settings ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStoreSettings() async {
    final res = await _dioClient.dio.get(Endpoints.storeSettings);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateStoreSettings(
    Map<String, dynamic> body,
  ) async {
    final res = await _dioClient.dio.patch(
      Endpoints.storeSettings,
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ─── CMS Pages ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCmsPages({
    int page = 1,
    int pageSize = 50,
    String? search,
    String? status,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.cmsPages,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getCmsPageById(String id) async {
    final res = await _dioClient.dio.get(Endpoints.cmsPageById(id));
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createCmsPage(Map<String, dynamic> body) async {
    final res = await _dioClient.dio.post(Endpoints.cmsPages, data: body);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateCmsPage(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await _dioClient.dio.patch(
      Endpoints.cmsPageById(id),
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> deleteCmsPage(String id) async {
    await _dioClient.dio.delete(Endpoints.cmsPageById(id));
  }

  Future<Map<String, dynamic>> publishCmsPage(String id, bool published) async {
    final res = await _dioClient.dio.post(
      Endpoints.cmsPagePublish(id),
      data: {'published': published},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ─── Themes ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getThemes({String? category}) async {
    final res = await _dioClient.dio.get(
      Endpoints.themes,
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    return List<dynamic>.from(res.data as List);
  }

  Future<Map<String, dynamic>?> getActiveTheme() async {
    final res = await _dioClient.dio.get(Endpoints.activeTheme);
    if (res.data == null) return null;
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> setActiveTheme(String themeId) async {
    final res = await _dioClient.dio.patch(
      Endpoints.activeTheme,
      data: {'themeId': themeId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
