import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/data/datasource/admin_avail_remote.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/repo/available_admin_repo.dart';

class AvailabilityAdminRepoImpl implements AvailabilityAdminRepo {
  final AvailabilityAdminRemoteDS remote;

  AvailabilityAdminRepoImpl(this.remote);

  @override
  Future<List<AdminAvailablitEntity>> getAvailabilityRange({
    required String startDate,
    required String endDate,
    int? organiz,
    int? staffId,
  }) {
    return remote.getAvailabilityRange(
      startDate: startDate,
      endDate: endDate,
      organiz: organiz,
      staffId: staffId,
    );
  }
}
