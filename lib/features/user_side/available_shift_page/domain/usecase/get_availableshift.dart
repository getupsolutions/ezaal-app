import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';
import '../repository/shift_repository.dart';

class GetAvailableShiftsUseCase {
  final ShiftRepository repository;

  GetAvailableShiftsUseCase(this.repository);

  Future<List<ShiftEntity>> call() async {
    return await repository.getAvailableShifts();
  }
}
