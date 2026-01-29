import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/savde_admin_shiftmodel.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/save_shift_respo.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';

abstract class AdminShiftRepository {
  Future<List<ShiftItem>> getAdminShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
    int? staffId,
    String? status,
  });
  Future<void> approvePendingShiftClaims({
    DateTime? startDate,
    DateTime? endDate,
    int? organizationId,
    int? staffId,
  });
  Future<SaveShiftResponse> saveShift(SaveAdminShiftParams params);
  Future<ShiftMastersDto> getShiftMasters();

  Future<void> cancelShift(int shiftId);
  Future<void> cancelShiftStaff(int shiftId);
  Future<void> updateShiftAttendance(UpdateShiftAttendanceParams params);
  Future<void> updateShiftStatus({required int shiftId, required bool approve});
  Future<void> sendOrganizationRosterMail({
    required DateTime startDate,
    required DateTime endDate,
    required int organizationId,
    required bool includeCancelled,
  });

  Future<Map<String, dynamic>> sendStaffConfirmedMail({
    required List<int> shiftIds,
  });

    Future<Map<String, dynamic>> sendStaffAvailableShiftMail({
    required List<int> shiftIds,
  });
}
