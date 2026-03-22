import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';

class WebThemeList {
  final List<WebTheme>? themes;

  WebThemeList({this.themes});

  factory WebThemeList.fromJson(List<dynamic> json) {
    List<WebTheme> themes = json.map((t) => WebTheme.fromMap(t)).toList();
    return WebThemeList(themes: themes);
  }
}
