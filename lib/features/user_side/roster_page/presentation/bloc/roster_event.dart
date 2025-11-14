// presentation/bloc/roster_event.dart
part of 'roster_bloc.dart';

abstract class RosterEvent {}

class LoadRosters extends RosterEvent {}

class FilterRostersByDate extends RosterEvent {
  final String selectedDate;
  FilterRostersByDate(this.selectedDate);
}

class ResetFilter extends RosterEvent {}
