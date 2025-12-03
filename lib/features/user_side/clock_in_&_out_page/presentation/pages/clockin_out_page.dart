import 'dart:typed_data';

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/di/di.dart' as di;
import 'package:ezaal/core/services/location_service.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

/// =========================
/// PAGE
/// =========================

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  String get todayDate => DateFormat('dd MMMM yyyy').format(DateTime.now());
  String get todayDay => DateFormat('EEEE').format(DateTime.now());
  int _pendingOperationsCount = 0;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    context.read<SlotBloc>().add(LoadSlots());
    _loadPendingOperationsCount();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final isOnline = await OfflineQueueService.isOnline();
    if (mounted) {
      setState(() {
        _isOffline = !isOnline;
      });
    }
  }

  Future<void> _loadPendingOperationsCount() async {
    final count = await OfflineQueueService.getQueueCount();
    if (mounted) {
      setState(() {
        _pendingOperationsCount = count;
      });
    }
  }

  Future<void> _manualSync() async {
    final isOnline = await OfflineQueueService.isOnline();

    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Device is offline. Cannot sync now.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_pendingOperationsCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ No pending operations to sync'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Syncing offline operations...'),
                    ],
                  ),
                ),
              ),
            ),
      );
    }

    try {
      final syncService = di.sl<OfflineSyncService>();
      final result = await syncService.syncAllOperations();

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        context.read<SlotBloc>().add(LoadSlots());
        await _loadPendingOperationsCount();
        await checkConnectivity();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Clock In & Clock Out',
        backgroundColor: const Color(0xff0c2340),
        elevation: 2,
        actions: [
          if (_pendingOperationsCount > 0)
            IconButton(
              icon: Badge(
                label: Text('$_pendingOperationsCount'),
                child: const Icon(Icons.cloud_upload, color: Colors.white),
              ),
              onPressed: _manualSync,
              tooltip: 'Sync pending operations',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              context.read<SlotBloc>().add(LoadSlots());
              await _loadPendingOperationsCount();
              await checkConnectivity();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  todayDate,
                  style: const TextStyle(
                    color: Color(0xff00bcd4),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  todayDay,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // Offline mode banner
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode - Showing cached data',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Pending operations banner
          if (_pendingOperationsCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.sync, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_pendingOperationsCount operation(s) pending sync',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _manualSync,
                    child: const Text('Sync Now'),
                  ),
                ],
              ),
            ),

          // Slots list
          Expanded(
            child: BlocBuilder<SlotBloc, SlotState>(
              builder: (context, state) {
                if (state is SlotLoading) {
                  return ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return buildSlotCardShimmer(screenWidth);
                    },
                  );
                } else if (state is SlotLoaded) {
                  if (state.slots.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No slots available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isOffline
                                ? 'No cached slots found. Connect to internet to load.'
                                : 'You have no shifts scheduled for today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.slots.length,
                    itemBuilder: (context, index) {
                      final slot = state.slots[index];
                      return ClockinShiftCard(
                        managerStatus: slot.managerStatus,
                        requestID: slot.id,
                        time: slot.time,
                        role: slot.role,
                        location: slot.location,
                        address: slot.address,
                        shiftDate: slot.shiftDate,
                        inTimeStatus: slot.inTimeStatus,
                        outTimeStatus: slot.outTimeStatus,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onOperationQueued: _loadPendingOperationsCount,
                      );
                    },
                  );
                } else if (state is SlotError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading slots',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<SlotBloc>().add(LoadSlots());
                            _loadPendingOperationsCount();
                            checkConnectivity();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0c2340),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No slots available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// SHIFT CARD
/// =========================

class ClockinShiftCard extends StatefulWidget {
  final String requestID;
  final String time;
  final String role;
  final String location;
  final String address;
  final String? shiftDate;
  final bool inTimeStatus;
  final bool outTimeStatus;
  final bool managerStatus;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? onOperationQueued;

  const ClockinShiftCard({
    super.key,
    required this.requestID,
    required this.time,
    required this.role,
    required this.location,
    required this.address,
    this.shiftDate,
    required this.inTimeStatus,
    required this.outTimeStatus,
    required this.managerStatus,
    required this.screenWidth,
    required this.screenHeight,
    this.onOperationQueued,
  });

  @override
  State<ClockinShiftCard> createState() => _ClockinShiftCardState();
}

class _ClockinShiftCardState extends State<ClockinShiftCard> {
  // Local state mirrors API & updates instantly for UI
  bool _localInTimeStatus = false;
  bool _localOutTimeStatus = false;
  bool _localManagerStatus = false;

  @override
  void initState() {
    super.initState();
    _localInTimeStatus = widget.inTimeStatus;
    _localOutTimeStatus = widget.outTimeStatus;
    _localManagerStatus = widget.managerStatus;
  }

  @override
  void didUpdateWidget(ClockinShiftCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.inTimeStatus != oldWidget.inTimeStatus) {
      _localInTimeStatus = widget.inTimeStatus;
    }
    if (widget.outTimeStatus != oldWidget.outTimeStatus) {
      _localOutTimeStatus = widget.outTimeStatus;
    }
    if (widget.managerStatus != oldWidget.managerStatus) {
      _localManagerStatus = widget.managerStatus;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final parsed = DateTime.parse(date);
      final formatted = DateFormat('EEE, dd-MMM-yyyy').format(parsed);
      return formatted;
    } catch (e) {
      return date;
    }
  }

  void _onAttendanceStateChanged(BuildContext context, AttendanceState state) {
    if (state is AttendanceFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${state.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (state is ClockInSuccess) {
      // Clock In success
      if (!mounted) return;
      setState(() {
        _localInTimeStatus = true;
      });

      widget.onOperationQueued?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isOfflineQueued
                ? '📥 Clock-in saved. Will sync when online.'
                : '✅ Clocked in successfully',
          ),
          backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      context.read<SlotBloc>().add(LoadSlots());
    } else if (state is ClockOutSuccess) {
      // Clock Out success
      if (!mounted) return;
      setState(() {
        _localOutTimeStatus = true;
      });

      widget.onOperationQueued?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isOfflineQueued
                ? '📥 Clock-out saved. Will sync when online.'
                : '✅ Clocked out successfully',
          ),
          backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      context.read<SlotBloc>().add(LoadSlots());
    }
  }

  void _onManagerInfoStateChanged(
    BuildContext context,
    ManagerInfoState state,
  ) {
    if (state is ManagerInfoSuccess) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isOfflineQueued
                ? '📥 Manager info saved. Will sync when online.'
                : '✅ Manager info recorded successfully',
          ),
          backgroundColor: state.isOfflineQueued ? Colors.blue : Colors.green,
        ),
      );

      widget.onOperationQueued?.call();

      setState(() {
        _localManagerStatus = true;
      });

      context.read<SlotBloc>().add(LoadSlots());
    } else if (state is ManagerInfoFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AttendanceBloc, AttendanceState>(
          listener: _onAttendanceStateChanged,
        ),
        BlocListener<ManagerInfoBloc, ManagerInfoState>(
          listener: _onManagerInfoStateChanged,
        ),
      ],
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, attendanceState) {
          return BlocBuilder<ManagerInfoBloc, ManagerInfoState>(
            builder: (context, managerState) {
              final bool showClockIn = !_localInTimeStatus;
              // NEW FLOW: after clock-in, button is Clock Out (manager info is inside this flow)
              final bool showClockOut =
                  _localInTimeStatus && !_localOutTimeStatus;
              final bool isCompleted =
                  _localInTimeStatus &&
                  _localManagerStatus &&
                  _localOutTimeStatus;

              final bool isLoading =
                  attendanceState is AttendanceLoading ||
                  managerState is ManagerInfoLoading;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: widget.screenWidth,
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
                      // Left info
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
                                  widget.time,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.screenHeight * 0.008),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatDate(widget.shiftDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.screenHeight * 0.008),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text(widget.role)),
                              ],
                            ),
                            SizedBox(height: widget.screenHeight * 0.008),
                            Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(child: Text(widget.location)),
                              ],
                            ),
                            SizedBox(height: widget.screenHeight * 0.008),
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
                                    widget.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (isCompleted) ...[
                              SizedBox(height: widget.screenHeight * 0.008),
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
                            ] else if (_localInTimeStatus &&
                                !_localOutTimeStatus) ...[
                              SizedBox(height: widget.screenHeight * 0.008),
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
                      // Right button
                      SizedBox(
                        height: 40,
                        width: 110,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                showClockIn ? primaryColor : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed:
                              isLoading || isCompleted
                                  ? null
                                  : () async {
                                    if (showClockIn) {
                                      await _handleClockIn(context);
                                    } else if (showClockOut) {
                                      await _handleFullClockOutFlow(context);
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
                                    showClockIn ? 'Clock In' : 'Clock Out',
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
        },
      ),
    );
  }

  // ---------- CLOCK IN (fixed) ----------

  Future<void> _handleClockIn(BuildContext context) async {
    // ✅ Capture bloc before any dialogs so we don't depend on widget being mounted later
    final attendanceBloc = context.read<AttendanceBloc>();

    final confirm = await _showConfirmationDialog(context);
    if (!confirm) return;

    // Location does not depend on widget mount
    final userLocation = await LocationService.getCurrentLocation();

    if (userLocation == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get your location. Please enable location services.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    final now = DateTime.now();
    final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final parts = widget.time.split(' - ');
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
        // ✅ Pass the bloc into the dialog to avoid context.read inside
        await _showReasonDialog(
          context,
          attendanceBloc: attendanceBloc,
          title: signintype == 'early' ? 'Early Clock-In' : 'Late Clock-In',
          requestID: widget.requestID,
          currentTime: currentTime,
          signintype: signintype,
          userLocation: userLocation,
        );
      } else {
        // No reason dialog needed, dispatch directly using captured bloc
        attendanceBloc.add(
          ClockInRequested(
            requestID: widget.requestID,
            inTime: currentTime,
            signintype: signintype,
            userLocation: userLocation,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Time parse error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error parsing time format')),
        );
      }
    }
  }

  // ---------- FULL CLOCK OUT FLOW (WIZARD DIALOG) ----------

  Future<void> _handleFullClockOutFlow(BuildContext context) async {
    final now = DateTime.now();
    final currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final parts = widget.time.split(' - ');
    if (parts.length < 2) {
      debugPrint('❌ Invalid time format: ${widget.time}');
      return;
    }

    DateTime endDateTime;
    try {
      final endTime = DateFormat('HH:mm:ss').parse(parts[1]);
      endDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        endTime.hour,
        endTime.minute,
        endTime.second,
      );
    } catch (e) {
      debugPrint('❌ Time parse error in _handleFullClockOutFlow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing time format: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String signouttype = 'ontime';
    bool needsReason = false;

    if (now.isBefore(endDateTime.subtract(const Duration(minutes: 15)))) {
      signouttype = 'early';
      needsReason = true;
    } else if (now.isAfter(endDateTime.add(const Duration(minutes: 15)))) {
      signouttype = 'late';
      needsReason = true;
    }

    if (!mounted) return;

    debugPrint('➡️ Starting full clock-out wizard for ${widget.requestID}');

    // ✅ Capture bloc references while this widget is still mounted
    final managerInfoBloc = context.read<ManagerInfoBloc>();
    final attendanceBloc = context.read<AttendanceBloc>();

    // Single wizard dialog for Manager Info + Clock Out + Review
    final wizardResult = await _showClockOutWizardDialog(
      context,
      shiftTime: widget.time,
      signouttype: signouttype,
      needsReason: needsReason,
      outTime: currentTime,
    );

    debugPrint('Wizard result: $wizardResult');

    // ✅ Only check for null; DO NOT check "mounted" here
    if (wizardResult == null) {
      debugPrint('⛔ Wizard cancelled, nothing saved');
      return;
    }

    debugPrint('✅ Dispatching ManagerInfo & ClockOut events from wizard');

    managerInfoBloc.add(
      SubmitManagerInfoRequested(
        requestID: widget.requestID,
        managerName: wizardResult.managerInfo.name,
        managerDesignation: wizardResult.managerInfo.designation,
        signatureBytes: wizardResult.managerInfo.signatureBytes,
      ),
    );

    attendanceBloc.add(
      ClockOutRequested(
        requestID: widget.requestID,
        outTime: currentTime,
        shiftbreak: wizardResult.clockOutForm.breakTime,
        notes: wizardResult.clockOutForm.reason,
        signouttype: signouttype,
      ),
    );
  }

  // ---------- DIALOG HELPERS ----------

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Are You Sure?', textAlign: TextAlign.center),
                content: const Text(
                  'Please confirm your work hours and obtain the necessary signature '
                  'from the staff or RN in charge at the end of each shift.\nBe punctual.\nThank you!',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
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
    required AttendanceBloc attendanceBloc,
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
          (dialogContext) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide a reason for this clock-in.',
                  style: TextStyle(fontSize: 14),
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
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Please enter a reason')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext);

                  // ✅ Use captured bloc, not dialog context
                  attendanceBloc.add(
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

  /// SINGLE wizard dialog that collects:
  /// 1) Manager info + signature
  /// 2) Clock-out details
  /// 3) Review & submit
  Future<_ClockOutWizardResult?> _showClockOutWizardDialog(
    BuildContext context, {
    required String shiftTime,
    required String signouttype,
    required bool needsReason,
    required String outTime,
  }) async {
    return showDialog<_ClockOutWizardResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ClockOutWizardDialog(
          shiftTime: shiftTime,
          signouttype: signouttype,
          needsReason: needsReason,
          outTime: outTime,
        );
      },
    );
  }
}

