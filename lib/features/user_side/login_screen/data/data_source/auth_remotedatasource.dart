import 'dart:convert';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<UserModel> autoLogin(String identifier, String password) async {
    try {
      return await login(identifier, password, isAdmin: true);
    } catch (_) {
      try {
        return await login(identifier, password, isAdmin: false);
      } catch (_) {
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
      debugPrint('=== LOGIN DEBUG ===');
      final endpoint = isAdmin ? '$baseUrl/admin-login' : '$baseUrl/login';
      debugPrint('URL: $endpoint');
      debugPrint('Identifier: $identifier');
      debugPrint('Is Admin: $isAdmin');

      final client = http.Client();
      final request = http.Request('POST', Uri.parse(endpoint));

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      final requestBody =
          isAdmin
              ? {'username': identifier, 'password': password}
              : {'email': identifier, 'password': password};

      request.body = jsonEncode(requestBody);

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('===================');

      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        debugPrint('Redirect detected to: $redirectUrl');
        throw Exception(
          'API endpoint redirected. Please check the correct URL.',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final message = data['message']?.toString().toLowerCase() ?? '';
        if (message.contains('successfully') || message.contains('logged in')) {
          if (data['data'] != null) {
            final userType = data['user_type']?.toString().toLowerCase();
            final apiRole = data['data']['role']?.toString().toLowerCase();

            final isActuallyAdmin =
                isAdmin ||
                userType == 'admin' ||
                (apiRole?.contains('admin') ?? false);

            data['data']['role'] = isActuallyAdmin ? 'admin' : 'user';
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
      debugPrint('Login Error: $e');
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

        if ((data['data']['role']?.toString().toLowerCase().contains('admin') ??
            false)) {
          transformedData['data']['role'] = 'admin';
        }

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
