import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class SendStaffConfirmedMailUseCase {
  final AdminShiftRepository repository;

  SendStaffConfirmedMailUseCase(this.repository);

  Future<Map<String, dynamic>> call({required List<int> shiftIds}) async {
    if (shiftIds.isEmpty) {
      throw Exception('No shift IDs provided');
    }

    return await repository.sendStaffConfirmedMail(shiftIds: shiftIds);
  }
}
