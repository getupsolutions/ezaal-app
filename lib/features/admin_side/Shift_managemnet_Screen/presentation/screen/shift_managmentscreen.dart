import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/add_shift_screen.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/shift_view_page.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/shift_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ShiftManagmentscreen extends StatefulWidget {
  const ShiftManagmentscreen({super.key});

  @override
  State<ShiftManagmentscreen> createState() => _ShiftManagmentscreenState();
}

class _ShiftManagmentscreenState extends State<ShiftManagmentscreen> {
  DateTime selectedWeekStart = DateTime.now();
  int selectedDayIndex = 0;

  // ⭐ NEW: cache last loaded shifts so UI can still show them
  AdminShiftLoaded? _cachedShiftState;

  String _formatShiftDate(String raw) {
    try {
      final d = DateTime.parse(raw); // server gives yyyy-MM-dd
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return raw; // fallback if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();

    // Week starts on Monday
    selectedWeekStart = _getWeekStart(today);

    // 0 = Monday, 6 = Sunday
    selectedDayIndex = today.difference(selectedWeekStart).inDays.clamp(0, 6);

    _loadWeek();
  }

  void _loadWeek() {
    final weekEnd = selectedWeekStart.add(const Duration(days: 6));
    context.read<AdminShiftBloc>().add(
      LoadAdminShiftsForWeek(weekStart: selectedWeekStart, weekEnd: weekEnd),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _getWeekDays() {
    return List.generate(
      7,
      (index) => selectedWeekStart.add(Duration(days: index)),
    );
  }

  void _previousWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.subtract(const Duration(days: 7));
      selectedDayIndex = 0;
    });
    _loadWeek();
  }

