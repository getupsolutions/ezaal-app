import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/core/widgets/svg_imageviewer.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/pages/availableshift_page.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/pages/clockin_out_page.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/pages/roster_page.dart';
import 'package:flutter/material.dart';

Widget buildEzaalLogo({required bool isSmallScreen}) {
  final size = isSmallScreen ? 32.0 : 40.0;

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withAlpha(122),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/Logo/Media.jpeg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient logo with 'E' if image fails to load
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget buildAvailableShiftCard(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 600;
  final cardPadding = isSmallScreen ? 20.0 : 32.0;
  final iconSize = isSmallScreen ? 24.0 : 32.0;
  final titleSize = isSmallScreen ? 18.0 : 22.0;
  final subtitleSize = isSmallScreen ? 14.0 : 16.0;

  return InkWell(
    onTap: () {
      NavigatorHelper.push(AvailableshiftPage());
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: primaryDarK,
        // gradient: const LinearGradient(
        //   colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.orange.withAlpha(130),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(130),
              shape: BoxShape.circle,
            ),
            child: SVGImageView(
              image: 'assets/svg/available_shift_user_icon.svg',
              width: iconSize,
              height: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Available Shift',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click here',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildMyRosterCard(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 600;
  final cardPadding = isSmallScreen ? 20.0 : 32.0;
  final iconSize = isSmallScreen ? 24.0 : 32.0;
  final titleSize = isSmallScreen ? 18.0 : 22.0;
  final subtitleSize = isSmallScreen ? 14.0 : 16.0;

  return InkWell(
    onTap: () {
      NavigatorHelper.push(RosterPage());
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: primaryDarK,
        // gradient: const LinearGradient(
        //   colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.blue.withAlpha(130),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(130),
              shape: BoxShape.circle,
            ),
            child: SVGImageView(
              image: 'assets/svg/my_roster.svg',
              width: iconSize,
              height: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'My Roster',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click here',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.blue[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildClockInOutCard(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 600;
  final cardPadding = isSmallScreen ? 20.0 : 32.0;
  final iconSize = isSmallScreen ? 24.0 : 32.0;
  final titleSize = isSmallScreen ? 18.0 : 22.0;
  final subtitleSize = isSmallScreen ? 14.0 : 16.0;

  return InkWell(
    onTap: () {
      NavigatorHelper.push(ClockInOutPage());
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: primaryDarK,
        // gradient: const LinearGradient(
        //   colors: [Color(0xFFF472B6), Color(0xFFEC4899)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.pink.withAlpha(130),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(130),
              shape: BoxShape.circle,
            ),
            child: SVGImageView(
              image: 'assets/svg/nav_check_in.svg',
              width: iconSize,
              height: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Clock In & Clock Out',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click here',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
