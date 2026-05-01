import 'dart:convert';
import 'dart:io';

const int _proxyPort = 5050;
const String _targetBaseUrl = 'http://localhost:5000';

Future<void> main() async {
  final secrets = await _loadSecrets();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _proxyPort);
  stdout.writeln(
    'Dev auth proxy: http://localhost:$_proxyPort -> $_targetBaseUrl',
  );

  await for (final request in server) {
    await _forward(request, secrets);
  }
}

Future<Map<String, String>> _loadSecrets() async {
  final file = File('dev_secrets.json');
  if (!file.existsSync()) {
    stderr.writeln('Missing dev_secrets.json');
    exitCode = 1;
    exit(1);
  }

  final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  return {
    'accessToken': data['DEV_ACCESS_TOKEN'] as String? ?? '',
    'refreshToken': data['DEV_REFRESH_TOKEN'] as String? ?? '',
    'tenantId': data['DEV_TENANT_ID'] as String? ?? '',
  };
}

Future<void> _forward(HttpRequest source, Map<String, String> secrets) async {
  final client = HttpClient();
  try {
    final body = await source.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    var response = await _send(client, source, body, secrets);

    if (response.statusCode == HttpStatus.unauthorized &&
        await _refresh(client, secrets)) {
      await response.drain<void>();
      response = await _send(client, source, body, secrets);
    }

    await _copyResponse(response, source.response);
  } catch (error) {
    source.response.statusCode = HttpStatus.badGateway;
    source.response.write('Dev auth proxy error: $error');
    await source.response.close();
  } finally {
    client.close(force: true);
  }
}

Future<HttpClientResponse> _send(
  HttpClient client,
  HttpRequest source,
  List<int> body,
  Map<String, String> secrets,
) async {
  final target = Uri.parse('$_targetBaseUrl${source.uri}');
  final proxyRequest = await client.openUrl(source.method, target);

  source.headers.forEach((name, values) {
    if (_skipHeader(name)) return;
    proxyRequest.headers.set(name, values);
  });
  proxyRequest.headers.set(
    HttpHeaders.authorizationHeader,
    'Bearer ${secrets['accessToken']}',
  );
  proxyRequest.headers.set('X-Tenant-Id', secrets['tenantId'] ?? '');
  proxyRequest.add(body);

  return proxyRequest.close();
}

Future<bool> _refresh(HttpClient client, Map<String, String> secrets) async {
  final refreshToken = secrets['refreshToken'];
  if (refreshToken == null || refreshToken.isEmpty) return false;

  final request = await client.getUrl(
    Uri.parse('$_targetBaseUrl/auth/refresh'),
  );
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $refreshToken');
  final response = await request.close();
  final body = await utf8.decoder.bind(response).join();
  if (response.statusCode < 200 || response.statusCode >= 300) return false;

  final data = jsonDecode(body) as Map<String, dynamic>;
  final accessToken = data['token']?['accessToken'] as String?;
  if (accessToken == null || accessToken.isEmpty) return false;

  secrets['accessToken'] = accessToken;
  return true;
}

Future<void> _copyResponse(
  HttpClientResponse source,
  HttpResponse target,
) async {
  target.statusCode = source.statusCode;
  source.headers.forEach((name, values) {
    if (_skipHeader(name)) return;
    target.headers.set(name, values);
  });
  await source.pipe(target);
}

bool _skipHeader(String name) {
  final lower = name.toLowerCase();
  return lower == HttpHeaders.hostHeader ||
      lower == HttpHeaders.contentLengthHeader ||
      lower == HttpHeaders.transferEncodingHeader;
}
