// presentation/bloc/Admin Shift/admin_shift_bloc.dart
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/savde_admin_shiftmodel.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/save_shift_respo.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/adminshift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/approve_pendingshiftclaim.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/cancel_shift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/get_shift_master_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/save_admin_shiftusecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_organization_rostermail_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_staff_available_shift.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_staff_confirmed_mail_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/update_shift_statususecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/update_shift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_shift_state.dart';

class AdminShiftBloc extends Bloc<AdminShiftEvent, AdminShiftState> {
  final GetAdminShiftsForWeek getAdminShiftsForWeek;
  final ApprovePendingShiftClaimsUseCase approvePendingShiftClaims;
  final SaveAdminShiftUseCase saveAdminShiftUseCase;
  final GetShiftMastersUseCase getShiftMastersUseCase;
  final CancelAdminShiftUseCase cancelAdminShiftUseCase;
  final CancelAdminShiftStaffUseCase cancelAdminShiftStaffUseCase;
  final UpdateShiftAttendanceUseCase updateShiftAttendanceUseCase;
  final UpdateShiftStatusUseCase updateShiftStatusUseCase;
  final SendOrganizationRosterMailUseCase sendOrganizationRosterMailUseCase;
  final SendStaffConfirmedMailUseCase sendStaffConfirmedMailUseCase;
  final SendStaffAvailableShiftMailUseCase sendStaffAvailableShiftMailUseCase;

  DateTime? _currentWeekStart;
  DateTime? _currentWeekEnd;
  int? _currentOrgId;
  int? _currentStaffId;
  String? _currentStatus;
  int? _currentStaffTypeId;
  int? _currentDepartmentId;

  AdminShiftBloc({
    required this.getAdminShiftsForWeek,
    required this.approvePendingShiftClaims,
    required this.saveAdminShiftUseCase,
    required this.getShiftMastersUseCase,
    required this.cancelAdminShiftUseCase,
    required this.cancelAdminShiftStaffUseCase,
    required this.updateShiftAttendanceUseCase,
    required this.updateShiftStatusUseCase,
    required this.sendOrganizationRosterMailUseCase,
    required this.sendStaffConfirmedMailUseCase,
    required this.sendStaffAvailableShiftMailUseCase,
  }) : super(AdminShiftInitial()) {
    on<LoadAdminShiftsForWeek>(_onLoadWeek);
    on<RefreshAdminShifts>(_onRefresh);
    on<ApprovePendingShiftClaimsEvent>(_onApprovePendingShiftClaims);
    on<SubmitShiftEvent>(_onSubmitShift);
    on<LoadShiftMastersEvent>(_onLoadMasters);
    on<CancelAdminShiftEvent>(_onCancelShift);
    on<CancelAdminShiftStaffEvent>(_onCancelShiftStaff);
    on<UpdateShiftAttendanceEvent>(_onUpdateAttendance);
    on<ToggleShiftApprovalEvent>(_onToggleShiftApproval);
    on<SendOrganizationRosterMailEvent>(_onSendOrgMail);
    on<SendStaffConfirmedMailEvent>(_onSendStaffConfirmedMail);
    on<SendStaffAvailableShiftMailEvent>(_onSendStaffAvailableShiftMail);
  }

