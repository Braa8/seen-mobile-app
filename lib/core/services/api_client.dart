import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, SessionService? session})
    : _client = client ?? http.Client(),
      _session = session ?? SessionService.instance;

  static const String baseUrl = 'https://seen-newspaper.vercel.app';
  final http.Client _client;
  final SessionService _session;

  Future<Map<String, dynamic>> get(String path, {bool authenticated = false}) =>
      _send('GET', path, authenticated: authenticated);
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) => _send('POST', path, body: body, authenticated: authenticated);
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) => _send('PUT', path, body: body, authenticated: authenticated);
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) => _send('DELETE', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated) {
      final token = await _session.idToken();
      if (token == null || token.isEmpty) {
        throw ApiException('يرجى تسجيل الدخول أولاً', statusCode: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }
    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 25));
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 25));
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 25));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 25));
          break;
        default:
          throw ApiException('طريقة طلب غير مدعومة');
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مجدداً.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decoded = <String, dynamic>{};
    }
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          (data['error'] ?? data['message'] ?? 'حدث خطأ أثناء تنفيذ الطلب')
              .toString();
      throw ApiException(message, statusCode: response.statusCode);
    }
    return data;
  }
}
