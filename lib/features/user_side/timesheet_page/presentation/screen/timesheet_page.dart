// File: lib/features/user_side/timesheet/presentation/pages/timesheet_page.dart

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/custom_drawer.dart';
import 'package:ezaal/core/widgets/shimmer.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/widget/date_filter_dialog.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/widget/shimmer_widget.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/widget/timesheet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/timesheet_bloc.dart';
import '../bloc/timesheet_event.dart';
import '../bloc/timesheet_state.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({super.key});

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  @override
  void initState() {
    super.initState();
    context.read<TimesheetBloc>().add(LoadTimesheet());
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => DateFilterDialog(
            onApplyFilter: (startDate, endDate) {
              context.read<TimesheetBloc>().add(
                FilterTimesheetByDate(startDate: startDate, endDate: endDate),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        backgroundColor: primaryDarK,
        title: "TimeSheet",
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showDateFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<TimesheetBloc>().add(ClearTimesheetFilter());
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: BlocBuilder<TimesheetBloc, TimesheetState>(
        builder: (context, state) {
          if (state is TimesheetLoading) {
            // Show shimmer loading effect
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return buildTimesheetCardShimmer(screenWidth);
              },
            );
          } else if (state is TimesheetLoaded) {
            if (state.timesheets.isEmpty) {
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
                      'No timesheet records found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.startDate != null && state.endDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your date filter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter Info Bar
                if (state.startDate != null && state.endDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtered: ${_formatDate(state.startDate!)} - ${_formatDate(state.endDate!)}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          onPressed: () {
                            context.read<TimesheetBloc>().add(
                              ClearTimesheetFilter(),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                // Timesheet List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.timesheets.length,
                    itemBuilder: (context, index) {
                      final timesheet = state.timesheets[index];
                      return TimesheetCard(timesheet: timesheet);
                    },
                  ),
                ),
              ],
            );
          } else if (state is TimesheetError) {
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
                    'Error loading timesheet',
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
                      context.read<TimesheetBloc>().add(LoadTimesheet());
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
          return const Center(child: Text('No timesheet data'));
        },
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }
}