  Future<void> _onLoadWeek(
    LoadAdminShiftsForWeek event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(AdminShiftLoading());

    _currentWeekStart = event.weekStart;
    _currentWeekEnd = event.weekEnd;
    _currentOrgId = event.organizationId;
    _currentStaffId = event.staffId;
    _currentStatus = event.status;
    _currentStaffTypeId = event.staffTypeId;
    _currentDepartmentId = event.departmentId;

    try {
      final shifts = await getAdminShiftsForWeek(
        event.weekStart,
        event.weekEnd,
        organizationId: event.organizationId,
        staffId: event.staffId,
        status: event.status,
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
      emit(
        AdminShiftApproving(
          shifts: currentShifts,
          weekStart: weekStart,
          weekEnd: weekEnd,
        ),
      );

      await approvePendingShiftClaims(
        startDate: event.startDate,
        endDate: event.endDate,
        organizationId: event.organizationId,
        staffId: event.staffId,
      );

      final refreshedShifts = await getAdminShiftsForWeek(
        weekStart,
        weekEnd,
        organizationId: _currentOrgId,
        staffId: _currentStaffId,
        status: _currentStatus,
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
        staffId: _currentStaffId,
        status: _currentStatus,
        staffTypeId: _currentStaffTypeId,
        departmentId: _currentDepartmentId,
      ),
    );
  }

  Future<void> _onSubmitShift(
    SubmitShiftEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(AddEditShiftSubmitting());

    try {
      final copies = event.copies <= 0 ? 1 : event.copies;

      SaveShiftResponse? lastResp;

      for (int i = 0; i < copies; i++) {
        final idForThisIteration =
            (copies == 1) ? event.id : (i == 0 ? event.id : null);

        final params = SaveAdminShiftParams(
          id: idForThisIteration,
          organizationId: event.organizationId,
          staffTypeId: event.staffTypeId,
          date: event.date,
          fromTime: event.fromTime,
          toTime: event.toTime,
          notes: event.notes,
          breakMinutes: event.breakMinutes,
          staffId: event.staffId,
          departmentId: event.departmentId,
        );

        lastResp = await saveAdminShiftUseCase(params);
      }

      final mailMsg =
          (lastResp?.mailSent == true)
              ? " Email sent to ${lastResp?.mailTo ?? 'staff'}."
              : (lastResp?.mailReason != null)
              ? " Email not sent (${lastResp!.mailReason})."
              : "";

      emit(
        AddEditShiftSuccess(
          message:
              (event.id != null)
                  ? "Shift updated.$mailMsg"
                  : "Shift created.$mailMsg",
        ),
      );

      // refresh week same as your existing code...
      if (_currentWeekStart != null && _currentWeekEnd != null) {
        final refreshedShifts = await getAdminShiftsForWeek(
          _currentWeekStart!,
          _currentWeekEnd!,
          organizationId: _currentOrgId,
          staffId: _currentStaffId,
          status: _currentStatus,
        );

        emit(
          AdminShiftLoaded(
            shifts: refreshedShifts,
            weekStart: _currentWeekStart!,
            weekEnd: _currentWeekEnd!,
          ),
        );
      }
    } catch (e) {
      emit(AddEditShiftFailure(e.toString()));
    }
  }

  Future<void> _onCancelShift(
    CancelAdminShiftEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    if (_currentWeekStart == null || _currentWeekEnd == null) return;

    emit(AdminShiftLoading());
    try {
      await cancelAdminShiftUseCase(event.shiftId);

      final refreshed = await getAdminShiftsForWeek(
        _currentWeekStart!,
        _currentWeekEnd!,
        organizationId: _currentOrgId,
        staffId: _currentStaffId,
        status: _currentStatus,
      );

      emit(
        AdminShiftActionSuccess(
          message: 'Shift cancelled successfully',
          shifts: refreshed,
          weekStart: _currentWeekStart!,
          weekEnd: _currentWeekEnd!,
        ),
      );
    } catch (e) {
      emit(AdminShiftError(e.toString()));
    }
  }

  Future<void> _onCancelShiftStaff(
    CancelAdminShiftStaffEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    if (_currentWeekStart == null || _currentWeekEnd == null) return;

    emit(AdminShiftLoading());
    try {
      await cancelAdminShiftStaffUseCase(event.shiftId);

      final refreshed = await getAdminShiftsForWeek(
        _currentWeekStart!,
        _currentWeekEnd!,
        organizationId: _currentOrgId,
        staffId: _currentStaffId,
        status: _currentStatus,
      );

      emit(
        AdminShiftActionSuccess(
          message: 'Staff removed from shift',
          shifts: refreshed,
          weekStart: _currentWeekStart!,
          weekEnd: _currentWeekEnd!,
        ),
      );
    } catch (e) {
      emit(AdminShiftError(e.toString()));
    }
  }

  Future<void> _onLoadMasters(
    LoadShiftMastersEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(ShiftMastersLoading());
    try {
      final masters = await getShiftMastersUseCase();
      emit(ShiftMastersLoaded(masters));
    } catch (e) {
      emit(ShiftMastersError(e.toString()));
    }
  }

  Future<void> _onUpdateAttendance(
    UpdateShiftAttendanceEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(UpdateShiftAttendanceSubmitting());

    try {
      await updateShiftAttendanceUseCase(event.params);

      // After update, refresh current week shifts if we know the range
      if (_currentWeekStart != null && _currentWeekEnd != null) {
        final refreshed = await getAdminShiftsForWeek(
          _currentWeekStart!,
          _currentWeekEnd!,
          organizationId: _currentOrgId,
          staffId: _currentStaffId,
          status: _currentStatus,
        );

        emit(
          AdminShiftLoaded(
            shifts: refreshed,
            weekStart: _currentWeekStart!,
            weekEnd: _currentWeekEnd!,
          ),
        );
      }

      emit(
        UpdateShiftAttendanceSuccess(
          message: 'Clock-in/Clock-out and manager info updated',
        ),
      );
    } catch (e) {
      emit(UpdateShiftAttendanceFailure(e.toString()));
    }
  }

  Future<void> _onToggleShiftApproval(
    ToggleShiftApprovalEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    if (_currentWeekStart == null || _currentWeekEnd == null) {
      // We can still call, but refresh will be skipped
    }

    // Optional loading state
    emit(AdminShiftLoading());

    try {
      await updateShiftStatusUseCase(
        shiftId: event.shiftId,
        approve: event.approve,
      );

      // Refresh current week list if we know the filters
      List<ShiftItem> refreshed = [];
      DateTime weekStart = _currentWeekStart ?? DateTime.now();
      DateTime weekEnd =
          _currentWeekEnd ?? weekStart.add(const Duration(days: 6));

      if (_currentWeekStart != null && _currentWeekEnd != null) {
        refreshed = await getAdminShiftsForWeek(
          weekStart,
          weekEnd,
          organizationId: _currentOrgId,
          staffId: _currentStaffId,
          status: _currentStatus,
        );
      }

      final isApprove = event.approve;
      final msg =
          event.approve
              ? 'Shift approved successfully'
              : 'Shift unapproved Successfully';
      final color = isApprove ? success : danger;

      emit(
        AdminShiftActionSuccess(
          message: msg,
          shifts: refreshed,
          weekStart: weekStart,
          weekEnd: weekEnd,
          snackColor: color,
        ),
      );
    } catch (e) {
      emit(AdminShiftError(e.toString()));
    }
  }

  Future<void> _onSendOrgMail(
    SendOrganizationRosterMailEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(OrgMailSending());
    try {
      print(
        '📧 Sending org mail: orgId=${event.organizationId}, '
        'start=${event.startDate}, end=${event.endDate}, '
        'includeCancelled=${event.includeCancelled}',
      );

      await sendOrganizationRosterMailUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
        organizationId: event.organizationId,
        includeCancelled: event.includeCancelled,
      );

      print('✅ Org mail API success');
      emit(OrgMailSentSuccess('Organization roster email sent'));
    } catch (e) {
      print('❌ Org mail API failed: $e');
      emit(OrgMailSentFailure(e.toString()));
    }
  }

