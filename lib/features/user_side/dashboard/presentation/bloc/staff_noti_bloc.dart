import 'package:ezaal/features/user_side/dashboard/domain/usecase/staff_noti_usecase.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_event.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class StaffNotificationBloc extends Bloc<StaffNotificationEvent, StaffNotificationState> {
  final GetStaffUnreadCountUC getUnreadCountUC;
  final GetStaffNotificationsUC getNotificationsUC;

  StaffNotificationBloc({
    required this.getUnreadCountUC,
    required this.getNotificationsUC,
  }) : super(StaffNotificationState.initial()) {
    on<FetchStaffUnreadCount>(_fetchUnread);
    on<FetchStaffNotifications>(_fetchList);
  }

  Future<void> _fetchUnread(
    FetchStaffUnreadCount event,
    Emitter<StaffNotificationState> emit,
  ) async {
    try {
      final count = await getUnreadCountUC(type: event.type);
      emit(state.copyWith(staffUnreadCount: count, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _fetchList(
    FetchStaffNotifications event,
    Emitter<StaffNotificationState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await getNotificationsUC(
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      emit(
        state.copyWith(loading: false, staffNotifications: list, error: null),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
