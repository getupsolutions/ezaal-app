import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:flutter/material.dart';
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
      // Get slots from server
      var slots = await getSlotUseCase();

      debugPrint('=== APPLYING LOCAL STATE TO SLOTS ===');
      // ✅ Apply local state to each slot
      final slotsWithLocalState = await Future.wait(
        slots.map((slot) async {
          final localState = await OfflineQueueService.getLocalState(slot.id);
          if (localState != null) {
            debugPrint(
              'Slot ${slot.id}: Local Clock-In: ${localState.hasLocalClockIn}, '
              'Local Clock-Out: ${localState.hasLocalClockOut}, '
              'Local Manager: ${localState.hasLocalManagerInfo}',
            );
          }
          return slot.applyLocalState(localState);
        }),
      );
      debugPrint('====================================');

      emit(SlotLoaded(slotsWithLocalState));
    } catch (e) {
      emit(SlotError(e.toString()));
    }
  }
}
