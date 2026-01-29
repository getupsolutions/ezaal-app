import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';

class SendStaffAvailableShiftMailUseCase {
  final AdminShiftRepository repository;

  SendStaffAvailableShiftMailUseCase(this.repository);

  Future<Map<String, dynamic>> call({required List<int> shiftIds}) async {
    return await repository.sendStaffAvailableShiftMail(shiftIds: shiftIds);
  }
}
