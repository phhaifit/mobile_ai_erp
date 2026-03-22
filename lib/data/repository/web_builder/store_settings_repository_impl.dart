import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';

class StoreSettingsRepositoryImpl extends StoreSettingsRepository {
  StoreSettings _mockSettings = StoreSettings(
    storeName: 'Jarvis Store',
    tagline: 'Smart Shopping, Simplified',
    email: 'contact@jarvisstore.com',
    phone: '+84 123 456 789',
    address: '227 Nguyen Van Cu, District 5, HCMC',
    currency: 'VND',
    description:
        'Your one-stop shop for electronics, accessories, and smart home devices.',
  );

  @override
  Future<StoreSettings> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockSettings;
  }

  @override
  Future<void> saveSettings(StoreSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockSettings = settings;
  }
}
