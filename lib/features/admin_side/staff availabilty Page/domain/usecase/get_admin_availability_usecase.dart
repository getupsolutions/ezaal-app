import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/repo/available_admin_repo.dart';



class GetAdminAvailabilityRange {
  final AvailabilityAdminRepo repo;
  GetAdminAvailabilityRange(this.repo);

  Future<List<AdminAvailablitEntity>> call({
    required String startDate,
    required String endDate,
    int? organiz,
    int? staffId,
  }) {
    return repo.getAvailabilityRange(
      startDate: startDate,
      endDate: endDate,
      organiz: organiz,
      staffId: staffId,
    );
  }
}
