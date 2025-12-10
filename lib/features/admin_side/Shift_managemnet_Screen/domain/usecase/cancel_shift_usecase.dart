import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class CancelAdminShiftUseCase {
  final AdminShiftRepository repository;
  CancelAdminShiftUseCase(this.repository);

  Future<void> call(int shiftId) => repository.cancelShift(shiftId);
}

class CancelAdminShiftStaffUseCase {
  final AdminShiftRepository repository;
  CancelAdminShiftStaffUseCase(this.repository);

  Future<void> call(int shiftId) => repository.cancelShiftStaff(shiftId);
}
