import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';

abstract class ShiftState {}

class ShiftInitial extends ShiftState {}

class ShiftLoading extends ShiftState {}

class ShiftLoaded extends ShiftState {
  final List<ShiftEntity> shifts;
  ShiftLoaded(this.shifts);
}

class ShiftError extends ShiftState {
  final String message;
  ShiftError(this.message);
}

class ShiftClaimSuccess extends ShiftState {
  final String message;
  ShiftClaimSuccess({this.message = 'Shift claimed successfully!'});
}

class ShiftClaimError extends ShiftState {
  final String message;
  ShiftClaimError(this.message);
}

class ShiftSessionExpired extends ShiftState {}

class ShiftClaimPending extends ShiftState {
  final String message;
  ShiftClaimPending({this.message = 'Shift claim sent for admin approval'});
}
