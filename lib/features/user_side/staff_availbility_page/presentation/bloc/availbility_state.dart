import 'package:equatable/equatable.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

class AvailabilityState extends Equatable {
  final bool loading;
  final List<AvailabilityEntity> items;
  final String? error;
  final String? success;

  const AvailabilityState({
    required this.loading,
    required this.items,
    this.error,
    this.success,
  });

  factory AvailabilityState.initial() =>
      const AvailabilityState(loading: false, items: []);

  AvailabilityState copyWith({
    bool? loading,
    List<AvailabilityEntity>? items,
    String? error,
    String? success,
  }) {
    return AvailabilityState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
      success: success,
    );
  }

  @override
  List<Object?> get props => [loading, items, error, success];
}
