import 'package:ezaal/features/user_side/staff_availbility_page/domain/usecase/availbility_usecase.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_event.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailabilityUseCase getUseCase;
  final SaveAvailabilityUseCase saveUseCase;
  final DeleteAvailabilityUseCase deleteUseCase;
  final EditAvailabilityUseCase editUsecase;

  AvailabilityBloc({
    required this.getUseCase,
    required this.saveUseCase,
    required this.deleteUseCase,
    required this.editUsecase,
  }) : super(AvailabilityState.initial()) {
    on<LoadAvailabilityRange>(_onLoad);
    on<EditAvailabilityForDate>(_onEdit);
    on<SaveAvailabilityForDate>(_onSave);
    on<DeleteAvailabilityForDate>(_onDelete);
  }

  Future<void> _onLoad(
    LoadAvailabilityRange e,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final list = await getUseCase(e.startDate, e.endDate, organiz: e.organiz);
      emit(state.copyWith(loading: false, items: list));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onSave(
    SaveAvailabilityForDate e,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      await saveUseCase(e.entity);
      emit(state.copyWith(loading: false, success: "Availability saved"));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onEdit(
    EditAvailabilityForDate e,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      await editUsecase(e.entity);
      emit(state.copyWith(loading: false, success: "Availability updated"));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteAvailabilityForDate e,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      await deleteUseCase(e.date, organiz: e.organiz);
      emit(state.copyWith(loading: false, success: "Availability removed"));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
