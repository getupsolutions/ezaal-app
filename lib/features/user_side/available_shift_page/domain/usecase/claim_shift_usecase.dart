import '../repository/shift_repository.dart';

class ClaimShiftUseCase {
  final ShiftRepository repository;

  ClaimShiftUseCase(this.repository);

  Future<void> call(int shiftId) async {
    await repository.claimShift(shiftId);
  }
}
