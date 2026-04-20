abstract class StaffNotificationEvent {}

class FetchStaffUnreadCount extends StaffNotificationEvent {
  final String type;
  FetchStaffUnreadCount({
    this.type =
        'organiz-add-reqst,new-shift,shift-approved,shift-rejected,shift-claim-pending,staff-acpt-req',
  });
}

class FetchStaffNotifications extends StaffNotificationEvent {
  final String type;
  final int limit;
  final int offset;

  FetchStaffNotifications({
    this.type =
        'organiz-add-reqst,new-shift,shift-approved,shift-rejected,shift-claim-pending,staff-acpt-req',
    this.limit = 30,
    this.offset = 0,
  });
}

class DeleteStaffNotification extends StaffNotificationEvent {
  final int notificationId;

  DeleteStaffNotification({required this.notificationId});
}
