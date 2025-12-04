import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OrganizationRosterFilterDialog extends StatefulWidget {
  const OrganizationRosterFilterDialog({super.key});

  @override
  State<OrganizationRosterFilterDialog> createState() =>
      _OrganizationRosterFilterDialogState();
}

class _OrganizationRosterFilterDialogState
    extends State<OrganizationRosterFilterDialog> {
  DateTimeRange? selectedDateRange;
  String selectedOrganization = 'All Organization';
  String selectedStaffType = 'All Staff Type';
  String selectedStaff = 'All Staff';
  String selectedDepartment = 'All Department';
  String selectedRosterType = 'Weekly Roster';
  String selectedStatus = 'Approved/UnAp';
  bool showCancelledShift = false;

  final List<String> organizations = [
    'All Organization',
    'Organization 1',
    'Organization 2',
    'Organization 3',
  ];
  final List<String> staffTypes = [
    'All Staff Type',
    'Full Time',
    'Part Time',
    'Casual',
  ];
  final List<String> staffList = ['All Staff', 'Staff 1', 'Staff 2', 'Staff 3'];
  final List<String> departments = [
    'All Department',
    'Department 1',
    'Department 2',
    'Department 3',
  ];
  final List<String> rosterTypes = [
    'Weekly Roster',
    'Monthly Roster',
    'Daily Roster',
  ];
  final List<String> statusList = [
    'Approved/UnAp',
    'Approved',
    'Unapproved',
    'Pending',
  ];

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange:
          selectedDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 6)),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A5F),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  String _getDateRangeText() {
    if (selectedDateRange == null) {
      final now = DateTime.now();
      final weekEnd = now.add(const Duration(days: 6));
      return '${DateFormat('dd-MM-yyyy').format(now)} - ${DateFormat('dd-MM-yyyy').format(weekEnd)}';
    }
    return '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} - '
        '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';
  }

  int? _mapOrganizationNameToId(String orgName) {
    if (orgName == 'All Organization') return null;
    // TODO: use actual list with id & name from backend
    return null;
  }

  int? _mapStaffNameToId(String staffName) {
    if (staffName == 'All Staff') return null;
    // TODO: map to real staff id
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // makes dialog respect small screens (no overflow at edges)
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Cap width for tablets / web so dialog doesn't become too wide
          final maxWidth =
              constraints.maxWidth > 600
                  ? 600.0
                  : constraints.maxWidth; // up to 600px
          final maxHeight = constraints.maxHeight * 0.9; // leave some margin

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Organization Roster',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Range
                        _buildLabel('Date Range'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDateRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _getDateRangeText(),
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Organization and Staff Type Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Organization'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedOrganization,
                                    organizations,
                                    (value) => setState(
                                      () => selectedOrganization = value!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Staff Type'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedStaffType,
                                    staffTypes,
                                    (value) => setState(
                                      () => selectedStaffType = value!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Staff and Department Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Staff'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedStaff,
                                    staffList,
                                    (value) =>
                                        setState(() => selectedStaff = value!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Department'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedDepartment,
                                    departments,
                                    (value) => setState(
                                      () => selectedDepartment = value!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Roster Type and Status Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Roster Type'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedRosterType,
                                    rosterTypes,
                                    (value) => setState(
                                      () => selectedRosterType = value!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Status'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    selectedStatus,
                                    statusList,
                                    (value) =>
                                        setState(() => selectedStatus = value!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Show Cancelled Shift Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: showCancelledShift,
                              onChanged: (value) {
                                setState(() {
                                  showCancelledShift = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF1E3A5F),
                            ),
                            const Flexible(
                              child: Text(
                                'Show Cancelled Shift',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        _buildActionButton(
                          'Apply Filter',
                          const Color(0xFF00BCD4),
                          () {
                            // Apply filter logic if needed
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Clear All',
                          const Color(0xFF1E3A5F),
                          () {
                            setState(() {
                              selectedDateRange = null;
                              selectedOrganization = 'All Organization';
                              selectedStaffType = 'All Staff Type';
                              selectedStaff = 'All Staff';
                              selectedDepartment = 'All Department';
                              selectedRosterType = 'Weekly Roster';
                              selectedStatus = 'Approved/UnAp';
                              showCancelledShift = false;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Send Organization Mail',
                          const Color(0xFF00E676),
                          () {
                            // TODO: Send organization mail logic
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Send Staff Confirmed mail',
                          const Color(0xFFFFEB3B),
                          () {
                            final int? organizationId =
                                _mapOrganizationNameToId(selectedOrganization);
                            final int? staffId = _mapStaffNameToId(
                              selectedStaff,
                            );

                            final DateTime? startDate =
                                selectedDateRange?.start;
                            final DateTime? endDate = selectedDateRange?.end;

                            context.read<AdminShiftBloc>().add(
                              ApprovePendingShiftClaimsEvent(
                                startDate: startDate,
                                endDate: endDate,
                                organizationId: organizationId,
                                staffId: staffId,
                              ),
                            );

                            Navigator.pop(context);
                          },
                          textColor: Colors.black87,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Send Staff Available Shift Mail',
                          const Color(0xFF03A9F4),
                          () {
                            // TODO: Send staff available shift mail logic
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items:
              items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Function to show the dialog
void showOrganizationRosterFilter(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const OrganizationRosterFilterDialog();
    },
  );
}
