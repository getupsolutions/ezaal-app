// import 'dart:typed_data';

// import 'package:ezaal/core/constant/constant.dart';
// import 'package:ezaal/core/services/location_service.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_event.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_state.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_event.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
// import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:signature/signature.dart';

// class ClockinShiftCard extends StatefulWidget {
//   final String requestID;
//   final String time;
//   final String role;
//   final String location;
//   final String address;
//   final String? shiftDate;
//   final bool inTimeStatus;
//   final bool outTimeStatus;
//   final bool managerStatus;
//   final double screenWidth;
//   final double screenHeight;
//   final VoidCallback? onOperationQueued;

//   const ClockinShiftCard({
//     super.key,
//     required this.requestID,
//     required this.time,
//     required this.role,
//     required this.location,
//     required this.address,
//     this.shiftDate,
//     required this.inTimeStatus,
//     required this.outTimeStatus,
//     required this.managerStatus,
//     required this.screenWidth,
//     required this.screenHeight,
//     this.onOperationQueued,
//   });

//   @override
//   State<ClockinShiftCard> createState() => _ClockinShiftCardState();
// }

// class _ClockinShiftCardState extends State<ClockinShiftCard> {
//   // Local state mirrors API & updates instantly for UI
//   bool _localInTimeStatus = false;
//   bool _localOutTimeStatus = false;
//   bool _localManagerStatus = false;

//   @override
//   void initState() {
//     super.initState();
//     _localInTimeStatus = widget.inTimeStatus;
//     _localOutTimeStatus = widget.outTimeStatus;
//     _localManagerStatus = widget.managerStatus;
//   }

//   @override
//   void didUpdateWidget(ClockinShiftCard oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.inTimeStatus != oldWidget.inTimeStatus) {
//       _localInTimeStatus = widget.inTimeStatus;
//     }
//     if (widget.outTimeStatus != oldWidget.outTimeStatus) {
//       _localOutTimeStatus = widget.outTimeStatus;
//     }
//     if (widget.managerStatus != oldWidget.managerStatus) {
//       _localManagerStatus = widget.managerStatus;
//     }
//   }

//   String _formatDate(String? date) {
//     if (date == null || date.isEmpty) return '';

//     try {
//       final parsed = DateTime.parse(date);
//       final formatted = DateFormat('EEE, dd-MMM-yyyy').format(parsed);
//       return formatted;
//     } catch (e) {
//       return date;
//     }
//   }

//   void _onAttendanceStateChanged(BuildContext context, AttendanceState state) {
//     if (state is AttendanceFailure) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ ${state.message}'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } else if (state is ClockInSuccess) {
//       // Clock In success
//       if (!mounted) return;
//       setState(() {
//         _localInTimeStatus = true;
//       });

//       widget.onOperationQueued?.call();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             state.isOfflineQueued
//                 ? '📥 Clock-in saved. Will sync when online.'
//                 : '✅ Clocked in successfully',
//           ),
//           backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );

//       context.read<SlotBloc>().add(LoadSlots());
//     } else if (state is ClockOutSuccess) {
//       // Clock Out success
//       if (!mounted) return;
//       setState(() {
//         _localOutTimeStatus = true;
//       });

//       widget.onOperationQueued?.call();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             state.isOfflineQueued
//                 ? '📥 Clock-out saved. Will sync when online.'
//                 : '✅ Clocked out successfully',
//           ),
//           backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );

//       context.read<SlotBloc>().add(LoadSlots());
//     }
//   }

//   void _onManagerInfoStateChanged(
//     BuildContext context,
//     ManagerInfoState state,
//   ) {
//     if (state is ManagerInfoSuccess) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             state.isOfflineQueued
//                 ? '📥 Manager info saved. Will sync when online.'
//                 : '✅ Manager info recorded successfully',
//           ),
//           backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
//         ),
//       );

//       widget.onOperationQueued?.call();

//       setState(() {
//         _localManagerStatus = true;
//       });

