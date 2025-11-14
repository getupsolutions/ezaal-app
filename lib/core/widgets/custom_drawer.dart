import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/core/widgets/show_dialog.dart';
import 'package:ezaal/core/widgets/svg_imageviewer.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/pages/availableshift_page.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/pages/clockin_out_page.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/login_screen.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/user_details_page.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/pages/roster_page.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/screen/timesheet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isFirstDropdownExpanded = false;
  bool isSecondDropdownExpanded = false;
  int selectedIndex = -1; // Default no selection

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: primaryDarK,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Responsive sizes
            final horizontalPadding = width * 0.04;
            final verticalPadding = height * 0.015;
            final avatarSize = width * 0.25;
            final titleFontSize = width * 0.045;
            final subtitleFontSize = width * 0.04;
            final iconSize = width * 0.10;

            return Column(
              children: [
                // Drawer Header
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // Default guest values
                    String name = "Guest";
                    String email = "guest@example.com";
                    String? typeId;
                    String? photoUrl;

                    // Check if user is logged in
                    if (state is AuthSuccess) {
                      name = state.user.name;
                      email = state.user.email;
                      typeId = state.user.staffId;
                      photoUrl = state.user.photoUrl;
                    } else if (state is AuthLoading) {
                      // Show loading indicator while checking auth
                      return Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: avatarSize,
                                height: avatarSize,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(height: verticalPadding),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: GestureDetector(
                        onTap:
                            state is AuthSuccess
                                ? () => NavigatorHelper.push(UserDetailsPage())
                                : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child:
                                    photoUrl != null
                                        ? Image.network(
                                          photoUrl,
                                          width: avatarSize,
                                          height: avatarSize,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Icon(
                                                Icons.person,
                                                size: avatarSize,
                                              ),
                                        )
                                        : Icon(Icons.person, size: avatarSize),
                              ),
                              SizedBox(height: verticalPadding),
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                              SizedBox(height: verticalPadding / 2),
                              Text(
                                email,
                                style: TextStyle(fontSize: subtitleFontSize),
                              ),
                              if (typeId != null)
                                Text(
                                  typeId,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: kPurple,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: verticalPadding),

                // Scrollable Menu
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/nav_dashboard.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'My Dashboard',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap: () => NavigatorHelper.pop(),
                        ),
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/my_roster.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'My Roster',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap: () => NavigatorHelper.push(RosterPage()),
                        ),
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/available_shift_user_icon.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Available Shift',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap:
                              () => NavigatorHelper.push(AvailableshiftPage()),
                        ),
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/drawer_time_sheet.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Time Sheet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap: () => NavigatorHelper.push(TimesheetPage()),
                        ),
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/nav_check_in.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Clock in & Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap: () => NavigatorHelper.push(ClockInOutPage()),
                        ),
                        // ListTile(
                        //   leading: Icon(
                        //     Icons.note,
                        //     color:
                        //         selectedIndex == 0
                        //             ? Colors.white
                        //             : Colors.white70,
                        //     size: iconSize,
                        //   ),
                        //   title: Text(
                        //     'Progress note',
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       color: kWhite,
                        //       fontSize: titleFontSize,
                        //     ),
                        //   ),
                        //   onTap: () => NavigatorHelper.push(ProgressnotePage()),
                        // ),
                      ],
                    ),
                  ),
                ),

                // Logout at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    leading: SVGImageView(
                      image: 'assets/svg/logout.svg',
                      width: iconSize,
                      height: iconSize,
                      color: kRed,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kWhite,
                        fontSize: titleFontSize,
                      ),
                    ),
                    onTap: () {
                      CupertinoDialogUtils.showCupertinoDialogBox(
                        context: context,
                        title: 'Logout',
                        content: 'Are you sure you want to logout?',
                        actions: [
                          CupertinoDialogActionModel(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                            isDefaultAction: true,
                          ),
                          CupertinoDialogActionModel(
                            child: const Text('Logout'),
                            onPressed: () {
                              context.read<AuthBloc>().add(LogoutRequested());
                              NavigatorHelper.pushReplacement(
                                const LoginScreen(),
                              );
                            },
                            isDestructiveAction: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
