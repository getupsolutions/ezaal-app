import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<NavigateToAvailableShift>(_onNavigateToAvailableShift);
    on<NavigateToMyRoster>(_onNavigateToMyRoster);
    on<NavigateToClockInOut>(_onNavigateToClockInOut);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(DashboardLoaded(userName: 'Bijo MATHEW'));
  }

  void _onNavigateToAvailableShift(
    NavigateToAvailableShift event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigating(destination: 'Available Shift'));
  }

  void _onNavigateToMyRoster(
    NavigateToMyRoster event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigating(destination: 'My Roster'));
  }

  void _onNavigateToClockInOut(
    NavigateToClockInOut event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardNavigating(destination: 'Clock In & Clock Out'));
  }
}
