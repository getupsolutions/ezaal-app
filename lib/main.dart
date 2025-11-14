// import 'package:ezaal/core/presentation/pages/home_page/screens/home_screen.dart';
// import 'package:ezaal/core/presentation/pages/organization_page/bloc/org_bloc.dart';
// import 'package:ezaal/core/presentation/pages/splash_screen/bloc/splash_bloc.dart';
// import 'package:ezaal/core/presentation/utils/navigator_helper.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/bloc/roster_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/pages/splash_screen.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/bloc/timesheet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ezaal/core/di/di.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize DI

  String? token = await TokenStorage.getAccessToken();

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;

  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => di.sl<SplashBloc>()),
        BlocProvider(create: (context) => di.sl<ShiftBloc>()),
        BlocProvider(create: (context) => di.sl<RosterBloc>()),
        BlocProvider(create: (context) => di.sl<AttendanceBloc>()),
        BlocProvider(create: (context) => di.sl<SlotBloc>()),
        BlocProvider(create: (context) => di.sl<ManagerInfoBloc>()),
        BlocProvider(create: (context) => di.sl<TimesheetBloc>()),
        BlocProvider(create: (context) => di.sl<DashboardBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: NavigatorHelper.navigatorKey,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
