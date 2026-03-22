import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme_list.dart';

abstract class WebThemeRepository {
  Future<WebThemeList> getThemes();

  Future<WebTheme?> getThemeById(String id);

  Future<void> applyTheme(String id, {int? primaryColor, int? accentColor});
}
