import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';

abstract class SlotState {}

class SlotInitial extends SlotState {}

class SlotLoading extends SlotState {}

class SlotLoaded extends SlotState {
  final List<SlotEntity> slots;
  SlotLoaded(this.slots);
}

class SlotError extends SlotState {
  final String message;
  SlotError(this.message);
}
