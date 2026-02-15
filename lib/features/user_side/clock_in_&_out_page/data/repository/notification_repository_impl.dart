import 'package:ezaal/features/user_side/dashboard/data/remote_datasource/notification_remote_ds.dart';
import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';
import 'package:ezaal/features/user_side/dashboard/domain/repository/notification_repository.dart';

class StaffNotificationRepositoryImpl implements StaffNotificationRepository {
  final StaffNotificationRemoteDatasource remote;
  StaffNotificationRepositoryImpl(this.remote);

  @override
  Future<int> getStaffUnreadCount({String type = 'organiz-add-reqst'}) {
    return remote.fetchStaffUnreadCount(type: type);
  }

  @override
  Future<List<StaffNotificationEntity>> getStaffNotifications({
    String type = 'organiz-add-reqst',
    int limit = 30,
    int offset = 0,
  }) {
    return remote.fetchStaffNotifications(
      type: type,
      limit: limit,
      offset: offset,
    );
  }
}
