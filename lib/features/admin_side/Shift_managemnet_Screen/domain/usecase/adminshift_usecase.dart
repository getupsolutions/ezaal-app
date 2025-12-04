import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository_impl/adminshift_repository.dart';


class GetAdminShiftsForWeek {
  final AdminShiftRepository repository;

  GetAdminShiftsForWeek(this.repository);

  Future<List<ShiftItem>> call(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
  }) {
    return repository.getShiftsForWeek(
      weekStart,
      weekEnd,
      organizationId: organizationId,
    );
  }
}
