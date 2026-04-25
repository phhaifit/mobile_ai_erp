import 'package:flutter/foundation.dart' show kIsWeb;

class Endpoints {
  Endpoints._();

  static const String _host = kIsWeb ? 'localhost' : '10.0.2.2';
  static const String baseUrl = 'http://$_host:5000';

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
}
