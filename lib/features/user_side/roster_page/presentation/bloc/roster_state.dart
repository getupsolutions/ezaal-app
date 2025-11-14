// presentation/bloc/roster_state.dart
part of 'roster_bloc.dart';

abstract class RosterState {}

class RosterInitial extends RosterState {}

class RosterLoading extends RosterState {}

class RosterLoaded extends RosterState {
  final List<RosterEntity> rosterList;
  final List<RosterEntity> filteredList;

  RosterLoaded({required this.rosterList, required this.filteredList});

  RosterLoaded copyWith({
    List<RosterEntity>? rosterList,
    List<RosterEntity>? filteredList,
  }) {
    return RosterLoaded(
      rosterList: rosterList ?? this.rosterList,
      filteredList: filteredList ?? this.filteredList,
    );
  }
}

class RosterError extends RosterState {
  final String message;
  RosterError({required this.message});
}
