import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/clockin_shiftcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  String get todayDate => DateFormat('dd MMMM yyyy').format(DateTime.now());
  String get todayDay => DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    context.read<SlotBloc>().add(LoadSlots());
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
        // leadingIcon: Icons.menu,
        // onLeadingPressed: () => scaffoldKey.currentState?.openDrawer(),
        backgroundColor: const Color(0xff0c2340),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<SlotBloc>().add(LoadSlots()),
          ),
        ],
      ),
      // drawer: CustomDrawer(),
      body: Column(
        children: [
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
                          onPressed:
                              () => context.read<SlotBloc>().add(LoadSlots()),
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
