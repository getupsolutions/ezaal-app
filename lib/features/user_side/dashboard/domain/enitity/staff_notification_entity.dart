class StaffNotificationEntity {
  final int id;
  final int userId;
  final String notification;
  final String type;
  final int rd; // 0 unread, 1 read
  final String? link;
  final DateTime addedOn;

  const StaffNotificationEntity({
    required this.id,
    required this.userId,
    required this.notification,
    required this.type,
    required this.rd,
    required this.link,
    required this.addedOn,
  });

  bool get isUnread => rd == 0;
}
