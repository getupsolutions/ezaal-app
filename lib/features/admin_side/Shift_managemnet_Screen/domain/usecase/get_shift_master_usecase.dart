import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class GetShiftMastersUseCase {
  final AdminShiftRepository repository;

  GetShiftMastersUseCase(this.repository);

  Future<ShiftMastersDto> call() {
    return repository.getShiftMasters();
  }
}
