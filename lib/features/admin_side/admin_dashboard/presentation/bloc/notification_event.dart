abstract class NotificationEvent {}

class FetchNotifications extends NotificationEvent {}

class FetchUnreadCount extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  DeleteNotification(this.notificationId);
}

class RefreshNotifications extends NotificationEvent {}
