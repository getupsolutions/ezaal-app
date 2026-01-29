import 'dart:async';
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/shift_managmentscreen.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_state.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/widget/admin_drawer.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/widget/dashboard_tile.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/widget/date_time.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/widget/notification_uipage.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/screen/staff_availbilty_admin.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/widget/dashboard_widgets.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String greeting = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    updateGreeting();
    updateDateTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          updateDateTime();
          updateGreeting();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ---------------------------
  // TIME-BASED GREETINGS
  // ---------------------------
  void updateGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Responsive spacing
    double smallGap = height * 0.01;
    double mediumGap = height * 0.02;
    double largeGap = height * 0.03;

    final bool isSmall = width < 600;
    final bool isMedium = width >= 600 && width < 1100;

    double titleSize =
        isSmall
            ? 22
            : isMedium
            ? 26
            : 30;
    double dateSize =
        isSmall
            ? 14
            : isMedium
            ? 16
            : 18;
    double userNameSize =
        isSmall
            ? 16
            : isMedium
            ? 18
            : 20;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminDrawer(),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryDarK,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: kWhite),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildEzaalLogo(isSmallScreen: isSmall),
              SizedBox(width: smallGap),
              Text(
                "EHC Hub",
                style: TextStyle(
                  color: kWhite,
                  fontSize:
                      isSmall
                          ? 16
                          : isMedium
                          ? 18
                          : 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // BlocBuilder<NotificationBloc, NotificationState>(
          //   builder: (context, notificationState) {
          //     int unreadCount = 0;

          //     if (notificationState is NotificationLoaded) {
          //       unreadCount = notificationState.unreadCount;
          //     }

          //     return Padding(
          //       padding: const EdgeInsets.only(right: 12.0),
          //       child: Stack(
          //         children: [
          //           IconButton(
          //             icon: Icon(Icons.notifications, color: kWhite, size: 26),
          //             onPressed: () {
          //               NavigatorHelper.push(NotificationPage());
          //             },
          //           ),
          //           if (unreadCount > 0)
          //             Positioned(
          //               right: 8,
          //               top: 8,
          //               child: Container(
          //                 padding: EdgeInsets.all(4),
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   shape: BoxShape.circle,
          //                 ),
          //                 constraints: BoxConstraints(
          //                   minWidth: 18,
          //                   minHeight: 18,
          //                 ),
          //                 child: Center(
          //                   child: Text(
          //                     unreadCount > 99 ? '99+' : unreadCount.toString(),
          //                     style: TextStyle(
          //                       color: Colors.white,
          //                       fontSize: 10,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String userName = "User";
              String? photo;
              if (state is AuthSuccess) {
                userName = state.user.name.trim();
                photo = state.user.photoUrl;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:
                          isSmall
                              ? 16
                              : isMedium
                              ? 18
                              : 22,
                      backgroundImage:
                          (photo != null && photo.isNotEmpty)
                              ? NetworkImage(photo)
                              : null,
                      child:
                          (photo == null || photo.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                    ),
                    if (!isSmall) ...[
                      const SizedBox(width: 8),
                      Text(
                        userName,
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: userNameSize,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: kWhite),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              isSmall
                  ? 16
                  : isMedium
                  ? 24
                  : 32,
          vertical:
              isSmall
                  ? 16
                  : isMedium
                  ? 24
                  : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String userName = "User";
                if (state is AuthSuccess) {
                  userName = state.user.name.trim();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                        color: primaryDarK,
                      ),
                    ),

                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: titleSize - 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: mediumGap),

                    Row(
                      children: [
                        // DATE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 20),
                              SizedBox(width: smallGap),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: dateSize),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: mediumGap),

                        // TIME
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: smallGap),
                              Text(
                                formattedTime,
                                style: TextStyle(fontSize: dateSize),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: largeGap),

            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: smallGap),
            Divider(color: kBlack),
            SizedBox(height: largeGap),

            DashboardTile(
              color: primaryDarK,
              icon: Icons.bar_chart_outlined,
              title: "Shift management",
              actionText: "Click Here",
              onTap: () => NavigatorHelper.push(ShiftManagmentscreen()),
            ),
            SizedBox(height: smallGap),

            DashboardTile(
              color: primaryDarK,
              icon: Icons.event_available,
              title: "Staff Availabilty",
              actionText: "Click Here",
              onTap: () => NavigatorHelper.push(StaffAvailbiltyAdminPage()),
            ),
          ],
        ),
      ),
    );
  }
}
