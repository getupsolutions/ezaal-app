import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/get_slot_usecase.dart';
import 'slot_event.dart';
import 'slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  final GetSlotUseCase getSlotUseCase;

  SlotBloc(this.getSlotUseCase) : super(SlotInitial()) {
    on<LoadSlots>(_onLoadSlots);
  }

  Future<void> _onLoadSlots(LoadSlots event, Emitter<SlotState> emit) async {
    emit(SlotLoading());
    try {
      final slots = await getSlotUseCase();
      emit(SlotLoaded(slots));
    } catch (e) {
      emit(SlotError(e.toString()));
    }
  }
}
