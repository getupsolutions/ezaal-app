import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/enitity/approve_pendingclaim.dart';

abstract class AdminShiftRepository {
  Future<List<ShiftItem>> getShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
  });
  Future<void> approvePendingShiftClaims({
    DateTime? startDate,
    DateTime? endDate,
    int? organizationId,
    int? staffId,
  });
}
