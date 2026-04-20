import 'package:ezaal/features/user_side/dashboard/domain/enitity/staff_notification_entity.dart';

class StaffNotificationState {
  final bool loading;
  final bool deleting;
  final int staffUnreadCount;
  final List<StaffNotificationEntity> staffNotifications;
  final String? error;

  const StaffNotificationState({
    required this.loading,
    required this.deleting,
    required this.staffUnreadCount,
    required this.staffNotifications,
    this.error,
  });

  factory StaffNotificationState.initial() => const StaffNotificationState(
    loading: false,
    deleting: false,
    staffUnreadCount: 0,
    staffNotifications: [],
    error: null,
  );

  StaffNotificationState copyWith({
    bool? loading,
    bool? deleting,
    int? staffUnreadCount,
    List<StaffNotificationEntity>? staffNotifications,
    String? error,
  }) {
    return StaffNotificationState(
      loading: loading ?? this.loading,
      deleting: deleting ?? this.deleting,
      staffUnreadCount: staffUnreadCount ?? this.staffUnreadCount,
      staffNotifications: staffNotifications ?? this.staffNotifications,
      error: error,
    );
  }
}
