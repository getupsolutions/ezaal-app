import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

abstract class AvailabilityRepository {
  Future<List<AvailabilityEntity>> getAvailability(
    String start,
    String end, {
    int? organiz,
  });
  Future<void> saveAvailability(AvailabilityEntity entity);
  Future<void> deleteAvailability(DateTime date, {int? organiz});
  Future<void> editAvailability(AvailabilityEntity entity);
}

abstract class NotificationRepo {
  Future<int> getUnreadCount();
}

