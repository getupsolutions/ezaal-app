import 'package:ezaal/features/admin_side/admin_dashboard/domain/entity/notification_entity.dart';


abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  NotificationLoaded({required this.notifications, required this.unreadCount});
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationMarkedAsRead extends NotificationState {
  final int notificationId;

  NotificationMarkedAsRead(this.notificationId);
}

class AllNotificationsMarkedAsRead extends NotificationState {}

class NotificationDeleted extends NotificationState {
  final int notificationId;

  NotificationDeleted(this.notificationId);
}

class NotificationSessionExpired extends NotificationState {}
