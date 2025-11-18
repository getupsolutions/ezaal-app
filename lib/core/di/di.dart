import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/data_source/managerinfo_datasource.dart';
import 'package:ezaal/features/user_side/available_shift_page/data/data_source/shift_remote_datasource.dart';
import 'package:ezaal/features/user_side/available_shift_page/data/repository/managerinfo_repositoryimpl.dart';
import 'package:ezaal/features/user_side/available_shift_page/data/repository/shift_repository_impl.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/repository/shift_repository.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/claim_shift_usecase.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/get_availableshift.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/repository/slot_repository_impl.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/managerinfo_repository.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/slot_repository.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/get_slot_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/managerinfo_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/data/data_source/auth_remotedatasource.dart';
import 'package:ezaal/features/user_side/login_screen/data/repository/auth_repositoryimp.dart';
import 'package:ezaal/features/user_side/login_screen/domain/repository/auth_repository.dart';
import 'package:ezaal/features/user_side/login_screen/domain/usecase/login_usecase.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/roster_page/data/data_source/roster_remote_data_source.dart';
import 'package:ezaal/features/user_side/roster_page/data/repository/roster_repository_impl.dart';
import 'package:ezaal/features/user_side/roster_page/domain/repository/roster_repository.dart';
import 'package:ezaal/features/user_side/roster_page/domain/usecase/get_roster_usecase.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/bloc/roster_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/data_source/attendance_remote_data_source.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/repository/attendance_repository_impl.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/attendance_repository.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/clock_in_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/clock_out_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:ezaal/features/user_side/timesheet_page/data/remoteDatasource/timesheet_remotedatasource.dart';
import 'package:ezaal/features/user_side/timesheet_page/data/repositoryImpl/timesheet_repositoryimpl.dart';
import 'package:ezaal/features/user_side/timesheet_page/domain/repository/timesheet_repository.dart';
import 'package:ezaal/features/user_side/timesheet_page/domain/usecase/timesheet_usecase.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/bloc/timesheet_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final token = await TokenStorage.getAccessToken() ?? '';
  //Bloc
  sl.registerFactory(() => SplashBloc());
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => ShiftBloc(sl(), sl()));
  sl.registerFactory(
    () => RosterBloc(getRosterCalendarUseCase: sl(), getRosterUseCase: sl()),
  );
  sl.registerFactory(
    () => AttendanceBloc(clockInUseCase: sl(), clockOutUseCase: sl()),
  );
  sl.registerFactory(() => SlotBloc(sl()));

  sl.registerFactory(() => ManagerInfoBloc(submitManagerInfoUseCase: sl()));
  sl.registerFactory(() => TimesheetBloc(getTimesheetUseCase: sl()));
  sl.registerFactory(() => DashboardBloc());

  //! UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ClaimShiftUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableShiftsUseCase(sl()));
  sl.registerLazySingleton(() => GetRosterUseCase(sl()));
  sl.registerLazySingleton(() => GetRosterCalendarUseCase(sl()));
  sl.registerLazySingleton(() => ClockInUseCase(sl()));
  sl.registerLazySingleton(() => ClockOutUseCase(sl()));
  sl.registerLazySingleton(() => GetSlotUseCase(sl()));
  sl.registerLazySingleton(() => SubmitManagerInfoUseCase(sl()));
  sl.registerLazySingleton(() => GetTimesheetUseCase(sl()));

  //! Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ShiftRepository>(() => ShiftRepositoryImpl(sl()));
  sl.registerLazySingleton<RosterRepository>(() => RosterRepositoryImpl(sl()));
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SlotRepository>(() => SlotRepositoryImpl(sl()));
  sl.registerLazySingleton<ManagerInfoRepository>(
    () => ManagerInfoRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TimesheetRepository>(
    () => TimesheetRepositoryImpl(remoteDataSource: sl()),
  );

  //! Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton(() => ShiftRemoteDataSource());
  sl.registerLazySingleton<RosterRemoteDataSource>(
    () => RosterRemoteDataSource(),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSource(),
  );
  sl.registerLazySingleton<ManagerInfoRemoteDataSource>(
    () => ManagerInfoRemoteDataSource(),
  );
  sl.registerLazySingleton<TimesheetRemoteDataSource>(
    () => TimesheetRemoteDataSource(),
  );

  //Offline Sync Service
  sl.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(
      attendanceDataSource: sl<AttendanceRemoteDataSource>(),
      managerInfoDataSource: sl<ManagerInfoRemoteDataSource>(),
    ),
  );
}
