import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/claim_shift_usecase.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/get_availableshift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final GetAvailableShiftsUseCase getShiftsUseCase;
  final ClaimShiftUseCase claimShiftUseCase;

  ShiftBloc(this.getShiftsUseCase, this.claimShiftUseCase)
    : super(ShiftInitial()) {
    on<FetchShifts>((event, emit) async {
      emit(ShiftLoading());
      try {
        final shifts = await getShiftsUseCase();
        if (shifts.isEmpty) {
          emit(ShiftLoaded([])); // ✅ Emit empty list state
        } else {
          emit(ShiftLoaded(shifts));
        }
      } catch (e) {
        print('Error fetching shifts: $e');
        emit(ShiftError(e.toString()));
      }
    });

    on<ClaimShift>((event, emit) async {
      try {
        await claimShiftUseCase(event.shiftId);
        emit(ShiftClaimSuccess());

        // Re-fetch after claiming
        final shifts = await getShiftsUseCase();
        emit(ShiftLoaded(shifts));
      } catch (e) {
        print('Error claiming shift: $e');
        emit(ShiftError(e.toString()));
      }
    });
  }
}
