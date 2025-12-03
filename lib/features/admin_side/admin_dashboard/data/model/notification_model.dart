import 'package:ezaal/features/admin_side/admin_dashboard/domain/entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.notification,
    required super.type,
    required super.isRead,
    required super.link,
    required super.addedOn,
    super.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,
      notification: json['notification'] ?? '',
      type: json['type'] ?? '',
      isRead: json['rd'] == 1 || json['rd'] == '1',
      link: json['link'] ?? '',
      addedOn: DateTime.parse(
        json['addedon'] ?? DateTime.now().toIso8601String(),
      ),
      userId:
          json['userId'] != null
              ? (json['userId'] is int
                  ? json['userId']
                  : int.tryParse(json['userId'].toString()))
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification': notification,
      'type': type,
      'rd': isRead ? 1 : 0,
      'link': link,
      'addedon': addedOn.toIso8601String(),
      'userId': userId,
    };
  }
}
