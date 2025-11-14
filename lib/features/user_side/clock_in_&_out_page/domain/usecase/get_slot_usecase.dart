import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/slot_repository.dart';

class GetSlotUseCase {
  final SlotRepository repository;

  GetSlotUseCase(this.repository);

  Future<List<SlotEntity>> call() {
    return repository.getSlots();
  }
}
