// presentation/widget/shift_filter_dialog.dart
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
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

  ShiftMastersDto? _masters;

  static const String _allOrgLabel = 'All Organization';
  static const String _allStaffTypeLabel = 'All Staff Type';
  static const String _allStaffLabel = 'All Staff';
  static const String _allDeptLabel = 'All Department';

  @override
  void initState() {
    super.initState();
    context.read<AdminShiftBloc>().add(LoadShiftMastersEvent());
  }

  List<String> get _organizationOptions {
    if (_masters == null) return const [_allOrgLabel];
    return [_allOrgLabel, ..._masters!.organizations.map((e) => e.name)];
  }

  List<String> get _staffTypeOptions {
    if (_masters == null) return const [_allStaffTypeLabel];
    return [
      _allStaffTypeLabel,
      ..._masters!.staffTypes.map((e) => e.designation),
    ];
  }

  List<String> get _staffOptions {
    if (_masters == null) return const [_allStaffLabel];
    return [_allStaffLabel, ..._masters!.staff.map((e) => e.name)];
  }

  List<String> get _departmentOptions {
    if (_masters == null) return const [_allDeptLabel];
    return [_allDeptLabel, ..._masters!.departments.map((e) => e.department)];
  }

  final List<String> rosterTypes = const [
    'Weekly Roster',
    'Monthly Roster',
    'Daily Roster',
  ];

  final List<String> statusList = const [
    'Approved/UnAp',
    'Approved',
    'Unapproved',
    'Pending',
  ];

  String? _mapStatusLabelToApi(String label) {
    switch (label) {
      case 'Approved':
        return 'confirmed';
      case 'Unapproved':
        return 'un-confirm';
      default:
        return null; // Approved/UnAp, Pending -> no status filter
    }
  }

  int? _getOrganizationIdByName(String name) {
    if (_masters == null || name == _allOrgLabel) return null;
    for (final org in _masters!.organizations) {
      if (org.name == name) return org.id;
    }
    return null;
  }

  int? _getStaffTypeIdByName(String name) {
    if (_masters == null || name == _allStaffTypeLabel) return null;
    for (final s in _masters!.staffTypes) {
      if (s.designation == name) return s.id;
    }
    return null;
  }

  int? _getStaffIdByName(String name) {
    if (_masters == null || name == _allStaffLabel) return null;
    for (final s in _masters!.staff) {
      if (s.name == name) return s.id;
    }
    return null;
  }

  int? _getDepartmentIdByName(String name) {
    if (_masters == null || name == _allDeptLabel) return null;
    for (final d in _masters!.departments) {
      if (d.department == name) return d.id;
    }
    return null;
  }

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

  void _onApplyFilter() {
    final range =
        selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 6)),
        );

    final int? organizationId = _getOrganizationIdByName(selectedOrganization);
    final int? staffId = _getStaffIdByName(selectedStaff);
    final int? staffTypeId = _getStaffTypeIdByName(selectedStaffType);
    final int? departmentId = _getDepartmentIdByName(selectedDepartment);

    String? statusApi = _mapStatusLabelToApi(selectedStatus);

    // 🔴 If "Show Cancelled Shift" is picked → show only cancelled shifts
    if (showCancelledShift) {
      statusApi = 'cancelled';
    }

    context.read<AdminShiftBloc>().add(
      LoadAdminShiftsForWeek(
        weekStart: range.start,
        weekEnd: range.end,
        organizationId: organizationId,
        staffId: staffId,
        status: statusApi,
        staffTypeId: staffTypeId,
        departmentId: departmentId,
      ),
    );

    Navigator.pop(context);
  }

  void _onClearAll() {
    setState(() {
      selectedDateRange = null;
      selectedOrganization = _allOrgLabel;
      selectedStaffType = _allStaffTypeLabel;
      selectedStaff = _allStaffLabel;
      selectedDepartment = _allDeptLabel;
      selectedRosterType = 'Weekly Roster';
      selectedStatus = 'Approved/UnAp';
      showCancelledShift = false;
    });
  }

  void _onSendStaffConfirmedMail() {
    final range =
        selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 6)),
        );

    final int? organizationId = _getOrganizationIdByName(selectedOrganization);
    final int? staffId = _getStaffIdByName(selectedStaff);

    context.read<AdminShiftBloc>().add(
      ApprovePendingShiftClaimsEvent(
        startDate: range.start,
        endDate: range.end,
        organizationId: organizationId,
        staffId: staffId,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
          final maxHeight = constraints.maxHeight * 0.9;

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

                Flexible(
                  child: BlocBuilder<AdminShiftBloc, AdminShiftState>(
                    builder: (context, state) {
                      if (state is ShiftMastersLoading && _masters == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is ShiftMastersLoaded) {
                        _masters = state.masters;
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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

                            // Organization & Staff Type
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Organization'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedOrganization,
                                        _organizationOptions,
                                        (value) => setState(
                                          () =>
                                              selectedOrganization =
                                                  value ?? _allOrgLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Staff Type'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedStaffType,
                                        _staffTypeOptions,
                                        (value) => setState(
                                          () =>
                                              selectedStaffType =
                                                  value ?? _allStaffTypeLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Staff & Department
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Staff'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedStaff,
                                        _staffOptions,
                                        (value) => setState(
                                          () =>
                                              selectedStaff =
                                                  value ?? _allStaffLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Department'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedDepartment,
                                        _departmentOptions,
                                        (value) => setState(
                                          () =>
                                              selectedDepartment =
                                                  value ?? _allDeptLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Roster Type & Status
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Roster Type'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedRosterType,
                                        rosterTypes,
                                        (value) => setState(
                                          () =>
                                              selectedRosterType =
                                                  value ?? 'Weekly Roster',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel('Status'),
                                      const SizedBox(height: 8),
                                      _buildDropdown(
                                        selectedStatus,
                                        statusList,
                                        (value) => setState(
                                          () =>
                                              selectedStatus =
                                                  value ?? 'Approved/UnAp',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Show Cancelled Shift
                            Row(
                              children: [
                                Checkbox(
                                  value: showCancelledShift,
                                  onChanged: (val) {
                                    setState(
                                      () => showCancelledShift = val ?? false,
                                    );
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

                            _buildActionButton(
                              'Apply Filter',
                              const Color(0xFF00BCD4),
                              _onApplyFilter,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Clear All',
                              const Color(0xFF1E3A5F),
                              _onClearAll,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Send Organization Mail',
                              const Color(0xFF00E676),
                              () {
                                // TODO
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Send Staff Confirmed mail',
                              const Color(0xFFFFEB3B),
                              _onSendStaffConfirmedMail,
                              textColor: Colors.black87,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Send Staff Available Shift Mail',
                              const Color(0xFF03A9F4),
                              () {
                                // TODO
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final String safeValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
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

void showOrganizationRosterFilter(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const OrganizationRosterFilterDialog(),
  );
}