//       context.read<SlotBloc>().add(LoadSlots());
//     } else if (state is ManagerInfoFailure) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('❌ ${state.message}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<AttendanceBloc, AttendanceState>(
//           listener: _onAttendanceStateChanged,
//         ),
//         BlocListener<ManagerInfoBloc, ManagerInfoState>(
//           listener: _onManagerInfoStateChanged,
//         ),
//       ],
//       child: BlocBuilder<AttendanceBloc, AttendanceState>(
//         builder: (context, attendanceState) {
//           return BlocBuilder<ManagerInfoBloc, ManagerInfoState>(
//             builder: (context, managerState) {
//               final bool showClockIn = !_localInTimeStatus;
//               // NEW FLOW: after clock-in, button is Clock Out (manager info is inside this flow)
//               final bool showClockOut =
//                   _localInTimeStatus && !_localOutTimeStatus;
//               final bool isCompleted =
//                   _localInTimeStatus &&
//                   _localManagerStatus &&
//                   _localOutTimeStatus;

//               final bool isLoading =
//                   attendanceState is AttendanceLoading ||
//                   managerState is ManagerInfoLoading;

//               return Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   width: widget.screenWidth,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isCompleted ? Colors.green : Colors.grey,
//                       width: isCompleted ? 2 : 1,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     color: isCompleted ? Colors.green.shade50 : Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade300,
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Left info
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.access_time,
//                                   size: 16,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   widget.time,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: widget.screenHeight * 0.008),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.calendar_today_outlined,
//                                   size: 14,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     _formatDate(widget.shiftDate),
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: widget.screenHeight * 0.008),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.badge_outlined,
//                                   size: 14,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(child: Text(widget.role)),
//                               ],
//                             ),
//                             SizedBox(height: widget.screenHeight * 0.008),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.business,
//                                   size: 14,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(child: Text(widget.location)),
//                               ],
//                             ),
//                             SizedBox(height: widget.screenHeight * 0.008),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on_outlined,
//                                   size: 14,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     widget.address,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (isCompleted) ...[
//                               SizedBox(height: widget.screenHeight * 0.008),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: const Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.check_circle,
//                                       color: Colors.white,
//                                       size: 14,
//                                     ),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       'Completed',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ] else if (_localInTimeStatus &&
//                                 !_localOutTimeStatus) ...[
//                               SizedBox(height: widget.screenHeight * 0.008),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade100,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.timer,
//                                       color: Colors.blue.shade700,
//                                       size: 14,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       'In Progress',
//                                       style: TextStyle(
//                                         color: Colors.blue.shade700,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // Right button
//                       SizedBox(
//                         height: 40,
//                         width: 110,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 showClockIn ? primaryColor : Colors.red,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 2,
//                           ),
//                           onPressed:
//                               isLoading || isCompleted
//                                   ? null
//                                   : () async {
//                                     if (showClockIn) {
//                                       await _handleClockIn(context);
//                                     } else if (showClockOut) {
//                                       await _handleFullClockOutFlow(context);
//                                     }
//                                   },
//                           child:
//                               isLoading
//                                   ? const SizedBox(
//                                     width: 16,
//                                     height: 16,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                   : Text(
//                                     showClockIn ? 'Clock In' : 'Clock Out',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ---------- CLOCK IN ----------

//   Future<void> _handleClockIn(BuildContext context) async {
//     final confirm = await _showConfirmationDialog(context);
//     if (!confirm || !mounted) return;

//     final userLocation = await LocationService.getCurrentLocation();

//     if (userLocation == null) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Unable to get your location. Please enable location services.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }

//     final now = DateTime.now();
//     final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

//     final parts = widget.time.split(' - ');
//     if (parts.length < 2) return;

//     try {
//       final startTime = DateFormat('HH:mm:ss').parse(parts[0]);
//       final startDateTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         startTime.hour,
//         startTime.minute,
//         startTime.second,
//       );

//       String signintype = 'ontime';
//       bool needsReason = false;

//       if (now.isBefore(startDateTime)) {
//         signintype = 'early';
//         needsReason = true;
//       } else if (now.isAfter(startDateTime.add(const Duration(minutes: 15)))) {
//         signintype = 'late';
//         needsReason = true;
//       }

