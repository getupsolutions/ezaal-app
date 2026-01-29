import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class SendOrganizationRosterMailUseCase {
  final AdminShiftRepository repo;
  SendOrganizationRosterMailUseCase(this.repo);

  Future<void> call({
    required DateTime startDate,
    required DateTime endDate,
    required int organizationId,
    required bool includeCancelled,
  }) {
    return repo.sendOrganizationRosterMail(
      startDate: startDate,
      endDate: endDate,
      organizationId: organizationId,
      includeCancelled: includeCancelled,
    );
  }
}
