// import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/clockout_entity.dart';

// class ClockOutModel extends ClockOutEntity {
//   const ClockOutModel({
//     required super.requestID,
//     required super.outTime,
//     required super.signouttype,
//     required super.signoutreason,
//     required super.shiftbreak,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'requestID': requestID,
//       'outTime': outTime,
//       'signouttype': signouttype,
//       'notes': signoutreason,
//       'shiftbreak': shiftbreak,
//     };
//   }

//   factory ClockOutModel.fromJson(Map<String, dynamic> json) {
//     return ClockOutModel(
//       requestID: json['requestID']?.toString() ?? '',
//       outTime: json['outTime'] ?? '',
//       signouttype: json['signouttype'] ?? '',
//       signoutreason: json['notes'] ?? '',
//       shiftbreak: json['shiftbreak'] ?? '',
//     );
//   }
// }
