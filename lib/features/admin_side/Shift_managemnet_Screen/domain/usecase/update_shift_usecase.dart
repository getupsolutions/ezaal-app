import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class UpdateShiftAttendanceUseCase {
  final AdminShiftRepository repository;

  UpdateShiftAttendanceUseCase(this.repository);

  Future<void> call(UpdateShiftAttendanceParams params) {
    return repository.updateShiftAttendance(params);
  }
}
