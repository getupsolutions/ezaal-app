import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class GetAdminShiftsForWeek {
  final AdminShiftRepository repository;

  GetAdminShiftsForWeek(this.repository);

  Future<List<ShiftItem>> call(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
    int? staffId,
    String? status,
    int? staffTypeId,
    int? departmentId,
  }) {
    // staffTypeId & departmentId can be used when repository/API support them
    return repository.getAdminShiftsForWeek(
      weekStart,
      weekEnd,
      organizationId: organizationId,
      staffId: staffId,
      status: status,
    );
  }
}
