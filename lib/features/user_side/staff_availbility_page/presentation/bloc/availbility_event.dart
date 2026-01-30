import 'package:equatable/equatable.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

abstract class AvailabilityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAvailabilityRange extends AvailabilityEvent {
  final String startDate;
  final String endDate;

  LoadAvailabilityRange({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class SaveAvailabilityForDate extends AvailabilityEvent {
  final AvailabilityEntity entity;
  SaveAvailabilityForDate(this.entity);

  @override
  List<Object?> get props => [entity];
}

class DeleteAvailabilityForDate extends AvailabilityEvent {
  final DateTime date;
  final String shift; // ✅ Proper field

  DeleteAvailabilityForDate({
    required this.date,
    required this.shift, // ✅ Required parameter
  });

  @override
  List<Object?> get props => [date, shift]; // ✅ Includes shift in equality
}

class LoadStaffAvailabilityRange extends AvailabilityEvent {
  final String startDate;
  final String endDate;
  final int staffId;

  LoadStaffAvailabilityRange({
    required this.startDate,
    required this.endDate,
    required this.staffId,
  });

  @override
  List<Object?> get props => [startDate, endDate, staffId];
}

class EditAvailabilityForDate extends AvailabilityEvent {
  final AvailabilityEntity entity;
  EditAvailabilityForDate(this.entity);

  @override
  List<Object?> get props => [entity];
}
