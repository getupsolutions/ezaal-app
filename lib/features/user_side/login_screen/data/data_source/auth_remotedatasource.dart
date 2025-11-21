import 'dart:convert';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  // Auto-detect login: Try admin first, then user
  Future<UserModel> autoLogin(String identifier, String password) async {
    try {
      // Try admin login first
      return await login(identifier, password, isAdmin: true);
    } catch (adminError) {
      print('Admin login failed, trying user login...');
      // If admin login fails, try user login
      try {
        return await login(identifier, password, isAdmin: false);
      } catch (userError) {
        // Both failed, throw the most relevant error
        throw Exception(
          'Invalid credentials. Please check your email/username and password.',
        );
      }
    }
  }

  Future<UserModel> login(
    String identifier,
    String password, {
    bool isAdmin = false,
  }) async {
    try {
      print('=== LOGIN DEBUG ===');
      final endpoint = isAdmin ? '$baseUrl/admin-login' : '$baseUrl/login';
      print('URL: $endpoint');
      print('Identifier: $identifier');
      print('Is Admin: $isAdmin');

      final client = http.Client();
      final request = http.Request('POST', Uri.parse(endpoint));

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      // Admin uses username, User uses email
      final requestBody =
          isAdmin
              ? {"username": identifier, "password": password}
              : {"email": identifier, "password": password};

      request.body = jsonEncode(requestBody);

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===================');

      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        print('Redirect detected to: $redirectUrl');
        throw Exception(
          'API endpoint redirected. Please check the correct URL.',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for successful login message
        final message = data['message']?.toString().toLowerCase() ?? '';
        if (message.contains('successfully') || message.contains('logged in')) {
          // Ensure the role is set correctly based on response
          if (data['data'] != null) {
            // Use the role from API response, or determine from user_type
            final userType = data['user_type']?.toString().toLowerCase();
            final apiRole = data['data']['role']?.toString().toLowerCase();

            // Set role based on API response or user_type
            if (userType == 'admin' || apiRole?.contains('admin') == true) {
              data['data']['role'] = 'admin';
            } else {
              data['data']['role'] = data['data']['role'] ?? 'user';
            }
          }
          return UserModel.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 401) {
        throw Exception(
          isAdmin
              ? 'Invalid username or password'
              : 'Invalid email or password',
        );
      } else {
        throw Exception('Failed to login. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<UserModel> getUserFromToken(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/staff-profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] != null) {
        final transformedData = {
          'data': data['data'],
          'access_token': accessToken,
          'refresh_token': '',
        };
        return UserModel.fromJson(transformedData);
      } else {
        throw Exception('Invalid user data received');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Token expired or invalid');
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }
}
