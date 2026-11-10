import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central HTTP client for the KidDO Node.js REST API.
///
/// Base URL: http://localhost:3000 (dev)
/// All protected endpoints automatically attach the stored JWT token.
class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'kiddo_jwt_token';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final Dio _dio;

  // ── Singleton ────────────────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Request Interceptor: attach JWT ────────────────────────────────────
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          // Surface a clean error message
          final message = _extractError(e);
          handler.next(
            DioException(
              requestOptions: e.requestOptions,
              error: message,
              type: e.type,
              response: e.response,
            ),
          );
        },
      ),
    );
  }

  // ── Token helpers ────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ── HTTP wrappers ─────────────────────────────────────────────────────────────
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  // ── Error extraction ──────────────────────────────────────────────────────────
  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message'] ?? e.message ?? 'Unknown error';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Is the server running?';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Make sure the backend is running on localhost:3000';
    }
    return e.message ?? 'Network error';
  }
}
