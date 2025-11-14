import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';

abstract class SlotRepository {
  Future<List<SlotEntity>> getSlots();
}
