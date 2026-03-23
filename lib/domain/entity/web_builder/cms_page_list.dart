import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';

class CmsPageList {
  final List<CmsPage>? pages;

  CmsPageList({this.pages});

  factory CmsPageList.fromJson(List<dynamic> json) {
    List<CmsPage> pages = json.map((page) => CmsPage.fromMap(page)).toList();
    return CmsPageList(pages: pages);
  }
}
