import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/clockin_shiftcard.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ezaal/core/di/di.dart' as di;

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  String get todayDate => DateFormat('dd MMMM yyyy').format(DateTime.now());
  String get todayDay => DateFormat('EEEE').format(DateTime.now());
  int _pendingOperationsCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<SlotBloc>().add(LoadSlots());
    _loadPendingOperationsCount();
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

    // Show loading dialog
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
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh slots and pending count
        context.read<SlotBloc>().add(LoadSlots());
        await _loadPendingOperationsCount();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

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
                  return const Center(child: CircularProgressIndicator());
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
                            'You have no shifts scheduled for today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
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
                        inTimeStatus: slot.inTimeStatus,
                        outTimeStatus: slot.outTimeStatus,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onOperationQueued:
                            _loadPendingOperationsCount, // ✅ Pass callback
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