  Future<void> _onSendStaffConfirmedMail(
    SendStaffConfirmedMailEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(StaffConfirmedMailSending());

    try {
      print(
        '📧 Sending staff confirmed mail for ${event.shiftIds.length} shifts',
      );

      final result = await sendStaffConfirmedMailUseCase(
        shiftIds: event.shiftIds,
      );

      final sentCount = result['sent_count'] as int? ?? 0;
      final failedCount = result['failed_count'] as int? ?? 0;

      print(
        '✅ Staff confirmed mail sent: $sentCount success, $failedCount failed',
      );

      String message;
      if (sentCount > 0 && failedCount == 0) {
        message =
            sentCount == 1
                ? 'Confirmed shift email sent successfully'
                : 'Confirmed shift emails sent to $sentCount staff members';
      } else if (sentCount > 0 && failedCount > 0) {
        message = 'Emails sent to $sentCount staff. $failedCount failed.';
      } else {
        message = 'No emails were sent. Please check shift assignments.';
      }

      emit(
        StaffConfirmedMailSentSuccess(
          message: message,
          sentCount: sentCount,
          failedCount: failedCount,
        ),
      );
    } catch (e) {
      print('❌ Staff confirmed mail failed: $e');
      emit(StaffConfirmedMailSentFailure(e.toString()));
    }
  }

  Future<void> _onSendStaffAvailableShiftMail(
    SendStaffAvailableShiftMailEvent event,
    Emitter<AdminShiftState> emit,
  ) async {
    emit(StaffAvailableShiftMailSending());

    try {
      print(
        '📧 Sending staff available shift mail for ${event.shiftIds.length} shifts',
      );

      final result = await sendStaffAvailableShiftMailUseCase(
        shiftIds: event.shiftIds,
      );

      final sentCount = result['sent_count'] as int? ?? 0;
      final failedCount = result['failed_count'] as int? ?? 0;
      final totalEligible = result['total_eligible'] as int? ?? 0;

      print(
        '✅ Staff available shift mail sent: $sentCount success, '
        '$failedCount failed, $totalEligible eligible',
      );

      String message;
      if (sentCount > 0 && failedCount == 0) {
        message =
            sentCount == 1
                ? 'Available shift email sent to 1 eligible staff member'
                : 'Available shift emails sent to $sentCount eligible staff members';
      } else if (sentCount > 0 && failedCount > 0) {
        message =
            'Emails sent to $sentCount staff. $failedCount failed. '
            'Total eligible: $totalEligible';
      } else if (totalEligible == 0) {
        message = 'No eligible staff found for these shifts.';
      } else {
        message =
            'No emails were sent. $totalEligible staff were eligible but emails failed.';
      }

      emit(
        StaffAvailableShiftMailSentSuccess(
          message: message,
          sentCount: sentCount,
          failedCount: failedCount,
          totalEligible: totalEligible,
        ),
      );
    } catch (e) {
      print('❌ Staff available shift mail failed: $e');
      emit(StaffAvailableShiftMailSentFailure(e.toString()));
    }
  }
}
