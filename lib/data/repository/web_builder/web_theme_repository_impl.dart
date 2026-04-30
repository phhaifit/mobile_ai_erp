import 'dart:async';
import 'dart:developer' as developer;

import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme_list.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

class WebThemeRepositoryImpl extends WebThemeRepository {
  final WebBuilderApi _api;

  WebThemeRepositoryImpl(this._api);

  @override
  Future<WebThemeList> getThemes() async {
    final results = await Future.wait([
      _api.getThemes(),
      _api.getActiveTheme(),
    ]);

    final themesJson = results[0] as List<dynamic>;
    final activeJson = results[1] as Map<String, dynamic>?;
    final activeId = activeJson?['themeId'] as String?;

    final themes = themesJson
        .whereType<Map>()
        .map((m) => _mapFromApi(
              Map<String, dynamic>.from(m),
              isActive: activeId != null && m['id'] == activeId,
            ))
        .toList();

    return WebThemeList(themes: themes);
  }

  @override
  Future<WebTheme?> getThemeById(String id) async {
    // BE has no GET /themes/:id endpoint — fetch full list and pick.
    try {
      final list = await getThemes();
      return list.themes!.firstWhere((t) => t.id == id);
    } on StateError {
      // firstWhere throws StateError when not found
      return null;
    }
  }

  @override
  Future<void> applyTheme(
    String id, {
    int? primaryColor,
    int? accentColor,
  }) async {
    if (primaryColor != null || accentColor != null) {
      developer.log(
        'applyTheme: BE does not support color overrides yet — '
        'primaryColor/accentColor params will be ignored.',
        name: 'WebThemeRepositoryImpl',
      );
    }
    await _api.setActiveTheme(id);
  }

  WebTheme _mapFromApi(
    Map<String, dynamic> json, {
    required bool isActive,
  }) {
    final fontHeading = json['fontHeading'] as String?;
    final fontBody = json['fontBody'] as String?;
    final fonts = <String>[
      if (fontHeading != null && fontHeading.isNotEmpty) fontHeading,
      if (fontBody != null && fontBody.isNotEmpty && fontBody != fontHeading)
        fontBody,
    ];

    final category = (json['category'] as String?)?.toLowerCase() ?? '';
    final primary = _parseHexColor(json['primaryColor'] as String?);

    return WebTheme(
      id: json['id'] as String?,
      name: json['name'] as String?,
      // BE has no description field — leave null. UI may render previewImage instead.
      description: null,
      primaryColor: primary,
      accentColor: _parseHexColor(json['accentColor'] as String?),
      backgroundColor: _deriveBackgroundColor(primary, category),
      category: json['category'] as String?,
      fonts: fonts,
      isActive: isActive,
    );
  }

  /// Parse "#RRGGBB" or "#AARRGGBB" hex into ARGB int. Falls back to opaque black.
  int _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return 0xFF000000;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return int.tryParse(value, radix: 16) ?? 0xFF000000;
  }

  /// Derive a sensible page background color from the primary color and category.
  /// Dark themes get a dark neutral; otherwise we tint primary toward white (~92% white).
  int _deriveBackgroundColor(int primaryArgb, String category) {
    if (category == 'dark') return 0xFF1A1A1A;

    final r = (primaryArgb >> 16) & 0xFF;
    final g = (primaryArgb >> 8) & 0xFF;
    final b = primaryArgb & 0xFF;
    const blend = 0.92;
    int mix(int channel) =>
        (channel + (255 - channel) * blend).clamp(0, 255).toInt();
    return (0xFF << 24) | (mix(r) << 16) | (mix(g) << 8) | mix(b);
  }
}
