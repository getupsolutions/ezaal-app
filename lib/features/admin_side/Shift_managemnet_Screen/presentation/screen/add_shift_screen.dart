import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditShiftScreen extends StatefulWidget {
  final ShiftItem? existingShift;

  /// initial date passed from ShiftManagmentscreen
  final DateTime? initialDate;

  const AddEditShiftScreen({Key? key, this.existingShift, this.initialDate})
    : super(key: key);

  @override
  State<AddEditShiftScreen> createState() => _AddEditShiftScreenState();
}

class _AddEditShiftScreenState extends State<AddEditShiftScreen> {
  // Data from masters
  List<OrganizationDto> _organizations = [];
  List<StaffTypeDto> _staffTypes = [];
  List<StaffDto> _staffList = [];
  List<DepartmentDto> _departments = [];

  int? _selectedOrgId;
  int? _selectedStaffTypeId;
  int? _selectedStaffId;
  int? _selectedDepartmentId; // ✅ send this (id) to backend

  late DateTime selectedDate;

  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController breakController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool _initializedSelections = false;

  @override
  void initState() {
    super.initState();

    // Use initialDate if provided, otherwise today
    selectedDate = widget.initialDate ?? DateTime.now();

    startTimeController.text = '07:00';
    endTimeController.text = '15:30';
    breakController.text = '30';

    if (widget.existingShift != null) {
      final s = widget.existingShift!;
      selectedDate = DateTime.tryParse(s.date) ?? selectedDate;

      final parts = s.time.split('-');
      if (parts.length == 2) {
        startTimeController.text = parts[0].trim();
        endTimeController.text = parts[1].trim();
      }

      breakController.text = '30';
      notesController.text = s.location;
      // department will be resolved in _initSelectedValuesFromMasters()
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShiftBloc>().add(const LoadShiftMastersEvent());
    });
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    breakController.dispose();
    notesController.dispose();
    super.dispose();
  }

  int _parseBreakMinutes() {
    final txt = breakController.text.trim();
    if (txt.isEmpty) return 0;
    final numeric = txt.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) return 0;
    return int.tryParse(numeric) ?? 0;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _initSelectedValuesFromMasters() {
    if (_initializedSelections) return;
    _initializedSelections = true;

    if (widget.existingShift != null) {
      final s = widget.existingShift!;

      // Organization by name
      if (_organizations.isNotEmpty) {
        final org = _organizations.firstWhere(
          (o) => o.name == s.organizationName,
          orElse: () => _organizations.first,
        );
        _selectedOrgId = org.id;
      }

      // Staff type – we don't have it on ShiftItem, so default first
      if (_staffTypes.isNotEmpty) {
        _selectedStaffTypeId = _staffTypes.first.id;
      }

      // Staff by name (if any)
      if (s.staffName.isNotEmpty && _staffList.isNotEmpty) {
        final st = _staffList.firstWhere(
          (u) => u.name == s.staffName,
          orElse: () => _staffList.first,
        );
        _selectedStaffId = st.id;
      }

      // Department: here we try match by department name if ShiftItem has it
      if (_departments.isNotEmpty && s.departmentName != null) {
        try {
          final dept = _departments.firstWhere(
            (d) => d.department == s.departmentName,
          );
          _selectedDepartmentId = dept.id;
        } catch (_) {
          _selectedDepartmentId = _departments.first.id;
        }
      } else if (_departments.isNotEmpty) {
        _selectedDepartmentId = _departments.first.id;
      }
    } else {
      // Defaults for "create new shift"
      _selectedOrgId =
          _organizations.isNotEmpty ? _organizations.first.id : null;
      _selectedStaffTypeId =
          _staffTypes.isNotEmpty ? _staffTypes.first.id : null;
      _selectedStaffId = null;
      _selectedDepartmentId =
          _departments.isNotEmpty ? _departments.first.id : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingShift != null;

    return BlocListener<AdminShiftBloc, AdminShiftState>(
      listener: (context, state) {
        if (state is AddEditShiftSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit
                    ? 'Shift updated successfully'
                    : 'Shift created (pending approval)',
              ),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is AddEditShiftFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryDarK,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            isEdit ? 'Edit Shift Request' : 'Add Shift Request',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;

              // Basic breakpoints
              final bool isMobile = screenWidth < 600;
              final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
              final bool isDesktop = screenWidth >= 1024;

              // Cap the content width on large screens and center it
              double maxContentWidth = screenWidth;
              if (isDesktop) {
                maxContentWidth = 900;
              } else if (isTablet) {
                maxContentWidth = 700;
              }

              return BlocBuilder<AdminShiftBloc, AdminShiftState>(
                builder: (context, state) {
                  if (state is ShiftMastersLoading ||
                      state is AdminShiftInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ShiftMastersError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Failed to load dropdown data:\n${state.message}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (state is ShiftMastersLoaded) {
                    _organizations = state.masters.organizations;
                    _staffTypes = state.masters.staffTypes;
                    _staffList = state.masters.staff;
                    _departments = state.masters.departments;

                    _initSelectedValuesFromMasters();

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _buildForm(
                          context: context,
                          isEdit: isEdit,
                          maxWidth: maxContentWidth,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),
                      ),
                    );
                  }

                  // Fallback: if masters already loaded earlier (e.g. orientation change)
                  if (_organizations.isNotEmpty) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _buildForm(
                          context: context,
                          isEdit: isEdit,
                          maxWidth: maxContentWidth,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          isDesktop: isDesktop,
                        ),
                      ),
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm({
    required BuildContext context,
    required bool isEdit,
    required double maxWidth,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final headerText =
        isEdit
            ? 'Modify request ${DateFormat('dd/MM/yyyy').format(selectedDate)}'
            : 'Create new shift ${DateFormat('dd/MM/yyyy').format(selectedDate)}';

    // Responsive paddings
    final double horizontalPadding = isMobile ? 16 : 24;
    final double verticalPadding = isMobile ? 16 : 24;

    // Responsive font sizes
    final double labelFontSize = isMobile ? 14 : 15;
    final double headerFontSize = isMobile ? 16 : 18;

    return Column(
      children: [
        // Yellow header bar
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          color: const Color(0xFFFFF9C4),
          child: Text(
            headerText,
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Scrollable form content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization
                buildLabel('Organization', fontSize: labelFontSize),
                _buildDropdown<int>(
                  value: _selectedOrgId,
                  items:
                      _organizations
                          .map(
                            (o) => DropdownMenuItem<int>(
                              value: o.id,
                              child: Text(o.name),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedOrgId = val),
                ),
                const SizedBox(height: 20),

                // Staff Type
                buildLabel('Staff Type', fontSize: labelFontSize),
                _buildDropdown<int>(
                  value: _selectedStaffTypeId,
                  items:
                      _staffTypes
                          .map(
                            (st) => DropdownMenuItem<int>(
                              value: st.id,
                              child: Text(st.designation),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _selectedStaffTypeId = val),
                ),
                const SizedBox(height: 20),

                // Date selector (optional but nice for responsiveness)
                // Row(
                //   children: [
                //     Expanded(
                //       child: buildLabel('Date', fontSize: labelFontSize),
                //     ),
                //     TextButton.icon(
                //       onPressed: _selectDate,
                //       icon: const Icon(Icons.calendar_today, size: 18),
                //       label: Text(
                //         DateFormat('dd/MM/yyyy').format(selectedDate),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 8),

                // Time row (responsive)
                LayoutBuilder(
                  builder: (context, timeConstraints) {
                    final isNarrow = maxWidth < 500;

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(
                            'Start Time (HH:mm)',
                            fontSize: labelFontSize,
                          ),
                          _buildTextField(startTimeController),
                          const SizedBox(height: 16),
                          buildLabel(
                            'End Time (HH:mm)',
                            fontSize: labelFontSize,
                          ),
                          _buildTextField(endTimeController),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(
                                'Start Time (HH:mm)',
                                fontSize: labelFontSize,
                              ),
                              _buildTextField(startTimeController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel(
                                'End Time (HH:mm)',
                                fontSize: labelFontSize,
                              ),
                              _buildTextField(endTimeController),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Break
                buildLabel('Break (minutes)', fontSize: labelFontSize),
                _buildTextField(breakController),
                const SizedBox(height: 20),

                // Department (id as value, name as label)
                buildLabel('Choose Department', fontSize: labelFontSize),
                _buildDropdown<int>(
                  value: _selectedDepartmentId,
                  items:
                      _departments
                          .map(
                            (d) => DropdownMenuItem<int>(
                              value: d.id,
                              child: Text(d.department),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _selectedDepartmentId = val),
                ),
                const SizedBox(height: 20),

                // Staff
                buildLabel('Select Staff', fontSize: labelFontSize),
                _buildDropdown<int?>(
                  value: _selectedStaffId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Staff not assigned'),
                    ),
                    ..._staffList.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedStaffId = val),
                ),
                const SizedBox(height: 20),

                // Notes / Location
                buildLabel('Notes / Location', fontSize: labelFontSize),
                _buildTextArea(controller: notesController),
                const SizedBox(height: 30),

                // Duplicate button (centered, responsive width)
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 280,
                    ),
                    child: SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton(
                        onPressed: () {
                          _onSubmitPressed(copies: 2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5A0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Duplicate this',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom buttons (Close / Submit)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, buttonConstraints) {
              final isNarrow = maxWidth < 500;

              if (isNarrow) {
                // Stack buttons vertically on very small screens
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AdminShiftBloc, AdminShiftState>(
                        builder: (context, state) {
                          final isLoading = state is AddEditShiftSubmitting;
                          return ElevatedButton(
                            onPressed: isLoading ? null : _onSubmitPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                    : Text(
                                      widget.existingShift != null
                                          ? 'Update'
                                          : 'Submit',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              // Side by side on wider screens
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BlocBuilder<AdminShiftBloc, AdminShiftState>(
                      builder: (context, state) {
                        final isLoading = state is AddEditShiftSubmitting;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onSubmitPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    widget.existingShift != null
                                        ? 'Update'
                                        : 'Submit',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _onSubmitPressed({int copies = 1}) {
    if (_selectedOrgId == null || _selectedStaffTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Organization and Staff Type'),
        ),
      );
      return;
    }

    final bloc = context.read<AdminShiftBloc>();

    final existingId = (copies == 1) ? widget.existingShift?.id : null;
    final breakMinutes = _parseBreakMinutes();

    bloc.add(
      SubmitShiftEvent(
        id: existingId,
        organizationId: _selectedOrgId!,
        staffTypeId: _selectedStaffTypeId!,
        date: selectedDate,
        fromTime: startTimeController.text.trim(),
        toTime: endTimeController.text.trim(),
        notes: notesController.text.trim(),
        breakMinutes: breakMinutes,
        staffId: _selectedStaffId,
        departmentId: _selectedDepartmentId,
        copies: copies,
      ),
    );
  }

  Widget buildLabel(String text, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTextArea({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
