import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';

class BrandLogoAvatar extends StatelessWidget {
  const BrandLogoAvatar({
    super.key,
    required this.name,
    this.logoUrl,
    this.radius = 22,
  });

  final String name;
  final String? logoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = resolveBrandLogoUrl(
      logoUrl,
      apiBaseUrl: _configuredApiBaseUrl(),
    );
    if (normalizedUrl == null || !_isAbsoluteUrl(normalizedUrl)) {
      return _IconAvatar(radius: radius);
    }

    final size = radius * 2;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          normalizedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _IconAvatar(radius: radius),
        ),
      ),
    );
  }

  bool _isAbsoluteUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String? _configuredApiBaseUrl() {
    if (!getIt.isRegistered<DioConfigs>()) {
      return null;
    }
    return getIt<DioConfigs>().baseUrl;
  }
}

String? resolveBrandLogoUrl(String? logoUrl, {String? apiBaseUrl}) {
  final normalizedUrl = logoUrl?.trim();
  if (normalizedUrl == null || normalizedUrl.isEmpty) {
    return null;
  }
  if (normalizedUrl.startsWith('/uploads/')) {
    final baseUri = Uri.tryParse(apiBaseUrl ?? '');
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      return normalizedUrl;
    }
    return Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: normalizedUrl,
    ).toString();
  }
  return normalizedUrl;
}

class _IconAvatar extends StatelessWidget {
  const _IconAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.workspace_premium_outlined,
      size: radius * 1.4,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
