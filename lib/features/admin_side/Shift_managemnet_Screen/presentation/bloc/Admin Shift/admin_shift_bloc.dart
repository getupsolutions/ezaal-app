import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/adminshift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/approve_pendingshiftclaim.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_shift_state.dart';

class AdminShiftBloc extends Bloc<AdminShiftEvent, AdminShiftState> {
  final GetAdminShiftsForWeek getAdminShiftsForWeek;
  final ApprovePendingShiftClaimsUseCase approvePendingShiftClaims;

  DateTime? _currentWeekStart;
  DateTime? _currentWeekEnd;
  int? _currentOrgId;

  AdminShiftBloc({
    required this.getAdminShiftsForWeek,
    required this.approvePendingShiftClaims,
  }) : super(AdminShiftInitial()) {
    on<LoadAdminShiftsForWeek>(_onLoadWeek);
    on<RefreshAdminShifts>(_onRefresh);
    on<ApprovePendingShiftClaimsEvent>(_onApprovePendingShiftClaims);
  }

  Future<void> _onLoadWeek(
    LoadAdminShiftsForWeek event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(AdminShiftLoading());

    _currentWeekStart = event.weekStart;
    _currentWeekEnd = event.weekEnd;
    _currentOrgId = event.organizationId;

    try {
      final shifts = await getAdminShiftsForWeek(
        event.weekStart,
        event.weekEnd,
        organizationId: event.organizationId,
      );

      emit(
        AdminShiftLoaded(
          shifts: shifts,
          weekStart: event.weekStart,
          weekEnd: event.weekEnd,
        ),
      );
    } catch (e) {
      emit(AdminShiftError(e.toString()));
    }
  }

  Future<void> _onApprovePendingShiftClaims(
    ApprovePendingShiftClaimsEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    // Get current list for optimistic UI
    List<ShiftItem> currentShifts = [];
    DateTime weekStart = _currentWeekStart ?? DateTime.now();
    DateTime weekEnd =
        _currentWeekEnd ?? weekStart.add(const Duration(days: 6));

    final currentState = state;
    if (currentState is AdminShiftLoaded) {
      currentShifts = currentState.shifts;
      weekStart = currentState.weekStart;
      weekEnd = currentState.weekEnd;
    }

    try {
      // Show "approving" but keep shifts visible
      emit(
        AdminShiftApproving(
          shifts: currentShifts,
          weekStart: weekStart,
          weekEnd: weekEnd,
        ),
      );

      // Call use case
      await approvePendingShiftClaims(
        startDate: event.startDate,
        endDate: event.endDate,
        organizationId: event.organizationId,
        staffId: event.staffId,
      );

      // Reload the same week window so data is refreshed
      final refreshedShifts = await getAdminShiftsForWeek(
        weekStart,
        weekEnd,
        organizationId: _currentOrgId,
      );

      emit(
        AdminShiftApprovedSuccessfully(
          shifts: refreshedShifts,
          weekStart: weekStart,
          weekEnd: weekEnd,
        ),
      );
    } catch (e) {
      emit(AdminShiftError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshAdminShifts event,
    Emitter<AdminShiftState> emit,
  ) async {
    if (_currentWeekStart == null || _currentWeekEnd == null) return;

    add(
      LoadAdminShiftsForWeek(
        weekStart: _currentWeekStart!,
        weekEnd: _currentWeekEnd!,
        organizationId: _currentOrgId,
      ),
    );
  }
}
