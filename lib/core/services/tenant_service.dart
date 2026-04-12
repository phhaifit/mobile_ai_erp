import 'package:flutter/foundation.dart';

class TenantService {
  static const String _hardcodedTenantId = '9b4b42fa-25ac-4689-94fa-62a000d4fc8b';
  
  // Hardcoded tenant ID for now until login is implemented
  Future<String?> getCurrentTenantId() async {
    // TODO: In future, get from localStorage after login implementation
    return _hardcodedTenantId;
  }
  
  // For future use when login is implemented
  Future<void> setTenantId(String tenantId) async {
    // TODO: Store in localStorage when login is implemented
    // For now, this is a no-op since we're using hardcoded value
  }
  
  // For testing purposes
  static String get hardcodedTenantId => _hardcodedTenantId;
}
