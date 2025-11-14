// import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/clockin_entity.dart';

// class ClockInModel extends ClockInEntity {
//   const ClockInModel({
//     required super.requestID,
//     required super.inTime,
//     required super.signintype,
//     required super.signinreason,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'requestID': requestID,
//       'inTime': inTime,
//       'signintype': signintype,
//       'notes': signinreason,
//     };
//   }

//   factory ClockInModel.fromJson(Map<String, dynamic> json) {
//     return ClockInModel(
//       requestID: json['requestID']?.toString() ?? '',
//       inTime: json['inTime'] ?? '',
//       signintype: json['signintype'] ?? '',
//       signinreason: json['notes'] ?? '',
//     );
//   }
// }