  void _nextWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.add(const Duration(days: 7));
      selectedDayIndex = 0;
    });
    _loadWeek();
  }

  String _getWeekRangeText() {
    final weekEnd = selectedWeekStart.add(const Duration(days: 6));
    return '${DateFormat('dd/MM/yyyy').format(selectedWeekStart)} - '
        '${DateFormat('dd/MM/yyyy').format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Shift management',
        backgroundColor: primaryDarK,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: kWhite),
            onPressed: () {
              showOrganizationRosterFilter(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            // Center content and keep a nice readable width on large screens
            final contentWidth = screenWidth > 900 ? 900.0 : screenWidth;

            final isTablet = screenWidth >= 600 && screenWidth < 1024;
            final isDesktop = screenWidth >= 1024;

            double _fontScale(double base) {
              if (isDesktop) return base * 1.2;
              if (isTablet) return base * 1.1;
              return base;
            }

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  children: [
                    buildWeekSelector(contentWidth, screenHeight, _fontScale),
                    buildDayTabs(contentWidth, screenHeight, _fontScale),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocConsumer<AdminShiftBloc, AdminShiftState>(
                        listener: (context, state) {
                          if (state is AdminShiftApprovedSuccessfully) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Staff confirmed mail sent and shifts approved successfully.',
                                ),
                              ),
                            );
                          } else if (state is AdminShiftActionSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          } else if (state is AdminShiftError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          // 🔥 When Add/Edit shift succeeds, reload current week
                          else if (state is AddEditShiftSuccess) {
                            _loadWeek();
                          }

                          // ⭐ NEW: whenever we get a loaded state, cache it
                          if (state is AdminShiftLoaded) {
                            _cachedShiftState = state;
                          }
                        },
                        builder: (context, state) {
                          // 1) Handle hard error first
                          if (state is AdminShiftError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: _fontScale(14),
                                  ),
                                ),
                              ),
                            );
                          }

                          // 2) Decide which state to use for displaying shifts
                          AdminShiftLoaded? displayState;
                          if (state is AdminShiftLoaded) {
                            displayState = state;
                          } else {
                            // When state is ShiftMasters*, AddEdit*, etc,
                            // fall back to the last known good shift list
                            displayState = _cachedShiftState;
                          }

                          // 3) If we are loading AND we have nothing cached yet → pure loader
                          if ((state is AdminShiftLoading ||
                                  state is AdminShiftInitial) &&
                              displayState == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // 4) If we still have no displayState, show loader
                          if (displayState == null) {
                            // e.g. app just started and nothing loaded yet
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // 5) We have a displayState with shifts, render UI
                          final selectedDate = _getWeekDays()[selectedDayIndex];
                          final selectedDayStr = DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate);

                          final dayShifts =
                              displayState.shifts
                                  .where((s) => s.date == selectedDayStr)
                                  .toList();

                          if (dayShifts.isEmpty) {
                            return Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'No shifts for this day',
                                      style: TextStyle(
                                        fontSize: _fontScale(14),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                buildAddShiftButton(
                                  contentWidth,
                                  screenHeight,
                                  _fontScale,
                                ),
                              ],
                            );
                          }

                          return _buildShiftsList(
                            contentWidth,
                            screenHeight,
                            dayShifts,
                            _fontScale,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget buildWeekSelector(
    double width,
    double height,
    double Function(double) fontScale,
  ) {
    return Container(
      margin: EdgeInsets.all(width * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: primaryDarK,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: kWhite),
            onPressed: _previousWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Flexible(
            child: Text(
              _getWeekRangeText(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kWhite,
                fontSize: fontScale(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: kWhite),
            onPressed: _nextWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget buildDayTabs(
    double width,
    double height,
    double Function(double) fontScale,
  ) {
    final weekDays = _getWeekDays();
    final tabHeight = height * 0.1;
    final clampedTabHeight = tabHeight.clamp(64.0, 90.0);

    return Container(
      height: clampedTabHeight,
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final isSelected = selectedDayIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDayIndex = index;
              });
            },
            child: Container(
              width: width * 0.18,
              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : primaryDarK,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                      color: kWhite,
                      fontSize: fontScale(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(day),
                    style: TextStyle(
                      color: kWhite,
                      fontSize: fontScale(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftsList(
    double width,
    double height,
    List<ShiftItem> shifts,
    double Function(double) fontScale,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(width * 0.02),
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width),
                  child: buildShiftCard(
                    shifts[index],
                    width,
                    height,
                    fontScale,
                  ),
                ),
              );
            },
          ),
        ),
        buildAddShiftButton(width, height, fontScale),
      ],
    );
  }

  Widget buildShiftCard(
    ShiftItem shift,
    double width,
    double height,
    double Function(double) fontScale,
  ) {
    final hasStaff = shift.staffName.isNotEmpty;
    final isCompleted = shift.hasClockInOut;

    return Container(
      margin: EdgeInsets.only(bottom: height * 0.015),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            decoration: BoxDecoration(
              color: primaryDarK,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: fontScale(11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: fontScale(11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Location + date
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.008,
            ),
            decoration: BoxDecoration(
              color: primaryDarK.withOpacity(0.9),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shift.location,
                    style: TextStyle(
                      color: kWhite,
                      fontSize: fontScale(13),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatShiftDate(shift.date),
                  style: TextStyle(
                    color: kWhite,
                    fontSize: fontScale(13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // left info
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.time,
                        style: TextStyle(
                          fontSize: fontScale(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasStaff ? shift.staffName : '',
                        style: TextStyle(
                          fontSize: fontScale(13),
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shift.status,
                        style: TextStyle(
                          fontSize: fontScale(11),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // right actions
                Flexible(
                  flex: 2,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: _buildActionButtons(
                      shift: shift,
                      hasStaff: hasStaff,
                      isCompleted: isCompleted,
                      fontScale: fontScale,
                      height: height,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons({
    required ShiftItem shift,
    required bool hasStaff,
    required bool isCompleted,
    required double Function(double) fontScale,
    required double height,
  }) {
    final List<Widget> actions = [];

    // CASE 3: Completed → only View
    if (isCompleted) {
      actions.add(
        buildActionIcon(
          icon: Icons.visibility,
          color: Colors.orange,
          height: height,
          fontScale: fontScale,
          tooltip: 'View shift',
          onTap: () {
            NavigatorHelper.push(ShiftViewPage(shift: shift));
          },
        ),
      );
      return actions;
    }

    // CASE 1: has staff (admin assigned or user claimed)
    if (hasStaff) {
      actions.addAll([
        buildActionIcon(
          icon: Icons.edit,
          color: Colors.orange,
          height: height,
          fontScale: fontScale,
          tooltip: 'Edit shift',
          onTap: () {
            NavigatorHelper.push(AddEditShiftScreen(existingShift: shift));
          },
        ),
        buildActionIcon(
          icon: Icons.person_remove_alt_1,
          color: Colors.red,
          height: height,
          fontScale: fontScale,
          tooltip: 'Cancel staff',
          onTap: () {
            context.read<AdminShiftBloc>().add(
              CancelAdminShiftStaffEvent(shiftId: shift.id),
            );
          },
        ),
        buildActionIcon(
          icon: Icons.visibility,
          color: Colors.orange,
          height: height,
          fontScale: fontScale,
          tooltip: 'View shift',
          onTap: () {
            NavigatorHelper.push(ShiftViewPage(shift: shift));
          },
        ),
      ]);
      return actions;
    }

    // CASE 2: no staff assigned
    actions.addAll([
      buildActionIcon(
        icon: Icons.edit,
        color: Colors.orange,
        height: height,
        fontScale: fontScale,
        tooltip: 'Edit shift',
        onTap: () {
          NavigatorHelper.push(AddEditShiftScreen(existingShift: shift));
        },
      ),
      buildActionIcon(
        icon: Icons.person_add_alt_1,
        color: Colors.green,
        height: height,
        fontScale: fontScale,
        tooltip: 'Add staff',
        onTap: () {
          NavigatorHelper.push(AddEditShiftScreen(existingShift: shift));
        },
      ),
      buildActionIcon(
        icon: Icons.cancel,
        color: Colors.black,
        height: height,
        fontScale: fontScale,
        tooltip: 'Cancel shift request',
        onTap: () {
          context.read<AdminShiftBloc>().add(
            CancelAdminShiftEvent(shiftId: shift.id),
          );
        },
      ),
    ]);

    return actions;
  }

  Widget buildActionIcon({
    required IconData icon,
    required Color color,
    required double height,
    required double Function(double) fontScale,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final iconWidget = Icon(
      icon,
      color: color,
      size: fontScale(height * 0.022),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        child:
            tooltip != null
                ? Tooltip(message: tooltip, child: iconWidget)
                : iconWidget,
      ),
    );
  }

  Widget buildAddShiftButton(
    double width,
    double height,
    double Function(double) fontScale,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: OutlinedButton(
        onPressed: () {
          final weekDays = _getWeekDays();
          final selectedDate = weekDays[selectedDayIndex];

          NavigatorHelper.push(AddEditShiftScreen(initialDate: selectedDate));
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: height * 0.018),
          side: BorderSide(color: Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(Icons.add, color: Colors.grey[700], size: fontScale(20)),
      ),
    );
  }
}
