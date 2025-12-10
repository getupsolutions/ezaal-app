import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class ApprovePendingShiftClaimsUseCase {
  final AdminShiftRepository repository;

  ApprovePendingShiftClaimsUseCase(this.repository);

  Future<void> call({
    DateTime? startDate,
    DateTime? endDate,
    int? organizationId,
    int? staffId,
  }) {
    return repository.approvePendingShiftClaims(
      startDate: startDate,
      endDate: endDate,
      organizationId: organizationId,
      staffId: staffId,
    );
  }
}
