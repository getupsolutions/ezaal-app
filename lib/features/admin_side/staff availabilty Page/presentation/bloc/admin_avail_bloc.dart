import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/usecase/get_admin_availability_usecase.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_event.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminAvailabilityBloc
    extends Bloc<AdminAvailabilityEvent, AdminAvailabilityState> {
  final GetAdminAvailabilityRange getRange;

  AdminAvailabilityBloc(this.getRange) : super(const AdminAvailabilityState()) {
    on<LoadAdminAvailabilityRange>(_onLoad);
  }

  Future<void> _onLoad(
    LoadAdminAvailabilityRange event,
    Emitter<AdminAvailabilityState> emit,
  ) async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final data = await getRange(
        startDate: event.startDate,
        endDate: event.endDate,
        organiz: event.organiz,
        staffId: null, // ✅ admin wants all staff
      );

      emit(state.copyWith(loading: false, items: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
