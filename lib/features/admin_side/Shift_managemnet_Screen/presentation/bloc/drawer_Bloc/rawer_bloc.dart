// Events

import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/drawer_Bloc/drawer_event.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/drawer_Bloc/drawer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToPage>((event, emit) {
      emit(NavigationState(selectedIndex: event.pageIndex));
    });
  }
}
