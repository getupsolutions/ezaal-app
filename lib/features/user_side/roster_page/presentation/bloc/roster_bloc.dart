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

      // ✅ Filter by today's date on initial load
      final today = DateTime.now();
      final todayString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      print('Today\'s date: $todayString');

      // Filter rosters for today
      final todayRosters =
          rosterList.where((e) => e.date == todayString).toList();

      print('Rosters found for today: ${todayRosters.length}');

      // ✅ Always start with filtered view (today's date)
      // This will show empty state if no rosters exist for today
      emit(
        RosterLoaded(
          rosterList: rosterList,
          filteredList: todayRosters, // Show only today's rosters
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
      // ✅ Show all rosters when reset is triggered
      emit(currentState.copyWith(filteredList: currentState.rosterList));
    }
  }
}
