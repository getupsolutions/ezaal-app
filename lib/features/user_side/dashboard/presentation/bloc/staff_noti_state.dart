import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';


class StaffNotificationState {
  final bool loading;
  final int staffUnreadCount;
  final List<StaffNotificationEntity> staffNotifications;
  final String? error;

  const StaffNotificationState({
    required this.loading,
    required this.staffUnreadCount,
    required this.staffNotifications,
    this.error,
  });

  factory StaffNotificationState.initial() => const StaffNotificationState(
    loading: false,
    staffUnreadCount: 0,
    staffNotifications: [],
    error: null,
  );

  StaffNotificationState copyWith({
    bool? loading,
    int? staffUnreadCount,
    List<StaffNotificationEntity>? staffNotifications,
    String? error,
  }) {
    return StaffNotificationState(
      loading: loading ?? this.loading,
      staffUnreadCount: staffUnreadCount ?? this.staffUnreadCount,
      staffNotifications: staffNotifications ?? this.staffNotifications,
      error: error,
    );
  }
}