/// =========================
/// WIZARD DIALOG WIDGET
/// =========================

class _ClockOutWizardDialog extends StatefulWidget {
  final String shiftTime;
  final String signouttype;
  final bool needsReason;
  final String outTime;

  const _ClockOutWizardDialog({
    required this.shiftTime,
    required this.signouttype,
    required this.needsReason,
    required this.outTime,
  });

  @override
  State<_ClockOutWizardDialog> createState() => _ClockOutWizardDialogState();
}

class _ClockOutWizardDialogState extends State<_ClockOutWizardDialog> {
  int _step = 0;

  // Manager info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  late SignatureController _signatureController;

  // Clock-out info
  final TextEditingController _breakTimeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  _ManagerInfoTemp? _managerInfo;
  _ClockOutTemp? _clockOutForm;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _breakTimeController.dispose();
    _reasonController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _nextFromManagerStep() async {
    if (_nameController.text.trim().isEmpty ||
        _designationController.text.trim().isEmpty) {
      _showSnack('Please fill all manager fields');
      return;
    }

    if (_signatureController.isEmpty) {
      _showSnack('Please provide a signature');
      return;
    }

    final signatureBytes = await _signatureController.toPngBytes();
    if (signatureBytes == null) {
      _showSnack('Failed to capture signature');
      return;
    }

    _managerInfo = _ManagerInfoTemp(
      name: _nameController.text.trim(),
      designation: _designationController.text.trim(),
      signatureBytes: signatureBytes,
    );

    setState(() {
      _step = 1;
    });
  }

