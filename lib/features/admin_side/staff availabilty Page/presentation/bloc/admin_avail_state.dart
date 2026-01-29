import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';

class AdminAvailabilityState {
  final bool loading;
  final List<AdminAvailablitEntity> items; // ✅ FIXED
  final String? error;

  const AdminAvailabilityState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  AdminAvailabilityState copyWith({
    bool? loading,
    List<AdminAvailablitEntity>? items, // ✅ FIXED
    String? error,
  }) {
    return AdminAvailabilityState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
    );
  }
}
