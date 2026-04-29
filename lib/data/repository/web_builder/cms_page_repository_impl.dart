import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page_list.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/content_block.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';

class CmsPageStatus {
  CmsPageStatus._();
  static const String published = 'Published';
  static const String draft = 'Draft';
}

class CmsPageRepositoryImpl extends CmsPageRepository {
  final WebBuilderApi _api;

  CmsPageRepositoryImpl(this._api);

  @override
  Future<CmsPageList> getPages() async {
    final res = await _api.getCmsPages(pageSize: 100);
    final data = (res['data'] as List?) ?? const [];
    final pages = data
        .whereType<Map>()
        .map((m) => _mapFromApi(Map<String, dynamic>.from(m)))
        .toList();
    return CmsPageList(pages: pages);
  }

  @override
  Future<CmsPage?> getPageById(String id) async {
    try {
      final json = await _api.getCmsPageById(id);
      return _mapFromApi(json);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> savePage(CmsPage page) async {
    final body = _mapToApi(page);
    if (page.id == null || page.id!.isEmpty) {
      await _api.createCmsPage(body);
    } else {
      // server doesn't accept publish state in PATCH — strip if present
      body.remove('is_published');
      await _api.updateCmsPage(page.id!, body);
    }
  }

  @override
  Future<void> deletePage(String id) async {
    await _api.deleteCmsPage(id);
  }

  @override
  Future<void> publishPage(String id, bool published) async {
    await _api.publishCmsPage(id, published);
  }

  CmsPage _mapFromApi(Map<String, dynamic> json) {
    final isPublished = json['isPublished'] as bool? ?? false;
    final updatedAt = json['updatedAt'] as String?;
    final blocksJson = json['contentBlocks'] as List?;
    return CmsPage(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['pageType'] as String?,
      status: isPublished ? CmsPageStatus.published : CmsPageStatus.draft,
      lastModified: updatedAt != null ? DateTime.tryParse(updatedAt) : null,
      isPublished: isPublished,
      blocks: blocksJson
          ?.whereType<Map>()
          .map(
            (b) => ContentBlock(
              type: b['type'] as String?,
              title: b['title'] as String? ?? b['type'] as String?,
            ),
          )
          .toList(),
      metaTitle: json['metaTitle'] as String?,
      metaDescription: json['metaDescription'] as String?,
      slug: json['urlSlug'] as String?,
    );
  }

  Map<String, dynamic> _mapToApi(CmsPage page) {
    final body = <String, dynamic>{};
    if (page.title != null) body['title'] = page.title;
    if (page.description != null) body['description'] = page.description;
    if (page.type != null) body['page_type'] = page.type;
    if (page.slug != null) body['url_slug'] = page.slug;
    if (page.metaTitle != null) body['meta_title'] = page.metaTitle;
    if (page.metaDescription != null) {
      body['meta_description'] = page.metaDescription;
    }
    if (page.blocks != null) {
      body['content_blocks'] = page.blocks!
          .asMap()
          .entries
          .map((e) => {
                'type': e.value.type,
                'title': e.value.title,
                'order': e.key,
              })
          .toList();
    }
    return body;
  }
}