  void _nextFromClockOutStep() {
    if (_breakTimeController.text.trim().isEmpty) {
      _showSnack('Please enter break time');
      return;
    }

    if (widget.needsReason && _reasonController.text.trim().isEmpty) {
      _showSnack('Please enter a reason');
      return;
    }

    _clockOutForm = _ClockOutTemp(
      breakTime: _breakTimeController.text.trim(),
      reason: widget.needsReason ? _reasonController.text.trim() : null,
    );

    setState(() {
      _step = 2;
    });
  }

  void _submit() {
    if (_managerInfo == null || _clockOutForm == null) {
      _showSnack('Missing data to submit');
      return;
    }

    Navigator.pop(
      context,
      _ClockOutWizardResult(
        managerInfo: _managerInfo!,
        clockOutForm: _clockOutForm!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String scheduledStart =
        widget.shiftTime.split(' - ').isNotEmpty
            ? widget.shiftTime.split(' - ')[0]
            : '';

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _step == 0
                ? Icons.person
                : _step == 1
                ? Icons.access_time
                : Icons.check_circle,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _step == 0
                ? 'Manager Information'
                : _step == 1
                ? (widget.needsReason
                    ? (widget.signouttype == 'early'
                        ? 'Early Clock-Out'
                        : 'Late Clock-Out')
                    : 'Clock Out Confirmation')
                : 'Review & Submit',
          ),
        ],
      ),
      content: SingleChildScrollView(child: _buildStepContent(scheduledStart)),
      actions: _buildStepActions(),
    );
  }

  Widget _buildStepContent(String scheduledStart) {
    if (_step == 0) {
      // Manager info step
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please obtain the necessary signature from the staff or RN in charge.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name of Incharge / Authorized Person',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _designationController,
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
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _signatureController.clear(),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      );
    } else if (_step == 1) {
      // Clock-out step
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.needsReason
                ? 'You are clocking out ${widget.signouttype == 'early' ? 'before' : 'after'} your scheduled time.'
                : 'Are you sure you want to clock out?',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Break Time (minutes)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _breakTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., 30',
              prefixIcon: Icon(Icons.access_time),
            ),
          ),
          if (widget.needsReason) ...[
            const SizedBox(height: 16),
            Text(
              'Reason for ${widget.signouttype == 'early' ? 'Early' : 'Late'} Clock-Out',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your reason here...',
              ),
            ),
          ],
        ],
      );
    } else {
      // Review step
      final manager = _managerInfo!;
      final clockOut = _clockOutForm!;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review the details before submitting.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildReviewRow('Shift Time', widget.shiftTime),
          _buildReviewRow('Clock-In (scheduled)', scheduledStart),
          _buildReviewRow('Clock-Out', widget.outTime),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Manager Info',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildReviewRow('Name', manager.name),
          _buildReviewRow('Designation', manager.designation),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Clock-Out Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildReviewRow('Sign-out Type', widget.signouttype.toUpperCase()),
          _buildReviewRow('Break (minutes)', clockOut.breakTime),
          if (clockOut.reason != null && clockOut.reason!.isNotEmpty)
            _buildReviewRow('Reason', clockOut.reason!),
          const SizedBox(height: 8),
          const Text(
            'If you press Cancel, Manager Info and Clock-Out will not be saved.',
            style: TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
      );
    }
  }

  List<Widget> _buildStepActions() {
    if (_step == 0) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: _nextFromManagerStep,
          child: const Text('Next', style: TextStyle(color: Colors.white)),
        ),
      ];
    } else if (_step == 1) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
          child: const Text('Back'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _nextFromClockOutStep,
          child: const Text('Next', style: TextStyle(color: Colors.white)),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: _submit,
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ];
    }
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

/// =========================
/// SIMPLE DATA HOLDERS
/// =========================

class _ManagerInfoTemp {
  final String name;
  final String designation;
  final Uint8List signatureBytes;

  _ManagerInfoTemp({
    required this.name,
    required this.designation,
    required this.signatureBytes,
  });
}

class _ClockOutTemp {
  final String breakTime;
  final String? reason;

  _ClockOutTemp({required this.breakTime, this.reason});
}

class _ClockOutWizardResult {
  final _ManagerInfoTemp managerInfo;
  final _ClockOutTemp clockOutForm;

  _ClockOutWizardResult({
    required this.managerInfo,
    required this.clockOutForm,
  });
}
