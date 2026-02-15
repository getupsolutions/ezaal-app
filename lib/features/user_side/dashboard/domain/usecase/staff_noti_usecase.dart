import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';
import 'package:ezaal/features/user_side/dashboard/domain/repository/notification_repository.dart';

class GetStaffUnreadCountUC {
  final StaffNotificationRepository repo;
  GetStaffUnreadCountUC(this.repo);

  Future<int> call({String type = 'organiz-add-reqst'}) {
    return repo.getStaffUnreadCount(type: type);
  }
}

class GetStaffNotificationsUC {
  final StaffNotificationRepository repo;
  GetStaffNotificationsUC(this.repo);

  Future<List<StaffNotificationEntity>> call({
    String type = 'organiz-add-reqst',
    int limit = 30,
    int offset = 0,
  }) {
    return repo.getStaffNotifications(type: type, limit: limit, offset: offset);
  }
}
