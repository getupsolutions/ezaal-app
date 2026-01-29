// features/admin_side/Shift_managemnet_Screen/presentation/screen/shift_view_page.dart

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/show_dialog.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/edit_clockin_out_page.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/view_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ShiftViewPage extends StatelessWidget {
  final ShiftItem shift;

  const ShiftViewPage({super.key, required this.shift});

  // ----------------- helpers -----------------

  DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      // day/month/year
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  String _formatShortDateTime(String? raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return '-';
    // day/month/year + time
    return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
  }

  String _formatOnlyTime(String? raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return '-';
    return DateFormat('HH:mm').format(dt);
  }

  String _mapClockType(String? type) {
    if (type == null || type.isEmpty) return '-';
    if (type.toLowerCase() == 'ontime') return 'Online';
    return type;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _calculateTotalWorked(ShiftItem s) {
    final inDt = _parseDateTime(s.signIn);
    final outDt = _parseDateTime(s.signOut);
    if (inDt == null || outDt == null) return '-';

    var diff = outDt.difference(inDt);

    final breakMin = int.tryParse(s.breakMinutes) ?? 0;
    if (breakMin > 0) {
      diff -= Duration(minutes: breakMin);
    }

    if (diff.isNegative) return '-';

    return _formatDuration(diff);
  }

  // Find updated ShiftItem from bloc state by id
  ShiftItem? _getShiftFromState(AdminShiftState state) {
    List<ShiftItem>? list;

    if (state is AdminShiftLoaded) {
      list = state.shifts;
    } else if (state is AdminShiftActionSuccess) {
      list = state.shifts;
    } else if (state is AdminShiftApprovedSuccessfully) {
      list = state.shifts;
    }

    if (list == null) return null;

    for (final s in list) {
      if (s.id == shift.id) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminShiftBloc, AdminShiftState>(
      listener: (context, state) {
        if (state is AdminShiftActionSuccess) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars(); // ✅ clear previous
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.message, style: TextStyle(color: kWhite)),
              backgroundColor: state.snackColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is AdminShiftError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // 👇 use updated shift from bloc if available, else fallback
        final currentShift = _getShiftFromState(state) ?? shift;

        final theme = Theme.of(context);
        final totalHoursWorked = _calculateTotalWorked(currentShift);

        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isTablet = screenWidth >= 600 && screenWidth < 1024;
                final isDesktop = screenWidth >= 1024;

                double fontScale(double base) {
                  if (isDesktop) return base * 1.25;
                  if (isTablet) return base * 1.1;
                  return base;
                }

                final maxContentWidth =
                    screenWidth > 900
                        ? 900.0
                        : screenWidth; // center on big screens

                return Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top bar: title + close
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'View request',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontSize: fontScale(
                                            theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.fontSize ??
                                                18,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Header date / org / designation
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(currentShift.date),
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontSize: fontScale(
                                                  theme
                                                          .textTheme
                                                          .titleLarge
                                                          ?.fontSize ??
                                                      22,
                                                ),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentShift.time,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: fontScale(
                                                  theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.fontSize ??
                                                      14,
                                                ),
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currentShift.organizationName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontSize: fontScale(
                                                theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.fontSize ??
                                                    14,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        currentShift.departmentName ?? '',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontSize: fontScale(
                                                theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.fontSize ??
                                                    12,
                                              ),
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Info rows
                              InfoRow(
                                icon: Icons.timer_outlined,
                                label: 'Break',
                                value: '${currentShift.breakMinutes} Minutes',
                              ),
                              const SizedBox(height: 4),

                              // ✅ NEW: Display Staff Type Designation
                              if (currentShift.staffTypeDesignation.isNotEmpty)
                                InfoRow(
                                  icon: Icons.work_outline,
                                  label: 'Position',
                                  value: currentShift.staffTypeDesignation,
                                  highlight: true,
                                ),
                              if (currentShift.staffTypeDesignation.isNotEmpty)
                                const SizedBox(height: 4),

                              InfoRow(
                                icon: Icons.person_outline,
                                label: 'Staff',
                                value:
                                    currentShift.staffName.isEmpty
                                        ? 'Unassigned'
                                        : currentShift.staffName,
                                highlight: true,
                              ),
                              const SizedBox(height: 4),
                              InfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: currentShift.location,
                              ),
                              const SizedBox(height: 4),
                              // ✅ NEW: Clock-in Location

                              const SizedBox(height: 4),
                   InfoRow(
                                icon: Icons.check_circle_outline,
                                label: 'Accepted date',
                                value:
                                    '${_formatShortDateTime(currentShift.staffRequestDate)} ${currentShift.staffRequestName ?? ''}',
                                highlight: true,
                              ),

                              const SizedBox(height: 4),

                              InfoRow(
                                icon: Icons.place_outlined,
                                label: 'Clock-in Location',
                                value:
                                    (currentShift.userClockinLocation == null ||
                                            currentShift
                                                .userClockinLocation!
                                                .isEmpty)
                                        ? 'No location added'
                                        : currentShift.clockinLocationDisplay,
                                highlight: true,
                              ),


                              const SizedBox(height: 12),

                              // Notes
                              if (currentShift.notes != null &&
                                  currentShift.notes.isNotEmpty)
                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: fontScale(
                                        theme.textTheme.bodyMedium?.fontSize ??
                                            14,
                                      ),
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Notes: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: currentShift.notes),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  'Notes: -',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: fontScale(
                                      theme.textTheme.bodyMedium?.fontSize ??
                                          14,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Clock in/out section (table style)
                              _buildClockTable(
                                context,
                                fontScale: fontScale,
                                currentShift: currentShift,
                              ),

                              const SizedBox(height: 16),

                              // Authorised person details
                              Text(
                                'Authorised Person details:',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: fontScale(
                                    theme.textTheme.titleMedium?.fontSize ?? 18,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),

                              DetailsTable(
                                rows: [
                                  DetailRowData(
                                    title: 'Name',
                                    value: currentShift.managerName ?? '-',
                                  ),
                                  DetailRowData(
                                    title: 'Designation',
                                    value:
                                        currentShift.managerDesignation ?? '-',
                                  ),
                                  DetailRowData(
                                    title: 'Break Taken',
                                    value:
                                        '${currentShift.breakMinutes} Minutes',
                                  ),
                                  DetailRowData(
                                    title: 'Department',
                                    value: currentShift.departmentName ?? '-',
                                  ),
                                  DetailRowData(
                                    title: 'Total hours worked',
                                    value: totalHoursWorked,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Bottom buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => EditAttendanceDialog(
                                                shift: currentShift,
                                              ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.edit),
                                      label: const Text(
                                        'Modify Clockin/Clockout timings',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final shiftBloc =
                                            context.read<AdminShiftBloc>();
                                        // backend uses 'confirmed'
                                        final isCurrentlyApproved =
                                            currentShift.status == 'confirmed';

                                        final confirmed =
                                            await CupertinoConfirmDialog.show(
                                              context: context,
                                              title:
                                                  isCurrentlyApproved
                                                      ? "Unapprove Shift ?"
                                                      : "Approve Shift ?",
                                              message:
                                                  isCurrentlyApproved
                                                      ? "Are you sure you want to UnApprove this Shift"
                                                      : "Are you sure you want to Approve this Shift",
                                              confirmText:
                                                  isCurrentlyApproved
                                                      ? "Unapprove"
                                                      : "Approve",
                                              cancelText: "Cancel",
                                              isDestructive:
                                                  isCurrentlyApproved,
                                              contentWidget:
                                                  _shiftConfirmDetails(
                                                    currentShift,
                                                  ),
                                            );
                                        if (!confirmed) return;
                                        shiftBloc.add(
                                          ToggleShiftApprovalEvent(
                                            shiftId: currentShift.id,
                                            approve: !isCurrentlyApproved,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        currentShift.status == 'confirmed'
                                            ? Icons.close
                                            : Icons.check,
                                      ),
                                      label: Text(
                                        currentShift.status == 'confirmed'
                                            ? 'Unapprove Shift'
                                            : 'Approve Shift',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _shiftConfirmDetails(ShiftItem s) {
    String safe(String? v) => (v == null || v.isEmpty) ? '-' : v;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dialogLine("Date", _formatDate(s.date)),
          _dialogLine("Time", safe(s.time)),
          // ✅ NEW: Show staff type designation in confirmation dialog
          if (s.staffTypeDesignation.isNotEmpty)
            _dialogLine("Position", s.staffTypeDesignation),
          _dialogLine(
            "Staff",
            s.staffName.isEmpty ? "Unassigned" : s.staffName,
          ),
          _dialogLine("Location", safe(s.location)),
          _dialogLine("Break", "${safe(s.breakMinutes)} min"),
          const SizedBox(height: 6),
          _dialogLine(
            "Clock In",
            "${_formatOnlyTime(s.signIn)} (${_mapClockType(s.signInType)})",
          ),
          _dialogLine(
            "Clock Out",
            "${_formatOnlyTime(s.signOut)} (${_mapClockType(s.signOutType)})",
          ),
        ],
      ),
    );
  }

  Widget _dialogLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildClockTable(
    BuildContext context, {
    required double Function(double) fontScale,
    required ShiftItem currentShift,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                const SizedBox(width: 80), // left empty cell
                Expanded(
                  child: Text(
                    'Clock in Details',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontScale(
                        theme.textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Clock out Details',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontScale(
                        theme.textTheme.bodyMedium?.fontSize ?? 14,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time row
          ClockRow(
            title: 'Time',
            clockIn: _formatOnlyTime(currentShift.signIn),
            clockOut: _formatOnlyTime(currentShift.signOut),
            clockInType: _mapClockType(currentShift.signInType),
            clockOutType: _mapClockType(currentShift.signOutType),
          ),

          // Notes row
          ClockRow(
            title: 'Notes',
            clockIn: currentShift.signInReason ?? '-',
            clockOut: currentShift.signOutReason ?? '-',
            showChip: false,
          ),
        ],
      ),
    );
  }
}
