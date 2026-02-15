// import 'dart:convert';
// import 'dart:typed_data';

// class TempClockOutData {
//   final String requestID;
//   final String currentTime;
//   final String signouttype;
//   final String? breakTime;
//   final String? reason;
//   final String managerName;
//   final String managerDesignation;
//   final Uint8List signatureBytes;

//   TempClockOutData({
//     required this.requestID,
//     required this.currentTime,
//     required this.signouttype,
//     this.breakTime,
//     this.reason,
//     required this.managerName,
//     required this.managerDesignation,
//     required this.signatureBytes,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'requestID': requestID,
//       'currentTime': currentTime,
//       'signouttype': signouttype,
//       'breakTime': breakTime,
//       'reason': reason,
//       'managerName': managerName,
//       'managerDesignation': managerDesignation,
//       'signatureBase64': base64Encode(signatureBytes),
//     };
//   }

//   factory TempClockOutData.fromJson(Map<String, dynamic> json) {
//     return TempClockOutData(
//       requestID: json['requestID'],
//       currentTime: json['currentTime'],
//       signouttype: json['signouttype'],
//       breakTime: json['breakTime'],
//       reason: json['reason'],
//       managerName: json['managerName'],
//       managerDesignation: json['managerDesignation'],
//       signatureBytes: base64Decode(json['signatureBase64']),
//     );
//   }
// }
