import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';

class StaffNotificationModel extends StaffNotificationEntity {
  const StaffNotificationModel({
    required super.id,
    required super.userId,
    required super.notification,
    required super.type,
    required super.rd,
    required super.link,
    required super.addedOn,
  });

  factory StaffNotificationModel.fromJson(Map<String, dynamic> j) {
    return StaffNotificationModel(
      id: int.tryParse(j['id'].toString()) ?? 0,
      userId: int.tryParse(j['userId'].toString()) ?? 0,
      notification: (j['notification'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      rd: int.tryParse(j['rd'].toString()) ?? 0,
      link:
          (j['link'] == null || j['link'].toString().trim().isEmpty)
              ? null
              : j['link'].toString(),
      addedOn:
          DateTime.tryParse((j['addedon'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
