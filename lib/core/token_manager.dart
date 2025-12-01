import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Save tokens and update user data
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Save individual tokens
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    // ✅ FIX: Also update tokens in user data
    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        userData['access_token'] = accessToken;
        userData['refresh_token'] = refreshToken;
        await prefs.setString(_userDataKey, jsonEncode(userData));
      } catch (e) {
        print('Error updating user data tokens: $e');
      }
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> saveUserData(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'data': {
        'id': user.id.toString(),
        'name': user.name,
        'email': user.email,
        'staffId': user.staffId,
        'photo': user.photoUrl,
        'role': user.role,
      },
      'access_token': user.accessToken,
      'refresh_token': user.refreshToken,
    });

    // Save complete user data
    await prefs.setString(_userDataKey, userJson);

    // ✅ Also save individual tokens for quick access
    await prefs.setString(_accessTokenKey, user.accessToken);
    await prefs.setString(_refreshTokenKey, user.refreshToken);
  }

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
          role: data['role'] ?? 'user',
        );
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }
}
