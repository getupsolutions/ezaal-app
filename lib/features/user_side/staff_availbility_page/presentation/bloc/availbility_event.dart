import 'package:equatable/equatable.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

abstract class AvailabilityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAvailabilityRange extends AvailabilityEvent {
  final String startDate;
  final String endDate;
  final int? organiz;
  LoadAvailabilityRange({
    required this.startDate,
    required this.endDate,
    this.organiz,
  });

  @override
  List<Object?> get props => [startDate, endDate, organiz];
}

class SaveAvailabilityForDate extends AvailabilityEvent {
  final AvailabilityEntity entity;
  SaveAvailabilityForDate(this.entity);

  @override
  List<Object?> get props => [entity];
}

class DeleteAvailabilityForDate extends AvailabilityEvent {
  final DateTime date;
  final int? organiz;
  DeleteAvailabilityForDate({required this.date, this.organiz});

  @override
  List<Object?> get props => [date, organiz];
}

class LoadStaffAvailabilityRange extends AvailabilityEvent {
  final String startDate;
  final String endDate;
  final int staffId;
  final int? organiz;

  LoadStaffAvailabilityRange({
    required this.startDate,
    required this.endDate,
    required this.staffId,
    this.organiz,
  });
}

class EditAvailabilityForDate extends AvailabilityEvent {
  final AvailabilityEntity entity;
  EditAvailabilityForDate(this.entity);
}
