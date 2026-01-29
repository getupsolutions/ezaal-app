import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';

abstract class AvailabilityAdminRepo {
  Future<List<AdminAvailablitEntity>> getAvailabilityRange({
    required String startDate,
    required String endDate,
    int? organiz,
    int? staffId, // nullable -> all staff
  });
}
