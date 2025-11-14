import 'dart:typed_data';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/data_source/managerinfo_datasource.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/managerinfo_repository.dart';


class ManagerInfoRepositoryImpl implements ManagerInfoRepository {
  final ManagerInfoRemoteDataSource remoteDataSource;

  ManagerInfoRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitManagerInfo({
    required String requestID,
    required String managerName,
    required String managerDesignation,
    required Uint8List signatureBytes,
  }) {
    return remoteDataSource.submitManagerInfo(
      requestID: requestID,
      managerName: managerName,
      managerDesignation: managerDesignation,
      signatureBytes: signatureBytes,
    );
  }
}
