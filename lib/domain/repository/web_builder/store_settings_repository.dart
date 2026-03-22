import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';

abstract class StoreSettingsRepository {
  Future<StoreSettings> getSettings();

  Future<void> saveSettings(StoreSettings settings);
}
