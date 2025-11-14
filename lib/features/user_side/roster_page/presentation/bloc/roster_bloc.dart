// presentation/bloc/roster_bloc.dart
import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';
import 'package:ezaal/features/user_side/roster_page/domain/usecase/get_roster_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'roster_event.dart';
part 'roster_state.dart';

class RosterBloc extends Bloc<RosterEvent, RosterState> {
  final GetRosterUseCase getRosterUseCase;
  final GetRosterCalendarUseCase getRosterCalendarUseCase;

  RosterBloc({
    required this.getRosterUseCase,
    required this.getRosterCalendarUseCase,
  }) : super(RosterInitial()) {
    on<LoadRosters>(_onLoadRosters);
    on<FilterRostersByDate>(_onFilterRostersByDate);
    on<ResetFilter>(_onResetFilter);
  }

  Future<void> _onLoadRosters(
    LoadRosters event,
    Emitter<RosterState> emit,
  ) async {
    emit(RosterLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final rosterList = await getRosterUseCase();
      print('Loaded ${rosterList.length} rosters');

      // Initially show all rosters or filter by today's date
      final today = DateTime.now();
      final todayString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final todayRosters =
          rosterList.where((e) => e.date == todayString).toList();

      emit(
        RosterLoaded(
          rosterList: rosterList,
          filteredList: todayRosters.isNotEmpty ? todayRosters : rosterList,
        ),
      );
    } catch (e) {
      print('Error loading rosters: $e');
      emit(RosterError(message: e.toString()));
    }
  }

  void _onFilterRostersByDate(
    FilterRostersByDate event,
    Emitter<RosterState> emit,
  ) {
    if (state is RosterLoaded) {
      final currentState = state as RosterLoaded;

      print('Filtering by date: ${event.selectedDate}');
      print('Total rosters: ${currentState.rosterList.length}');

      // Filter rosters by selected date
      final filtered =
          currentState.rosterList.where((roster) {
            print(
              'Comparing: roster.date="${roster.date}" with selected="${event.selectedDate}"',
            );
            return roster.date == event.selectedDate;
          }).toList();

      print('Filtered count: ${filtered.length}');

      emit(currentState.copyWith(filteredList: filtered));
    }
  }

  void _onResetFilter(ResetFilter event, Emitter<RosterState> emit) {
    if (state is RosterLoaded) {
      final currentState = state as RosterLoaded;
      emit(currentState.copyWith(filteredList: currentState.rosterList));
    }
  }
}
