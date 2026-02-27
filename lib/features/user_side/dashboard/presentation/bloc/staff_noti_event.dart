abstract class StaffNotificationEvent {}

class FetchStaffUnreadCount extends StaffNotificationEvent {
  final String type;
  FetchStaffUnreadCount({this.type = 'organiz-add-reqst'});
}

class FetchStaffNotifications extends StaffNotificationEvent {
  final String type;
  final int limit;
  final int offset;

  FetchStaffNotifications({
    this.type = 'organiz-add-reqst',
    this.limit = 30,
    this.offset = 0,
  });
}

abstract class UserNotificationEvent {}

class FetchUserUnreadCount extends UserNotificationEvent {}

class FetchUserNotifications extends UserNotificationEvent {
  final int limit;
  final int offset;
  FetchUserNotifications({this.limit = 30, this.offset = 0});
}

/// Fired by FCMService when a foreground push arrives for the user side.
/// Instantly prepends the item to the list without a network round-trip.
class PushUserNotification extends UserNotificationEvent {
  final String title;
  final String body;
  final String type;

  PushUserNotification({
    required this.title,
    required this.body,
    required this.type,
  });
}