//       if (needsReason) {
//         await _showReasonDialog(
//           context,
//           title: signintype == 'early' ? 'Early Clock-In' : 'Late Clock-In',
//           requestID: widget.requestID,
//           currentTime: currentTime,
//           signintype: signintype,
//           userLocation: userLocation,
//         );
//       } else {
//         if (!mounted) return;
//         context.read<AttendanceBloc>().add(
//           ClockInRequested(
//             requestID: widget.requestID,
//             inTime: currentTime,
//             signintype: signintype,
//             userLocation: userLocation,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Time parse error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error parsing time format')),
//       );
//     }
//   }

//   // ---------- NEW FULL CLOCK OUT FLOW ----------

//   Future<void> _handleFullClockOutFlow(BuildContext context) async {
//     final now = DateTime.now();
//     final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

//     final parts = widget.time.split(' - ');
//     if (parts.length < 2) {
//       debugPrint('❌ Invalid time format: ${widget.time}');
//       return;
//     }

//     DateTime endDateTime;
//     try {
//       final endTime = DateFormat('HH:mm:ss').parse(parts[1]);
//       endDateTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         endTime.hour,
//         endTime.minute,
//         endTime.second,
//       );
//     } catch (e) {
//       debugPrint('❌ Time parse error in _handleFullClockOutFlow: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error parsing time format: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     String signouttype = 'ontime';
//     bool needsReason = false;

//     if (now.isBefore(endDateTime.subtract(const Duration(minutes: 15)))) {
//       signouttype = 'early';
//       needsReason = true;
//     } else if (now.isAfter(endDateTime.add(const Duration(minutes: 15)))) {
//       signouttype = 'late';
//       needsReason = true;
//     }

//     if (!mounted) return;

//     debugPrint('➡️ Starting full clock-out flow for ${widget.requestID}');

//     // 1️⃣ Collect Manager Info (NOT saving yet)
//     final managerInfo = await _collectManagerInfoDialog(context);
//     debugPrint('Manager info dialog result: $managerInfo');

//     if (managerInfo == null) {
//       debugPrint('⛔ Manager info cancelled');
//       return;
//     }
//     if (!mounted) return;

//     // 🔑 IMPORTANT: give Flutter a frame to finish popping previous dialog
//     await Future.delayed(const Duration(milliseconds: 10));
//     if (!mounted) return;

//     // 2️⃣ Collect Clock Out form (NOT saving yet)
//     final clockOutForm = await _collectClockOutFormDialog(
//       context,
//       title:
//           needsReason
//               ? (signouttype == 'early' ? 'Early Clock-Out' : 'Late Clock-Out')
//               : 'Clock Out Confirmation',
//       message:
//           needsReason
//               ? 'You are clocking out ${signouttype == 'early' ? 'before' : 'after'} your scheduled time.'
//               : 'Are you sure you want to clock out?',
//       needsReason: needsReason,
//       signouttype: signouttype,
//     );

//     debugPrint('Clock-out form dialog result: $clockOutForm');

//     if (clockOutForm == null) {
//       // User cancelled clock out form
//       debugPrint('⛔ Clock-out form cancelled');
//       return;
//     }
//     if (!mounted) return;

//     // 🔑 Again, tiny delay before final dialog
//     await Future.delayed(const Duration(milliseconds: 10));
//     if (!mounted) return;

//     // 3️⃣ Final review popup
//     final confirmed = await _showFinalReviewDialog(
//       context,
//       managerInfo: managerInfo,
//       clockOutForm: clockOutForm,
//       signouttype: signouttype,
//       outTime: currentTime,
//     );

//     debugPrint('Final review confirmed: $confirmed');

//     if (!confirmed) {
//       // User cancelled at final review -> DO NOT SAVE anything
//       debugPrint('⛔ Final review cancelled, nothing saved');
//       return;
//     }
//     if (!mounted) return;

//     // 4️⃣ Submit to DB via blocs (Manager Info + Clock Out)
//     final managerInfoBloc = context.read<ManagerInfoBloc>();
//     final attendanceBloc = context.read<AttendanceBloc>();

//     debugPrint('✅ Dispatching ManagerInfo & ClockOut events');

