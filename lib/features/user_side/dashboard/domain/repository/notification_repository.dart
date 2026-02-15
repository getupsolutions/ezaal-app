import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';

abstract class StaffNotificationRepository {
  Future<int> getStaffUnreadCount({String type});
  Future<List<StaffNotificationEntity>> getStaffNotifications({
    String type,
    int limit,
    int offset,
  });
}
