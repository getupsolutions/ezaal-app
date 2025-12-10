import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class UpdateShiftStatusUseCase {
  final AdminShiftRepository repository;

  UpdateShiftStatusUseCase(this.repository);

  Future<void> call({required int shiftId, required bool approve}) {
    return repository.updateShiftStatus(shiftId: shiftId, approve: approve);
  }
}
