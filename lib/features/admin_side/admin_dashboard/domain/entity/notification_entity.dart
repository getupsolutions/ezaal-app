class NotificationEntity {
  final int id;
  final String notification;
  final String type;
  final bool isRead;
  final String link;
  final DateTime addedOn;
  final int? userId;

  NotificationEntity({
    required this.id,
    required this.notification,
    required this.type,
    required this.isRead,
    required this.link,
    required this.addedOn,
    this.userId,
  });

  // Helper to check if notification is for shift approval
  bool get isShiftApproval => type == 'shift-approved';

  // Helper to check if notification is for shift rejection
  bool get isShiftRejection => type == 'shift-rejected';

  // Helper to check if notification is for new shift
  bool get isNewShift => type == 'new-shift';

  // Helper to check if notification is unread
  bool get isUnread => !isRead;
}
