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
