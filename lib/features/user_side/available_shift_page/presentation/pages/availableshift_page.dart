import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/custom_shift_card.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_event.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_state.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/widget/Shiftcard_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // ✅ Added for time parsing

class AvailableshiftPage extends StatefulWidget {
  const AvailableshiftPage({super.key});

  @override
  State<AvailableshiftPage> createState() => _AvailableshiftPageState();
}

class _AvailableshiftPageState extends State<AvailableshiftPage> {
  String? selectedOrganization;
  List<String> allOrganizations = [];

  /// Local cache: which shift IDs are pending in this session
  /// (kept as requested, even if not used heavily now)
  final Set<int> _pendingShiftIds = {};

  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(FetchShifts());
  }

  void _showFilterDialog(BuildContext context, List<String> organizations) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? tempSelectedOrg = selectedOrganization;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, color: kWhite),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Filter by Organization',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kWhite,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: kWhite),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempSelectedOrg = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    tempSelectedOrg == null
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color:
                                        tempSelectedOrg == null
                                            ? primaryColor
                                            : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    tempSelectedOrg == null
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color:
                                        tempSelectedOrg == null
                                            ? primaryColor
                                            : Colors.grey,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'All Organizations',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            tempSelectedOrg == null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            tempSelectedOrg == null
                                                ? primaryColor
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (tempSelectedOrg == null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${organizations.length}',
                                        style: TextStyle(
                                          color: kWhite,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(thickness: 1),
                          ),
                          ...organizations.map((org) {
                            final isSelected = tempSelectedOrg == org;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  tempSelectedOrg = org;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryColor.withOpacity(0.1)
                                          : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color:
                                          isSelected
                                              ? primaryColor
                                              : Colors.transparent,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color:
                                          isSelected
                                              ? primaryColor
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        org,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedOrganization = tempSelectedOrg;
                              });
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: kWhite,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Filter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// =====================
  /// NEW: Local overlap check
  /// =====================

  Future<void> _handleClaimShiftLocally(
    BuildContext context,
    dynamic newShift,
    List<dynamic> allShifts,
  ) async {
    final overlapping = _findOverlappingClaimedShift(newShift, allShifts);

    if (overlapping != null) {
      // Show popup about already claimed shift
      _showAlreadyClaimedDialog(context, newShift, overlapping);
      return;
    }

    // No overlap → proceed as before
    context.read<ShiftBloc>().add(
      ClaimShift(newShift.id, newShift.date, newShift.time),
    );
  }

  _ShiftInterval? _getShiftInterval(dynamic shift) {
    if (shift.date == null || shift.date.toString().isEmpty) return null;
    if (shift.time == null || shift.time.toString().isEmpty) return null;

    final dateStr = shift.date.toString();
    final timeStr = shift.time.toString();
    final parts = timeStr.split(' - ');
    if (parts.length < 2) return null;

    final baseDate = _parseDate(dateStr);
    if (baseDate == null) return null;

    final startTime = _parseTime(parts[0].trim());
    final endTime = _parseTime(parts[1].trim());
    if (startTime == null || endTime == null) return null;

    final start = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      startTime.hour,
      startTime.minute,
      startTime.second,
    );

    var end = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      endTime.hour,
      endTime.minute,
      endTime.second,
    );

    // Handle overnight shifts: e.g. 22:00 -> 06:00 (next day)
    if (!endTime.isAfter(startTime)) {
      end = end.add(const Duration(days: 1));
    }

    return _ShiftInterval(start: start, end: end);
  }

  dynamic _findOverlappingClaimedShift(dynamic newShift, List<dynamic> all) {
    final newInterval = _getShiftInterval(newShift);
    if (newInterval == null) return null;

    for (final s in all) {
      if (s.id == newShift.id) continue;

      final status = s.status?.toString().toLowerCase() ?? '';

      // Consider accepted and pending as "already claimed"
      final bool isClaimed = status == 'accepted' || status == 'pending';

      if (!isClaimed) continue;

      final interval = _getShiftInterval(s);
      if (interval == null) continue;

      // Overlap check: A.start < B.end && B.start < A.end
      final bool overlaps =
          newInterval.start.isBefore(interval.end) &&
          interval.start.isBefore(newInterval.end);

      if (overlaps) {
        return s;
      }
    }

    return null;
  }

  void _showAlreadyClaimedDialog(
    BuildContext context,
    dynamic newShift,
    dynamic existingShift,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Already Claimed Shift',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You already have a shift that overlaps with this one:',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 12),
              _buildShiftInfoLine(
                label: 'Existing Shift',
                value:
                    '${existingShift.date} • ${existingShift.time} • ${existingShift.agencyName}',
              ),
              const SizedBox(height: 4),
              _buildShiftInfoLine(
                label: 'New Shift',
                value:
                    '${newShift.date} • ${newShift.time} • ${newShift.agencyName}',
              ),
              const SizedBox(height: 12),
              const Text(
                'Please choose a different shift that does not conflict with your existing schedule.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShiftInfoLine({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Expecting something like "2025-12-05"
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseTime(String timeStr) {
    // Try multiple common formats gracefully
    final List<String> formats = ['HH:mm:ss', 'HH:mm', 'hh:mm a', 'hh:mm:ss a'];

    for (final f in formats) {
      try {
        return DateFormat(f).parse(timeStr);
      } catch (_) {
        // ignore and try next
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          GestureDetector(
            onTap: () {
              context.read<ShiftBloc>().add(FetchShifts());
            },
            child:  Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.refresh, color: kWhite),
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (allOrganizations.isNotEmpty) {
                    _showFilterDialog(context, allOrganizations);
                  }
                },
                child:  Icon(Icons.filter_list, color: kWhite),
              ),
              if (selectedOrganization != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
        ],
        title: 'Available Shift',
        backgroundColor: primaryDarK,
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftClaimPending) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ShiftClaimSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ShiftClaimError) {
            // On error, clear local pending set if you want
            setState(() {
              _pendingShiftIds.clear();
            });

            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Shift Conflict',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (state is ShiftSessionExpired) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session expired. Please login again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return buildShiftCardShimmer(screenWidth, screenHeight);
              },
            );
          } else if (state is ShiftLoaded) {
            final organizations =
                state.shifts.map((shift) => shift.agencyName).toSet().toList()
                  ..sort();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  allOrganizations = organizations;
                });
              }
            });

            final filteredShifts =
                selectedOrganization == null
                    ? state.shifts
                    : state.shifts
                        .where(
                          (shift) => shift.agencyName == selectedOrganization,
                        )
                        .toList();

            if (state.shifts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No shifts available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (filteredShifts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      selectedOrganization != null
                          ? 'No shifts available for $selectedOrganization'
                          : 'No shifts available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    if (selectedOrganization != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedOrganization = null;
                          });
                        },
                        child: const Text('Clear Filter'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (selectedOrganization != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: primaryColor.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 20, color: primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtered by: $selectedOrganization',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedOrganization = null;
                            });
                          },
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredShifts.length,
                    itemBuilder: (context, index) {
                      final shift = filteredShifts[index];

                      final bool isPending =
                          shift.status.toLowerCase() == 'pending';
                      final bool isAccepted =
                          shift.status.toLowerCase() == 'accepted';

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ShiftCardWidget(
                          date: shift.date,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          duration: shift.duration,
                          time: shift.time,
                          agencyName: shift.agencyName,
                          notes: shift.notes,
                          location: shift.location,
                          isPending: isPending || isAccepted,
                          buttonText:
                              isAccepted
                                  ? 'Shift Accepted'
                                  : (isPending
                                      ? 'Shift Pending'
                                      : 'Claim Shift'),
                          onButtonPressed:
                              (isPending || isAccepted)
                                  ? null
                                  : () {
                                    // ✅ NEW: check local conflicts before dispatching ClaimShift
                                    _handleClaimShiftLocally(
                                      context,
                                      shift,
                                      state.shifts,
                                    );
                                  },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ShiftError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShiftBloc>().add(FetchShifts());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No Shift Available'));
        },
      ),
    );
  }
}

/// Helper to hold a shift’s time interval on the timeline
class _ShiftInterval {
  final DateTime start;
  final DateTime end;

  _ShiftInterval({required this.start, required this.end});
}
