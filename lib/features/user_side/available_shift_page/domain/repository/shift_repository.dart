import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';


abstract class ShiftRepository {
  Future<List<ShiftEntity>> getAvailableShifts();
  Future<void> claimShift(int shiftId);
}
