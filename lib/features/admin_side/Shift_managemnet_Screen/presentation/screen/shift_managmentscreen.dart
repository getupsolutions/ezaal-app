import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/add_shift_screen.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/completed_shift_view.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/shift_filter_dialog.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/widget/shift_widget.dart';
import 'package:flutter/material.dart';
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
    selectedWeekStart = _getWeekStart(DateTime.now());
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
      selectedWeekStart = selectedWeekStart.subtract(Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.add(Duration(days: 7));
    });
  }

  String _getWeekRangeText() {
    final weekEnd = selectedWeekStart.add(Duration(days: 6));
    return '${DateFormat('dd MMM').format(selectedWeekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: Column(
        children: [
          buildWeekSelector(screenWidth, screenHeight),
          buildDayTabs(screenWidth, screenHeight),
          _buildScrollIndicator(screenWidth),
          Expanded(child: _buildShiftsList(screenWidth, screenHeight)),
        ],
      ),
    );
  }

  Widget buildWeekSelector(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
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
            constraints: BoxConstraints(),
          ),
          Text(
            _getWeekRangeText(),
            style: TextStyle(
              color: kWhite,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: kWhite),
            onPressed: _nextWeek,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget buildDayTabs(double screenWidth, double screenHeight) {
    final weekDays = _getWeekDays();

    return Container(
      height: screenHeight * 0.1,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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
              width: screenWidth * 0.18,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
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
                      fontSize: screenHeight * 0.016,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('dd').format(day),
                    style: TextStyle(
                      color: kWhite,
                      fontSize: screenHeight * 0.022,
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

  Widget _buildScrollIndicator(double screenWidth) {
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
          Expanded(child: Container(height: 2, color: Colors.grey[300])),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.02),
      itemCount: shifts.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == shifts.length) {
          return _buildAddShiftButton(screenWidth, screenHeight);
        }
        return _buildShiftCard(shifts[index], screenWidth, screenHeight);
      },
    );
  }

  Widget _buildShiftCard(
    ShiftItem shift,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.012,
            ),
            decoration: BoxDecoration(
              color: primaryDarK,
              borderRadius: BorderRadius.only(
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
                    fontSize: screenHeight * 0.014,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(
                    color: kWhite,
                    fontSize: screenHeight * 0.014,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.008,
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
                Text(
                  shift.location,
                  style: TextStyle(
                    color: kWhite,
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  shift.date,
                  style: TextStyle(
                    color: kWhite,
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.time,
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      shift.staffName,
                      style: TextStyle(
                        fontSize: screenHeight * 0.016,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (shift.hasEdit)
                      _buildActionIcon(
                        Icons.edit,
                        Colors.orange,
                        screenHeight,
                        () {},
                      ),
                    if (shift.hasCancel)
                      _buildActionIcon(
                        Icons.cancel,
                        Colors.black,
                        screenHeight,
                        () {},
                      ),
                    if (shift.hasAdd)
                      _buildActionIcon(
                        Icons.add_circle,
                        Colors.green,
                        screenHeight,
                        () {},
                      ),
                    if (shift.hasView)
                      _buildActionIcon(
                        Icons.visibility,
                        Colors.orange,
                        screenHeight,
                        () {
                          NavigatorHelper.push(ViewRequestDialog());
                        },
                      ),
                    if (shift.hasDocument)
                      _buildActionIcon(
                        Icons.description,
                        Colors.orange,
                        screenHeight,
                        () {},
                      ),
                  ],
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
    double screenHeight,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 8),
        child: Icon(icon, color: color, size: screenHeight * 0.028),
      ),
    );
  }

  Widget _buildAddShiftButton(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: OutlinedButton(
        onPressed: () {
          NavigatorHelper.push(AddShiftScreen());
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
          side: BorderSide(color: Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(
          Icons.add,
          color: Colors.grey[700],
          size: screenHeight * 0.03,
        ),
      ),
    );
  }
}
