import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/add_shift_screen.dart';
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
    return '${DateFormat('dd MMM').format(selectedWeekStart)} - '
        '${DateFormat('dd MMM yyyy').format(weekEnd)}';
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

            final contentWidth = screenWidth > 700 ? 700.0 : screenWidth;

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
                    _buildScrollIndicator(contentWidth),
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
                          } else if (state is AdminShiftError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AdminShiftLoading ||
                              state is AdminShiftInitial) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is AdminShiftError) {
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
                          } else if (state is AdminShiftLoaded) {
                            // This also covers AdminShiftApproving and AdminShiftApprovedSuccessfully
                            final selectedDate =
                                _getWeekDays()[selectedDayIndex];
                            final selectedDayStr = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);

                            final dayShifts =
                                state.shifts
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
                                  _buildAddShiftButton(
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
                          }

                          return const SizedBox.shrink();
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

  // ---------- UI Helpers (unchanged from your version except for small polish) ----------

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

  Widget _buildScrollIndicator(double width) {
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
          Expanded(child: Container(height: 2, color: Colors.grey[300])),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(
    double width,
    double height,
    List<ShiftItem> shifts,
    double Function(double) fontScale,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(width * 0.02),
      itemCount: shifts.length + 1,
      itemBuilder: (context, index) {
        if (index == shifts.length) {
          return _buildAddShiftButton(width, height, fontScale);
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: _buildShiftCard(shifts[index], width, height, fontScale),
          ),
        );
      },
    );
  }

  Widget _buildShiftCard(
    ShiftItem shift,
    double width,
    double height,
    double Function(double) fontScale,
  ) {
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
                  shift.date,
                  style: TextStyle(
                    color: kWhite,
                    fontSize: fontScale(13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        shift.staffName.isEmpty
                            ? 'Unassigned'
                            : shift.staffName,
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
                Flexible(
                  flex: 2,
                  child: Wrap(
                    spacing: 4,
                    children: [
                      if (shift.hasEdit)
                        _buildActionIcon(
                          Icons.edit,
                          Colors.orange,
                          height,
                          fontScale,
                          () {
                            // TODO: open edit screen
                          },
                        ),
                      if (shift.hasCancel)
                        _buildActionIcon(
                          Icons.cancel,
                          Colors.black,
                          height,
                          fontScale,
                          () {
                            // TODO: cancel shift
                          },
                        ),
                      if (shift.hasAdd)
                        _buildActionIcon(
                          Icons.add_circle,
                          Colors.green,
                          height,
                          fontScale,
                          () {},
                        ),
                      if (shift.hasView)
                        _buildActionIcon(
                          Icons.visibility,
                          Colors.orange,
                          height,
                          fontScale,
                          () {
                            // TODO: open details
                          },
                        ),
                      if (shift.hasDocument)
                        _buildActionIcon(
                          Icons.description,
                          Colors.orange,
                          height,
                          fontScale,
                          () {},
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    Color color,
    double height,
    double Function(double) fontScale,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Icon(icon, color: color, size: fontScale(height * 0.022)),
      ),
    );
  }

  Widget _buildAddShiftButton(
    double width,
    double height,
    double Function(double) fontScale,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: OutlinedButton(
        onPressed: () {
          NavigatorHelper.push(const AddShiftScreen());
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
