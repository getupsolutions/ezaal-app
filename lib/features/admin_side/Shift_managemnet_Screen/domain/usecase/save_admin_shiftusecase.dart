// domain/usecase/save_admin_shift_usecase.dart
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/savde_admin_shiftmodel.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class SaveAdminShiftUseCase {
  final AdminShiftRepository repository;
  SaveAdminShiftUseCase(this.repository);

  Future<void> call(SaveAdminShiftParams params) {
    return repository.saveShift(params);
  }
}
