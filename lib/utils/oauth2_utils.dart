import 'package:flutter/foundation.dart';

class OAuth2Utils {
  static (String, String) getRedirectUri() {
    if (kIsWeb) {
      final callbackUri = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
        path: '/auth.html',
      );
      return (Uri.base.scheme, callbackUri.toString());
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux ||
       defaultTargetPlatform == TargetPlatform.macOS) {
        // TODO: dynamic port
      return ('http://localhost:13123', 'http://localhost:13123/');
    } else if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      return ('mobile-ai-erp', 'mobile-ai-erp://');
    }
    throw UnimplementedError();
  }

}