//     managerInfoBloc.add(
//       SubmitManagerInfoRequested(
//         requestID: widget.requestID,
//         managerName: managerInfo.name,
//         managerDesignation: managerInfo.designation,
//         signatureBytes: managerInfo.signatureBytes,
//       ),
//     );

//     attendanceBloc.add(
//       ClockOutRequested(
//         requestID: widget.requestID,
//         outTime: currentTime,
//         shiftbreak: clockOutForm.breakTime,
//         notes: clockOutForm.reason,
//         signouttype: signouttype,
//       ),
//     );
//   }

//   // ---------- DIALOG HELPERS ----------

//   Future<bool> _showConfirmationDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           builder:
//               (dialogContext) => AlertDialog(
//                 title: const Text('Are You Sure?', textAlign: TextAlign.center),
//                 content: const Text(
//                   'Please confirm your work hours and obtain the necessary signature '
//                   'from the staff or RN in charge at the end of each shift.\nBe punctual.\nThank you!',
//                   textAlign: TextAlign.center,
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(dialogContext, false),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(dialogContext, true),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                     ),
//                     child: const Text(
//                       'Confirm',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }

//   Future<void> _showReasonDialog(
//     BuildContext context, {
//     required String title,
//     required String requestID,
//     required String currentTime,
//     required String signintype,
//     String? userLocation,
//   }) async {
//     final TextEditingController reasonController = TextEditingController();

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (dialogContext) => AlertDialog(
//             title: Text(title),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Please provide a reason for this clock-in.',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: reasonController,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Reason',
//                     hintText: 'Enter your reason here...',
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
//                 onPressed: () {
//                   if (reasonController.text.trim().isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter a reason')),
//                     );
//                     return;
//                   }
//                   Navigator.pop(dialogContext);
//                   if (!mounted) return;
//                   context.read<AttendanceBloc>().add(
//                     ClockInRequested(
//                       requestID: requestID,
//                       inTime: currentTime,
//                       notes: reasonController.text.trim(),
//                       signintype: signintype,
//                       userLocation: userLocation,
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   // Temporary holder classes
//   Future<_ManagerInfoTemp?> _collectManagerInfoDialog(
//     BuildContext context,
//   ) async {
//     final TextEditingController nameController = TextEditingController();
//     final TextEditingController designationController = TextEditingController();
//     final SignatureController signatureController = SignatureController(
//       penStrokeWidth: 2,
//       penColor: Colors.black,
//       exportBackgroundColor: Colors.white,
//     );

//     final result = await showDialog<_ManagerInfoTemp>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.person, color: primaryColor),
//               const SizedBox(width: 8),
//               const Text('Manager Information'),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Please obtain the necessary signature from the staff or RN in charge.',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Full Name of Incharge / Authorized Person',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: designationController,
//                   decoration: const InputDecoration(
//                     labelText: 'Designation',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Signature',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: MediaQuery.of(dialogContext).size.width * 0.8,
//                   height: 150,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Signature(
//                     controller: signatureController,
//                     backgroundColor: Colors.grey.shade100,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton.icon(
//                       onPressed: () => signatureController.clear(),
//                       icon: const Icon(Icons.clear, size: 16),
//                       label: const Text('Clear'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, null),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
//               onPressed: () async {
//                 if (nameController.text.trim().isEmpty ||
//                     designationController.text.trim().isEmpty) {
//                   ScaffoldMessenger.of(dialogContext).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please fill all fields'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 if (signatureController.isEmpty) {
//                   ScaffoldMessenger.of(dialogContext).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please provide a signature'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 final signatureBytes = await signatureController.toPngBytes();
//                 if (signatureBytes == null) {
//                   ScaffoldMessenger.of(dialogContext).showSnackBar(
//                     const SnackBar(
//                       content: Text('Failed to capture signature'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 Navigator.pop(
//                   dialogContext,
//                   _ManagerInfoTemp(
//                     name: nameController.text.trim(),
//                     designation: designationController.text.trim(),
//                     signatureBytes: signatureBytes,
//                   ),
//                 );
//               },
//               child: const Text('Next', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );

//     return result;
//   }

//   Future<_ClockOutTemp?> _collectClockOutFormDialog(
//     BuildContext context, {
//     required String title,
//     required String message,
//     required bool needsReason,
//     required String signouttype,
//   }) async {
//     final TextEditingController breakTimeController = TextEditingController();
//     final TextEditingController reasonController = TextEditingController();

//     final result = await showDialog<_ClockOutTemp>(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (dialogContext) => AlertDialog(
//             title: Text(title),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(message, style: const TextStyle(fontSize: 14)),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Break Time (minutes)',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: breakTimeController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'e.g., 30',
//                       prefixIcon: Icon(Icons.access_time),
//                     ),
//                   ),
//                   if (needsReason) ...[
//                     const SizedBox(height: 16),
//                     Text(
//                       'Reason for ${signouttype == 'early' ? 'Early' : 'Late'} Clock-Out',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: reasonController,
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(),
//                         hintText: 'Enter your reason here...',
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(dialogContext, null),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 onPressed: () {
//                   if (breakTimeController.text.trim().isEmpty) {
//                     ScaffoldMessenger.of(dialogContext).showSnackBar(
//                       const SnackBar(content: Text('Please enter break time')),
//                     );
//                     return;
//                   }

//                   if (needsReason && reasonController.text.trim().isEmpty) {
//                     ScaffoldMessenger.of(dialogContext).showSnackBar(
//                       const SnackBar(content: Text('Please enter a reason')),
//                     );
//                     return;
//                   }

//                   final breakTime = breakTimeController.text.trim();
//                   final reason =
//                       needsReason ? reasonController.text.trim() : null;

//                   Navigator.pop(
//                     dialogContext,
//                     _ClockOutTemp(breakTime: breakTime, reason: reason),
//                   );
//                 },
//                 child: const Text(
//                   'Next',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );

//     return result;
//   }

//   Future<bool> _showFinalReviewDialog(
//     BuildContext context, {
//     required _ManagerInfoTemp managerInfo,
//     required _ClockOutTemp clockOutForm,
//     required String signouttype,
//     required String outTime,
//   }) async {
//     final String scheduledStart =
//         widget.time.split(' - ').isNotEmpty ? widget.time.split(' - ')[0] : '';

//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (dialogContext) => AlertDialog(
//                 title: const Text('Review & Submit'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Please review the details before submitting.',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildReviewRow('Shift Time', widget.time),
//                       _buildReviewRow('Clock-In (scheduled)', scheduledStart),
//                       _buildReviewRow('Clock-Out', outTime),
//                       const SizedBox(height: 12),
//                       const Divider(),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Manager Info',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildReviewRow('Name', managerInfo.name),
//                       _buildReviewRow('Designation', managerInfo.designation),
//                       const SizedBox(height: 12),
//                       const Divider(),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Clock-Out Details',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildReviewRow(
//                         'Sign-out Type',
//                         signouttype.toUpperCase(),
//                       ),
//                       _buildReviewRow(
//                         'Break (minutes)',
//                         clockOutForm.breakTime,
//                       ),
//                       if (clockOutForm.reason != null &&
//                           clockOutForm.reason!.isNotEmpty)
//                         _buildReviewRow('Reason', clockOutForm.reason!),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'If you press Cancel, Manager Info and Clock-Out will not be saved.',
//                         style: TextStyle(fontSize: 12, color: Colors.redAccent),
//                       ),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(dialogContext, false),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                     ),
//                     onPressed: () => Navigator.pop(dialogContext, true),
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }

//   Widget _buildReviewRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//             ),
//           ),
//           Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
//         ],
//       ),
//     );
//   }
// }

// // Simple internal holder classes for dialog data
// class _ManagerInfoTemp {
//   final String name;
//   final String designation;
//   final Uint8List signatureBytes;

//   _ManagerInfoTemp({
//     required this.name,
//     required this.designation,
//     required this.signatureBytes,
//   });
// }

// class _ClockOutTemp {
//   final String breakTime;
//   final String? reason;

//   _ClockOutTemp({required this.breakTime, this.reason});
// }
