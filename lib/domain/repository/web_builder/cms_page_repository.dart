import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page_list.dart';

abstract class CmsPageRepository {
  Future<CmsPageList> getPages();

  Future<CmsPage?> getPageById(String id);

  Future<void> savePage(CmsPage page);

  Future<void> deletePage(String id);
}
