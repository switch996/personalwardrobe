import 'dart:convert';
import 'dart:io';

class BackendApi {
  BackendApi({String? baseUrl})
      : _baseUrl = (baseUrl ?? _defaultBaseUrl()).replaceAll(RegExp(r'/+$'), '');

  final HttpClient _httpClient = HttpClient();
  final String _baseUrl;

  static const bool _skipAuth = bool.fromEnvironment(
    'PW_SKIP_AUTH',
    defaultValue: true,
  );

  String? _accessToken;
  String? _refreshToken;

  String get baseUrl => _baseUrl;

  String get _origin {
    final uri = Uri.parse(_baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  static String _defaultBaseUrl() {
    const fromEnv = String.fromEnvironment('PW_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://127.0.0.1:8080/api/v1';
  }

  Future<void> ensureAuthenticated() async {
    if (_skipAuth) return;
    if (_accessToken?.isNotEmpty == true) return;

    const phone = String.fromEnvironment('PW_PHONE', defaultValue: '13800000000');
    const code = String.fromEnvironment('PW_SMS_CODE', defaultValue: '123456');

    await _requestJson(
      method: 'POST',
      path: '/auth/sms/send',
      body: <String, dynamic>{'phone': phone},
      authenticated: false,
      retryOnUnauthorized: false,
    );

    try {
      final tokenResponse = await _requestJson(
        method: 'POST',
        path: '/auth/sms/verify',
        body: <String, dynamic>{'phone': phone, 'code': code},
        authenticated: false,
        retryOnUnauthorized: false,
      );
      _setTokens(tokenResponse);
    } on BackendApiException catch (e) {
      throw BackendApiException(
        statusCode: e.statusCode,
        code: e.code,
        message:
            'Auto login failed. Configure --dart-define=PW_PHONE and --dart-define=PW_SMS_CODE with valid values.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listOutfits() async {
    return _listPaged(
      '/outfits',
      query: <String, String>{'sortBy': 'date', 'sortOrder': 'desc'},
    );
  }

  Future<Map<String, dynamic>> createOutfit(Map<String, dynamic> body) {
    return _requestJson(method: 'POST', path: '/outfits', body: body);
  }

  Future<Map<String, dynamic>> updateOutfit(String id, Map<String, dynamic> body) {
    return _requestJson(method: 'PUT', path: '/outfits/$id', body: body);
  }

  Future<void> deleteOutfit(String id) async {
    await _requestJson(method: 'DELETE', path: '/outfits/$id');
  }

  Future<List<Map<String, dynamic>>> listClosetItems() async {
    return _listPaged(
      '/closet-items',
      query: <String, String>{'sortBy': 'updatedAt', 'sortOrder': 'desc'},
    );
  }

  Future<Map<String, dynamic>> createClosetItem(Map<String, dynamic> body) {
    return _requestJson(method: 'POST', path: '/closet-items', body: body);
  }

  Future<Map<String, dynamic>> updateClosetItem(String id, Map<String, dynamic> body) {
    return _requestJson(method: 'PUT', path: '/closet-items/$id', body: body);
  }

  Future<void> deleteClosetItem(String id) async {
    await _requestJson(method: 'DELETE', path: '/closet-items/$id');
  }

  Future<Map<String, dynamic>> uploadMedia(String filePath) async {
    if (!_skipAuth) {
      await ensureAuthenticated();
    }
    return _uploadMediaInternal(filePath, allowRetry: true);
  }

  String normalizeMediaUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$_origin$trimmed';
    }
    return '$_origin/$trimmed';
  }

  Future<List<Map<String, dynamic>>> _listPaged(
    String path, {
    Map<String, String> query = const <String, String>{},
  }) async {
    final items = <Map<String, dynamic>>[];
    var page = 1;
    const pageSize = 100;
    var total = 0;

    while (true) {
      final response = await _requestJson(
        method: 'GET',
        path: path,
        query: <String, String>{...query, 'page': '$page', 'pageSize': '$pageSize'},
      );

      final pageItems = (response['items'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      items.addAll(pageItems);
      total = (response['total'] as num?)?.toInt() ?? items.length;

      if (pageItems.isEmpty || items.length >= total) {
        break;
      }
      page += 1;
    }

    return items;
  }

  Future<Map<String, dynamic>> _uploadMediaInternal(
    String filePath, {
    required bool allowRetry,
  }) async {
    final file = File(filePath.trim());
    if (!await file.exists()) {
      throw const BackendApiException(
        statusCode: 400,
        code: 'BAD_REQUEST',
        message: 'Image file not found.',
      );
    }

    final boundary = '----pw-${DateTime.now().microsecondsSinceEpoch}';
    final uri = _buildUri('/media/upload');
    final request = await _httpClient.postUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (!_skipAuth && _accessToken?.isNotEmpty == true) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_accessToken');
    }
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    final fileName = file.uri.pathSegments.isEmpty ? 'image.jpg' : file.uri.pathSegments.last;
    final contentType = _contentTypeFor(fileName);

    request.write('--$boundary\r\n');
    request.write('Content-Disposition: form-data; name="file"; filename="$fileName"\r\n');
    request.write('Content-Type: $contentType\r\n\r\n');
    request.add(await file.readAsBytes());
    request.write('\r\n--$boundary--\r\n');

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();

    if (!_skipAuth && response.statusCode == 401 && allowRetry) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _uploadMediaInternal(filePath, allowRetry: false);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const BackendApiException(
        statusCode: 500,
        code: 'INVALID_RESPONSE',
        message: 'Invalid media response.',
      );
    }

    throw _buildException(response.statusCode, responseText);
  }

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String> query = const <String, String>{},
    bool authenticated = true,
    bool retryOnUnauthorized = true,
  }) async {
    if (authenticated && !_skipAuth) {
      await ensureAuthenticated();
    }

    final response = await _send(
      method: method,
      path: path,
      body: body,
      query: query,
      authenticated: authenticated,
    );
    final responseText = await response.transform(utf8.decoder).join();

    if (!_skipAuth && response.statusCode == 401 && authenticated && retryOnUnauthorized) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _requestJson(
          method: method,
          path: path,
          body: body,
          query: query,
          authenticated: authenticated,
          retryOnUnauthorized: false,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseText.trim().isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const BackendApiException(
        statusCode: 500,
        code: 'INVALID_RESPONSE',
        message: 'Invalid JSON response.',
      );
    }

    throw _buildException(response.statusCode, responseText);
  }

  Future<HttpClientResponse> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String> query = const <String, String>{},
    required bool authenticated,
  }) async {
    final request = await _httpClient.openUrl(method, _buildUri(path, query: query));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (!_skipAuth && authenticated && _accessToken?.isNotEmpty == true) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_accessToken');
    }
    if (body != null) {
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(body));
    }
    return request.close();
  }

  Uri _buildUri(String path, {Map<String, String> query = const <String, String>{}}) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  Future<bool> _tryRefreshToken() async {
    if (_skipAuth) return false;

    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      _accessToken = null;
      return false;
    }

    try {
      final response = await _requestJson(
        method: 'POST',
        path: '/auth/refresh',
        body: <String, dynamic>{'refreshToken': refreshToken},
        authenticated: false,
        retryOnUnauthorized: false,
      );
      _setTokens(response);
      return true;
    } catch (_) {
      _accessToken = null;
      _refreshToken = null;
      return false;
    }
  }

  void _setTokens(Map<String, dynamic> payload) {
    _accessToken = payload['accessToken'] as String?;
    _refreshToken = payload['refreshToken'] as String?;
  }

  String _contentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }

  BackendApiException _buildException(int statusCode, String responseText) {
    try {
      final decoded = jsonDecode(responseText);
      if (decoded is Map<String, dynamic>) {
        return BackendApiException(
          statusCode: statusCode,
          code: decoded['code'] as String?,
          message: (decoded['message'] as String?) ?? 'Request failed.',
        );
      }
    } catch (_) {
      // Ignore parse errors and fallback below.
    }

    return BackendApiException(
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
      message: responseText.trim().isEmpty ? 'Request failed.' : responseText,
    );
  }
}

class BackendApiException implements Exception {
  const BackendApiException({required this.statusCode, required this.code, required this.message});

  final int statusCode;
  final String? code;
  final String message;

  @override
  String toString() {
    return 'BackendApiException(status=$statusCode, code=$code, message=$message)';
  }
}
