import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezaal/core/token_manager.dart';

class TokenRefreshService {
  static const String baseUrl =
      'https://app.ezaalhealthcare.com.au/api/v1/public';

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null) {
        print('❌ No refresh token available');
        return false;
      }

      print('🔄 Attempting to refresh token...');

      // ✅ FIXED: Use correct endpoint 'refresh' not 'refresh-token'
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'), // Changed from /refresh-token
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken, // Match your PHP backend
        }),
      );

      print('Token refresh response status: ${response.statusCode}');
      print('Token refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Match your backend response structure
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        await TokenStorage.saveTokens(newAccessToken, newRefreshToken);

        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  static Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String token) request,
  ) async {
    String? accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null) {
      throw Exception('Session expired. Please login again.');
    }

    // First attempt with current token
    var response = await request(accessToken);

    // If token expired (401), refresh and retry
    if (response.statusCode == 401) {
      print('⚠️ Token expired, attempting refresh...');

      final refreshed = await refreshToken();

      if (refreshed) {
        accessToken = await TokenStorage.getAccessToken();
        if (accessToken != null) {
          print('🔄 Retrying request with new token...');
          response = await request(accessToken);
        }
      } else {
        // Refresh failed - user needs to login again
        await TokenStorage.clearTokens();
        throw Exception('Session expired. Please login again.');
      }
    }

    return response;
  }
}
