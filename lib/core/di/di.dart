import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/RemoteDataSource/admin_shift_datasource.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/respositoryImpl/adminshift_repositoryimpl.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/respository/adminshift_repository.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/adminshift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/approve_pendingshiftclaim.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/cancel_shift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/get_shift_master_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/save_admin_shiftusecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_organization_rostermail_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_staff_available_shift.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/send_staff_confirmed_mail_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/update_shift_statususecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/domain/usecase/update_shift_usecase.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/data/datasource/admin_avail_remote.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/data/repoImpl/admin_avail_repoimpl.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/repo/available_admin_repo.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/usecase/get_admin_availability_usecase.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_bloc.dart';
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
import 'package:ezaal/features/admin_side/admin_dashboard/data/remote_datasource/notification_remote_datasource..dart';
import 'package:ezaal/features/admin_side/admin_dashboard/data/repositoryImpl/notification_repositoryimpl.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/domain/repository/notification_repository.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/domain/usecase/notification_usecase.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_bloc.dart';
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
import 'package:ezaal/features/user_side/staff_availbility_page/data/dataSource/availbility_datasource.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/data/repoimpl/availbility_repositoryimpl.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/repo/availability_repository.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/usecase/availbility_usecase.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_bloc.dart';
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
  sl.registerFactory(
    () => NotificationBloc(
      deleteNotificationUseCase: sl(),
      getNotificationsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      markAllAsReadUseCase: sl(),
      markAsReadUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminShiftBloc(
      getAdminShiftsForWeek: sl(),
      approvePendingShiftClaims: sl(),
      saveAdminShiftUseCase: sl(),
      getShiftMastersUseCase: sl(),
      cancelAdminShiftStaffUseCase: sl(),
      cancelAdminShiftUseCase: sl(),
      updateShiftAttendanceUseCase: sl(),
      updateShiftStatusUseCase: sl(),
      sendOrganizationRosterMailUseCase: sl(),
      sendStaffConfirmedMailUseCase: sl(),
      sendStaffAvailableShiftMailUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AvailabilityBloc(
      editUsecase: sl(),
      deleteUseCase: sl(),
      getUseCase: sl(),
      saveUseCase: sl(),
    ),
  );
  sl.registerFactory(() => AdminAvailabilityBloc(sl()));

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
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminShiftsForWeek(sl()));
  sl.registerLazySingleton(() => ApprovePendingShiftClaimsUseCase(sl()));
  sl.registerLazySingleton(() => SaveAdminShiftUseCase(sl()));
  sl.registerLazySingleton(() => GetShiftMastersUseCase(sl()));
  sl.registerLazySingleton(() => CancelAdminShiftStaffUseCase(sl()));
  sl.registerLazySingleton(() => CancelAdminShiftUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShiftAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShiftStatusUseCase(sl()));
  sl.registerLazySingleton(() => SendOrganizationRosterMailUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => SaveAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminAvailabilityRange(sl()));
  sl.registerLazySingleton(() => EditAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => SendStaffConfirmedMailUseCase(sl()));
  sl.registerLazySingleton(() => SendStaffAvailableShiftMailUseCase(sl()));

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
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AdminShiftRepository>(
    () => AdminShiftRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AvailabilityRepository>(
    () => AvailabilityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AvailabilityAdminRepo>(
    () => AvailabilityAdminRepoImpl(sl()),
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
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(),
  );
  sl.registerLazySingleton<AdminShiftRemoteDataSource>(
    () => AdminShiftRemoteDataSource(),
  );
  sl.registerLazySingleton<AvailabilityRemoteDataSource>(
    () => AvailabilityRemoteDataSource(),
  );
  sl.registerLazySingleton<AvailabilityAdminRemoteDS>(
    () => AvailabilityAdminRemoteDS(),
  );
}
