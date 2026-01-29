import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/savde_admin_shiftmodel.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/save_shift_respo.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/RemoteDataSource/admin_shift_datasource.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class AdminShiftRepositoryImpl implements AdminShiftRepository {
  final AdminShiftRemoteDataSource remote;

  AdminShiftRepositoryImpl(this.remote);
  @override
  @override
  Future<List<ShiftItem>> getAdminShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
    int? staffId,
    String? status,
  }) {
    return remote.getShiftsForWeek(
      weekStart,
      weekEnd,
      organizationId: organizationId,
      staffId: staffId,
      status: status,
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

  @override
  Future<SaveShiftResponse> saveShift(SaveAdminShiftParams params) {
    return remote.saveShift(params);
  }

  @override
  Future<ShiftMastersDto> getShiftMasters() {
    return remote.getShiftMasters();
  }

  @override
  Future<void> cancelShift(int shiftId) {
    return remote.cancelShift(shiftId);
  }

  @override
  Future<void> cancelShiftStaff(int shiftId) {
    return remote.cancelShiftStaff(shiftId);
  }

  @override
  Future<void> updateShiftAttendance(UpdateShiftAttendanceParams params) {
    return remote.updateShiftAttendance(params);
  }

  @override
  Future<void> updateShiftStatus({
    required int shiftId,
    required bool approve,
  }) {
    return remote.updateShiftStatus(shiftId: shiftId, approve: approve);
  }

  @override
  Future<void> sendOrganizationRosterMail({
    required DateTime startDate,
    required DateTime endDate,
    required int organizationId,
    required bool includeCancelled,
  }) {
    return remote.sendOrganizationRosterMail(
      startDate: startDate,
      endDate: endDate,
      organizationId: organizationId,
      includeCancelled: includeCancelled,
    );
  }

  @override
  Future<Map<String, dynamic>> sendStaffConfirmedMail({
    required List<int> shiftIds,
  }) {
    return remote.sendStaffConfirmedMail(shiftIds: shiftIds);
  }

  @override
  Future<Map<String, dynamic>> sendStaffAvailableShiftMail({
    required List<int> shiftIds,
  }) {
    return remote.sendStaffAvailableShiftMail(shiftIds: shiftIds);
  }
}
