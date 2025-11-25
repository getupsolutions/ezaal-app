import 'package:flutter/material.dart';
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
            end: DateTime.now().add(Duration(days: 6)),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      final weekEnd = now.add(Duration(days: 6));
      return '${DateFormat('dd-MM-yyyy').format(now)} - ${DateFormat('dd-MM-yyyy').format(weekEnd)}';
    }
    return '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: screenWidth * 0.9,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E3A5F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Organization Roster',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    _buildLabel('Date Range'),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: EdgeInsets.symmetric(
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
                            Text(
                              _getDateRangeText(),
                              style: TextStyle(fontSize: 14),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Organization and Staff Type Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Organization'),
                              SizedBox(height: 8),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Staff Type'),
                              SizedBox(height: 8),
                              _buildDropdown(
                                selectedStaffType,
                                staffTypes,
                                (value) =>
                                    setState(() => selectedStaffType = value!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Staff and Department Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Staff'),
                              SizedBox(height: 8),
                              _buildDropdown(
                                selectedStaff,
                                staffList,
                                (value) =>
                                    setState(() => selectedStaff = value!),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Department'),
                              SizedBox(height: 8),
                              _buildDropdown(
                                selectedDepartment,
                                departments,
                                (value) =>
                                    setState(() => selectedDepartment = value!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Roster Type and Status Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Roster Type'),
                              SizedBox(height: 8),
                              _buildDropdown(
                                selectedRosterType,
                                rosterTypes,
                                (value) =>
                                    setState(() => selectedRosterType = value!),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Status'),
                              SizedBox(height: 8),
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
                    SizedBox(height: 16),

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
                          activeColor: Color(0xFF1E3A5F),
                        ),
                        Text(
                          'Show Cancelled Shift',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButton('Apply Filter', Color(0xFF00BCD4), () {
                      // Apply filter logic
                      Navigator.pop(context);
                    }),
                    SizedBox(height: 12),
                    _buildActionButton('Clear All', Color(0xFF1E3A5F), () {
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
                    }),
                    SizedBox(height: 12),
                    _buildActionButton(
                      'Send Organization Mail',
                      Color(0xFF00E676),
                      () {
                        // Send organization mail logic
                      },
                    ),
                    SizedBox(height: 12),
                    _buildActionButton(
                      'Send Staff Confirmed mail',
                      Color(0xFFFFEB3B),
                      () {
                        // Send staff confirmed mail logic
                      },
                      textColor: Colors.black87,
                    ),
                    SizedBox(height: 12),
                    _buildActionButton(
                      'Send Staff Available Shift Mail',
                      Color(0xFF03A9F4),
                      () {
                        // Send staff available shift mail logic
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 20),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
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
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
      return OrganizationRosterFilterDialog();
    },
  );
}
