

import 'package:ezaal/features/admin_side/admin_dashboard/domain/entity/notification_entity.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/domain/repository/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> call() async {
    return await repository.getNotifications();
  }
}

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<int> call() async {
    return await repository.getUnreadCount();
  }
}

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<void> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}

class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<void> call() async {
    return await repository.markAllAsRead();
  }
}

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<void> call(int notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}
