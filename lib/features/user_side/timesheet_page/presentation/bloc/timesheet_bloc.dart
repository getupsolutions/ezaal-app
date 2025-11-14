import 'package:ezaal/features/user_side/timesheet_page/domain/usecase/timesheet_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';

class TimesheetBloc extends Bloc<TimesheetEvent, TimesheetState> {
  final GetTimesheetUseCase getTimesheetUseCase;

  TimesheetBloc({required this.getTimesheetUseCase})
    : super(TimesheetInitial()) {
    on<LoadTimesheet>(_onLoadTimesheet);
    on<FilterTimesheetByDate>(_onFilterTimesheetByDate);
    on<ClearTimesheetFilter>(_onClearTimesheetFilter);
  }

  Future<void> _onLoadTimesheet(
    LoadTimesheet event,
    Emitter<TimesheetState> emit,
  ) async {
    debugPrint('=== BLOC: Load Timesheet ===');
    debugPrint('Start: ${event.startDate}, End: ${event.endDate}');
    debugPrint('Organization: ${event.organizationId}');

    emit(TimesheetLoading());

    try {
      final timesheets = await getTimesheetUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        organizationId: event.organizationId,
      );

      debugPrint('✅ BLoC: Loaded ${timesheets.length} timesheets');

      emit(
        TimesheetLoaded(
          timesheets,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      debugPrint('❌ BLoC Error: $e');
      emit(TimesheetError(e.toString()));
    }
  }

  Future<void> _onFilterTimesheetByDate(
    FilterTimesheetByDate event,
    Emitter<TimesheetState> emit,
  ) async {
    debugPrint('=== BLOC: Filter Timesheet By Date ===');
    debugPrint('📅 Start Date: ${event.startDate}');
    debugPrint('📅 End Date: ${event.endDate}');

    // Validate dates are not empty
    if (event.startDate.isEmpty || event.endDate.isEmpty) {
      debugPrint('❌ Empty date parameters!');
      emit(TimesheetError('Invalid date range'));
      return;
    }

    emit(TimesheetLoading());

    try {
      final timesheets = await getTimesheetUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      debugPrint('✅ BLoC: Filtered result - ${timesheets.length} timesheets');

      if (timesheets.isEmpty) {
        debugPrint('⚠️ No timesheets found for date range');
      }

      emit(
        TimesheetLoaded(
          timesheets,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e) {
      debugPrint('❌ BLoC Filter Error: $e');
      emit(TimesheetError('Failed to filter timesheets: ${e.toString()}'));
    }
  }

  Future<void> _onClearTimesheetFilter(
    ClearTimesheetFilter event,
    Emitter<TimesheetState> emit,
  ) async {
    debugPrint('=== BLOC: Clear Filter - Loading All Timesheets ===');
    emit(TimesheetLoading());

    try {
      // Call without any date parameters to get all timesheets
      final timesheets = await getTimesheetUseCase(
        startDate: null,
        endDate: null,
      );

      debugPrint('✅ BLoC: Cleared filter - ${timesheets.length} timesheets');

      // Don't pass startDate/endDate to indicate no filter is active
      emit(TimesheetLoaded(timesheets));
    } catch (e) {
      debugPrint('❌ BLoC Clear Filter Error: $e');
      emit(TimesheetError(e.toString()));
    }
  }
}
