import 'dart:convert';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<UserModel> login(String email, String password) async {
    try {
      print('=== LOGIN DEBUG ===');
      print('URL: $baseUrl/login');
      print('Email: $email');

      // Create a client that doesn't follow redirects automatically
      final client = http.Client();

      final request = http.Request('POST', Uri.parse('$baseUrl/login'));

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      request.body = jsonEncode({"email": email, "password": password});

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('===================');

      // Handle redirect manually
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        print('Redirect detected to: $redirectUrl');
        throw Exception(
          'API endpoint redirected. Please check the correct URL.',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'].toString().contains('Successfully')) {
          return UserModel.fromJson(data);
        } else {
          throw Exception(data['message']);
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
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
