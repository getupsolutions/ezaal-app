import 'package:ezaal/features/admin_side/admin_dashboard/data/remote_datasource/notification_remote_datasource..dart';
import 'package:ezaal/features/admin_side/admin_dashboard/domain/entity/notification_entity.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<int> getUnreadCount() async {
    return await remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    return await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    return await remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    return await remoteDataSource.deleteNotification(notificationId);
  }
}
