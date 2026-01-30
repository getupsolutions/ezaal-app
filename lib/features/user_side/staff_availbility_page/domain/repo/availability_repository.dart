import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

abstract class AvailabilityRepository {
  Future<List<AvailabilityEntity>> getAvailability(
    String startDate,
    String endDate,
  );

  Future<void> saveAvailability(AvailabilityEntity entity);

  Future<void> deleteAvailability(DateTime date, String shift);

  Future<void> editAvailability(AvailabilityEntity entity);
}
