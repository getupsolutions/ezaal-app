import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBadgeService {
  static const _kUnreadCount = 'unread_count';

  static Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUnreadCount) ?? 0;
  }

  static Future<void> setUnreadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUnreadCount, count);

    final supported = await AppBadgePlus.isSupported();
    if (!supported) return;

    // ✅ Clear badge by setting to 0
    await AppBadgePlus.updateBadge(count);
  }

  static Future<void> clearBadge() async {
    await setUnreadCount(0);
  }
}
