import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';

class StoreSettingsRepositoryImpl extends StoreSettingsRepository {
  final WebBuilderApi _api;

  StoreSettingsRepositoryImpl(this._api);

  @override
  Future<StoreSettings> getSettings() async {
    final json = await _api.getStoreSettings();
    return _mapFromApi(json);
  }

  @override
  Future<void> saveSettings(StoreSettings settings) async {
    await _api.updateStoreSettings(_mapToApi(settings));
  }

  StoreSettings _mapFromApi(Map<String, dynamic> json) {
    return StoreSettings(
      storeName: json['name'] as String?,
      tagline: json['tagline'] as String?,
      email: json['contactEmail'] as String?,
      phone: json['contactPhone'] as String?,
      address: json['address'] as String?,
      currency: json['currency'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> _mapToApi(StoreSettings s) {
    final body = <String, dynamic>{};
    if (s.storeName != null) body['name'] = s.storeName;
    if (s.tagline != null) body['tagline'] = s.tagline;
    if (s.email != null) body['contact_email'] = s.email;
    if (s.phone != null) body['contact_phone'] = s.phone;
    if (s.address != null) body['address'] = s.address;
    if (s.currency != null) body['currency'] = s.currency;
    if (s.description != null) body['description'] = s.description;
    if (s.logoUrl != null) body['logo_url'] = s.logoUrl;
    return body;
  }
}
