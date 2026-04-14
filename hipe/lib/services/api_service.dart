import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String baseUrl = 'https://api.example.com/v1';
  static const Duration timeout = Duration(seconds: 30);

  String? _authToken;

  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: params);
    try {
      final response =
          await http.get(uri, headers: _headers).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Network error');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response =
          await http.delete(uri, headers: _headers).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', statusCode: 401);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found', statusCode: 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error', statusCode: response.statusCode);
    } else {
      final message = body['message'] ?? 'Unknown error';
      throw ApiException(message.toString(),
          statusCode: response.statusCode);
    }
  }
}
