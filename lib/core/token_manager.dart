import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Save tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Save user data - now accepts UserEntity
  static Future<void> saveUserData(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'data': {
        'id': user.id.toString(),
        'name': user.name,
        'email': user.email,
        'staffId': user.staffId,
        'photo': user.photoUrl,
      },
      'access_token': user.accessToken,
      'refresh_token': user.refreshToken,
    });
    await prefs.setString(_userDataKey, userJson);
  }

  // Get user data - returns UserEntity
  static Future<UserEntity?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);

    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        final data = userData['data'] ?? {};

        return UserEntity(
          id: int.parse(data['id'].toString()),
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          accessToken: userData['access_token'] ?? '',
          refreshToken: userData['refresh_token'] ?? '',
          staffId: data['staffId'],
          photoUrl: data['photo'],
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Clear all tokens and user data
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }
}
