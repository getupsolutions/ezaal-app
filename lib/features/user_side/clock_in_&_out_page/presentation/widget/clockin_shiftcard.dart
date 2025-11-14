import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/services/location_service.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class ClockinShiftCard extends StatelessWidget {
  final String requestID;
  final String time;
  final String role;
  final String location;
  final String address;
  final bool inTimeStatus;
  final bool outTimeStatus;
  final bool managerStatus; // Add this

  final double screenWidth;
  final double screenHeight;

  const ClockinShiftCard({
    super.key,
    required this.requestID,
    required this.time,
    required this.role,
    required this.location,
    required this.address,
    required this.inTimeStatus,
    required this.outTimeStatus,
    required this.managerStatus,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is ClockInSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Clocked in successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.read<SlotBloc>().add(LoadSlots());
            }
          });
        } else if (state is ClockOutSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Clocked out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.read<SlotBloc>().add(LoadSlots());
            }
          });
        }
      },
      builder: (context, state) {
        final bool showClockIn = !inTimeStatus;
        final bool showClockOut = inTimeStatus && !outTimeStatus;
        final bool isCompleted = inTimeStatus && outTimeStatus;
        final bool isLoading = state is AttendanceLoading;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: screenWidth,
            decoration: BoxDecoration(
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey,
                width: isCompleted ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
              color: isCompleted ? Colors.green.shade50 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Text(role)),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Text(location)),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isCompleted) ...[
                        SizedBox(height: screenHeight * 0.008),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (inTimeStatus && !outTimeStatus) ...[
                        SizedBox(height: screenHeight * 0.008),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.blue.shade700,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'In Progress',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  width: isCompleted ? 110 : 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCompleted
                              ? Colors.blue
                              : (showClockOut ? Colors.red : primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              if (isCompleted) {
                                _showManagerInfoDialog(context);
                              } else if (showClockOut) {
                                await _handleClockOut(context);
                              } else if (showClockIn) {
                                await _handleClockIn(context);
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              isCompleted
                                  ? 'Manager Info'
                                  : (showClockOut ? 'Clock Out' : 'Clock In'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleClockIn(BuildContext context) async {
    final confirm = await _showConfirmationDialog(context);
    if (!confirm || !context.mounted) return;
    // Get user's current location
    final userLocation = await LocationService.getCurrentLocation();

    if (userLocation == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get your location. Please enable location services.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        // You can choose to either return here or continue without location
        // return; // Uncomment to block clock-in without location
      }
    }

    final now = DateTime.now();
    final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final parts = time.split(' - ');
    if (parts.length < 2) return;

    try {
      final startTime = DateFormat('HH:mm:ss').parse(parts[0]);
      final startDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        startTime.hour,
        startTime.minute,
        startTime.second,
      );

      String signintype = 'ontime';
      bool needsReason = false;

      if (now.isBefore(startDateTime)) {
        signintype = 'early';
        needsReason = true;
      } else if (now.isAfter(startDateTime.add(const Duration(minutes: 15)))) {
        signintype = 'late';
        needsReason = true;
      }

      if (needsReason) {
        await _showReasonDialog(
          context,
          title: signintype == 'early' ? 'Early Clock-In' : 'Late Clock-In',
          requestID: requestID,
          currentTime: currentTime,
          signintype: signintype,
          userLocation: userLocation,
        );
      } else {
        if (context.mounted) {
          context.read<AttendanceBloc>().add(
            ClockInRequested(
              requestID: requestID,
              inTime: currentTime,
              signintype: signintype,
              userLocation: userLocation,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Time parse error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error parsing time format')),
        );
      }
    }
  }

  Future<void> _handleClockOut(BuildContext context) async {
    final now = DateTime.now();
    final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final parts = time.split(' - ');
    if (parts.length < 2) {
      debugPrint('❌ Invalid time format: $time');
      return;
    }

    try {
      debugPrint('=== CLOCK OUT HANDLER START ===');
      debugPrint('Time string: $time');
      debugPrint('Request ID: $requestID');
      debugPrint('Current time: $currentTime');

      final endTime = DateFormat('HH:mm:ss').parse(parts[1]);
      final endDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        endTime.hour,
        endTime.minute,
        endTime.second,
      );

      String signouttype = 'ontime';
      bool needsReason = false;

      if (now.isBefore(endDateTime.subtract(const Duration(minutes: 15)))) {
        signouttype = 'early';
        needsReason = true;
      } else if (now.isAfter(endDateTime.add(const Duration(minutes: 15)))) {
        signouttype = 'late';
        needsReason = true;
      }

      debugPrint('Sign out type: $signouttype');
      debugPrint('Needs reason: $needsReason');
      debugPrint('================================');

      // CRITICAL FIX: Capture BLoC reference BEFORE showing dialog
      if (!context.mounted) return;

      final attendanceBloc = context.read<AttendanceBloc>();

      await _showClockOutDialog(
        context,
        title:
            needsReason
                ? (signouttype == 'early'
                    ? 'Early Clock-Out'
                    : 'Late Clock-Out')
                : 'Clock Out Confirmation',
        message:
            needsReason
                ? 'You are clocking out ${signouttype == 'early' ? 'before' : 'after'} your scheduled time.'
                : 'Are you sure you want to clock out?',
        needsReason: needsReason,
        requestID: requestID,
        currentTime: currentTime,
        signouttype: signouttype,
        attendanceBloc: attendanceBloc, // Pass BLoC directly
      );
    } catch (e) {
      debugPrint('❌ Time parse error in _handleClockOut: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing time format: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Are You Sure?', textAlign: TextAlign.center),
                content: const Text(
                  'Please confirm your work hours and obtain the necessary signature '
                  'from the staff or RN in charge at the end of each shift.\nBe punctual.\nThank you!',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showReasonDialog(
    BuildContext context, {
    required String title,
    required String requestID,
    required String currentTime,
    required String signintype,
    String? userLocation,
  }) async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please provide a reason for $title.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reason',
                    hintText: 'Enter your reason here...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a reason')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  context.read<AttendanceBloc>().add(
                    ClockInRequested(
                      requestID: requestID,
                      inTime: currentTime,
                      notes: reasonController.text.trim(),
                      signintype: signintype,
                      userLocation: userLocation,
                    ),
                  );
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showClockOutDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool needsReason,
    required String requestID,
    required String currentTime,
    required String signouttype,
    required AttendanceBloc attendanceBloc, // Receive BLoC directly
  }) async {
    debugPrint('=== SHOWING CLOCK OUT DIALOG ===');
    debugPrint('Title: $title');
    debugPrint('Needs Reason: $needsReason');

    final TextEditingController breakTimeController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    // Store values before dialog closes
    String? breakTime;
    String? reason;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  const Text(
                    'Break Time (minutes)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: breakTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 30',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  if (needsReason) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Reason for ${signouttype == 'early' ? 'Early' : 'Late'} Clock-Out',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your reason here...',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  debugPrint('Clock out dialog cancelled');
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  debugPrint('=== DIALOG CONFIRM PRESSED ===');
                  debugPrint('Break time: ${breakTimeController.text.trim()}');
                  debugPrint('Reason: ${reasonController.text.trim()}');

                  if (breakTimeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Please enter break time')),
                    );
                    return;
                  }

                  if (needsReason && reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Please enter a reason')),
                    );
                    return;
                  }

                  // Store values BEFORE closing dialog
                  breakTime = breakTimeController.text.trim();
                  reason = needsReason ? reasonController.text.trim() : null;

                  debugPrint('Validation passed, closing dialog');
                  Navigator.pop(dialogContext, true);
                },
                child: const Text(
                  'Confirm Clock Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    debugPrint('=== DIALOG RESULT ===');
    debugPrint('Dialog result: $result');

    // CRITICAL FIX: Use BLoC directly without checking context.mounted
    if (result == true) {
      debugPrint('=== SUBMITTING CLOCK OUT ===');
      debugPrint('Request ID: $requestID');
      debugPrint('Out Time: $currentTime');
      debugPrint('Break Time: $breakTime');
      debugPrint('Sign Out Type: $signouttype');
      debugPrint('Notes: $reason');
      debugPrint('===========================');

      // Use the BLoC reference we captured earlier
      attendanceBloc.add(
        ClockOutRequested(
          requestID: requestID,
          outTime: currentTime,
          shiftbreak: breakTime,
          notes: reason,
          signouttype: signouttype,
        ),
      );

      debugPrint('✅ Clock out event dispatched to bloc');
    } else {
      debugPrint('❌ Clock out cancelled by user');
    }
  }

  void _showManagerInfoDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController designationController = TextEditingController();
    final SignatureController signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Get BLoC before showing dialog
    final managerInfoBloc = context.read<ManagerInfoBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person, color: primaryColor),
              const SizedBox(width: 8),
              const Text('Manager Information'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please obtain the necessary signature from the staff or RN in charge.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Full Name Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name of Incharge / Authorized Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Designation Field
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Signature',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Signature Pad
                Container(
                  width: MediaQuery.of(dialogContext).size.width * 0.8,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Signature(
                    controller: signatureController,
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),

                const SizedBox(height: 8),

                // Signature actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => signatureController.clear(),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                const Text(
                  'Your shift has been completed successfully.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            BlocConsumer<ManagerInfoBloc, ManagerInfoState>(
              listener: (context, state) {
                if (state is ManagerInfoSuccess) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Manager info recorded successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload slots
                  context.read<SlotBloc>().add(LoadSlots());
                } else if (state is ManagerInfoFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is ManagerInfoLoading;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (nameController.text.trim().isEmpty ||
                                designationController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (signatureController.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Please provide a signature'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Export signature as bytes
                            final signatureBytes =
                                await signatureController.toPngBytes();

                            if (signatureBytes == null) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to capture signature'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Submit via BLoC
                            managerInfoBloc.add(
                              SubmitManagerInfoRequested(
                                requestID: requestID,
                                managerName: nameController.text.trim(),
                                managerDesignation:
                                    designationController.text.trim(),
                                signatureBytes: signatureBytes,
                              ),
                            );
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
