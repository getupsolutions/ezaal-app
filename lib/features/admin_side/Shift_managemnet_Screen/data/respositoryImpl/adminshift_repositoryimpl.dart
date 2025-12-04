import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/RemoteDataSource/admin_shift_datasource.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository_impl/adminshift_repository.dart';

class AdminShiftRepositoryImpl implements AdminShiftRepository {
  final AdminShiftRemoteDataSource remote;

  AdminShiftRepositoryImpl(this.remote);
  @override
  Future<List<ShiftItem>> getShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
  }) {
    return remote.getShiftsForWeek(
      weekStart,
      weekEnd,
      organizationId: organizationId,
    );
  }

  @override
  Future<void> approvePendingShiftClaims({
    DateTime? startDate,
    DateTime? endDate,
    int? organizationId,
    int? staffId,
  }) {
    return remote.approvePendingShiftClaims(
      startDate: startDate,
      endDate: endDate,
      organizationId: organizationId,
      staffId: staffId,
    );
  }
}
