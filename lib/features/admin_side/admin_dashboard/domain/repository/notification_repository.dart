import 'package:ezaal/features/admin_side/admin_dashboard/domain/entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
}
