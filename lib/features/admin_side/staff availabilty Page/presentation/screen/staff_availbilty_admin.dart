import 'dart:async';
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/add_shift_screen.dart'
    hide AvailabilityUtils;
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_bloc.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_event.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_state.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/widget/admin_staff_availbility_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffAvailbiltyAdminPage extends StatefulWidget {
  const StaffAvailbiltyAdminPage({super.key});

  @override
  State<StaffAvailbiltyAdminPage> createState() =>
      _StaffAvailbiltyAdminPageState();
}

class _StaffAvailbiltyAdminPageState extends State<StaffAvailbiltyAdminPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  int? _orgId; // null => all orgs
  int? _selectedStaffId; // null => all staff

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShiftBloc>().add(const LoadShiftMastersEvent());
      _loadMonth();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadMonth() {
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    context.read<AdminAvailabilityBloc>().add(
      LoadAdminAvailabilityRange(
        startDate: AvailabilityUtils.ymd(start),
        endDate: AvailabilityUtils.ymd(end),
        organiz: _orgId,
      ),
    );
  }

  void _reloadDebounced() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadMonth);
  }

  Future<void> _openAddShift(
    DateTime date, {
    required StaffDto staff,
    int? orgId,
    AdminAvailablitEntity? availability,
  }) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddEditShiftScreen(
              initialDate: date,
              initialOrgId: orgId,
              initialStaffId: staff.id,
              initialStaffName: staff.name,
              initialAvailability: availability,
            ),
      ),
    );

    if (ok == true) _reloadDebounced();
  }

  // organiz == null => all orgs
  bool _orgMatches(int? rowOrg, int? filterOrg) {
    if (filterOrg == null) return true;
    if (rowOrg == null) return true;
    return rowOrg == filterOrg;
  }

  bool _hasAvailability({
    required List<AdminAvailablitEntity> items,
    required int staffId,
    required DateTime day,
    required int? orgFilter,
  }) {
    final key = AvailabilityUtils.ymd(day);
    for (final e in items) {
      if (e.dte != key) continue;
      if (e.userid != staffId) continue;
      if (_orgMatches(e.organiz, orgFilter)) return true;
    }
    return false;
  }

  AdminAvailablitEntity? _availabilityFor({
    required List<AdminAvailablitEntity> items,
    required int staffId,
    required DateTime day,
    required int? orgFilter,
  }) {
    final key = AvailabilityUtils.ymd(day);
    for (final e in items) {
      if (e.dte != key) continue;
      if (e.userid != staffId) continue;
      if (_orgMatches(e.organiz, orgFilter)) return e;
    }
    return null;
  }

  Future<void> _openFilterDialog({
    required List<OrganizationDto> orgs,
    required List<StaffDto> staff,
  }) async {
    final result = await showDialog<FilterResult>(
      context: context,
      builder:
          (context) => FilterDialog(
            orgs: orgs,
            staff: staff,
            initialOrgId: _orgId,
            initialStaffId: _selectedStaffId,
          ),
    );

    if (result == null) return;

    setState(() {
      _orgId = result.orgId;
      _selectedStaffId = result.staffId;
    });

    // Reload availability when org changes (your API supports org filter)
    _loadMonth();
  }

  // String _orgName(int? id, List<OrganizationDto> orgs) {
  //   if (id == null) return "All Organizations";
  //   for (final o in orgs) {
  //     if (o.id == id) return o.name;
  //   }
  //   return "Organization #$id";
  // }

  // String _staffName(int? id, List<StaffDto> staff) {
  //   if (id == null) return "All Staff";
  //   for (final s in staff) {
  //     if (s.id == id) return s.name;
  //   }
  //   return "Staff #$id";
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: primaryDarK,
        title: const Text(
          "Staff Availability (Admin)",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<AdminShiftBloc, AdminShiftState>(
            builder: (context, mastersState) {
              final orgs =
                  (mastersState is ShiftMastersLoaded)
                      ? mastersState.masters.organizations
                      : <OrganizationDto>[];
              final staff =
                  (mastersState is ShiftMastersLoaded)
                      ? mastersState.masters.staff
                      : <StaffDto>[];

              return IconButton(
                tooltip: "Filters",
                onPressed:
                    (mastersState is ShiftMastersLoaded)
                        ? () => _openFilterDialog(orgs: orgs, staff: staff)
                        : null,
                icon: const Icon(Icons.filter_alt_outlined),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isDesktop = w >= 1024;
            final pad = EdgeInsets.all(w < 650 ? 12 : 16);

            return Padding(
              padding: pad,
              child: Column(
                children: [
                  // ✅ small chips to show current filters (no dropdown here)
                  // BlocBuilder<AdminShiftBloc, AdminShiftState>(
                  //   builder: (context, mastersState) {
                  //     final orgs =
                  //         (mastersState is ShiftMastersLoaded)
                  //             ? mastersState.masters.organizations
                  //             : <OrganizationDto>[];
                  //     final staff =
                  //         (mastersState is ShiftMastersLoaded)
                  //             ? mastersState.masters.staff
                  //             : <StaffDto>[];

                  //     final orgLabel = _orgName(_orgId, orgs);
                  //     final staffLabel = _staffName(_selectedStaffId, staff);

                  //     return Card(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(12),
                  //         child: Row(
                  //           children: [
                  //             Expanded(
                  //               child: Wrap(
                  //                 spacing: 8,
                  //                 runSpacing: 8,
                  //                 children: [
                  //                   ChipPill(
                  //                     icon: Icons.apartment,
                  //                     label: orgLabel,
                  //                   ),
                  //                   ChipPill(
                  //                     icon: Icons.person,
                  //                     label: staffLabel,
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             const SizedBox(width: 8),
                  //             ElevatedButton.icon(
                  //               onPressed:
                  //                   (mastersState is ShiftMastersLoaded)
                  //                       ? () => _openFilterDialog(
                  //                         orgs: orgs,
                  //                         staff: staff,
                  //                       )
                  //                       : null,
                  //               icon: const Icon(Icons.tune),
                  //               label: const Text("Filters"),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: BlocBuilder<AdminShiftBloc, AdminShiftState>(
                      builder: (context, mastersState) {
                        final staff =
                            (mastersState is ShiftMastersLoaded)
                                ? mastersState.masters.staff
                                : <StaffDto>[];
                        final orgs =
                            (mastersState is ShiftMastersLoaded)
                                ? mastersState.masters.organizations
                                : <OrganizationDto>[];

                        if (mastersState is ShiftMastersLoading ||
                            mastersState is AdminShiftInitial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return BlocConsumer<
                          AdminAvailabilityBloc,
                          AdminAvailabilityState
                        >(
                          listener: (context, state) {
                            if (state.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          builder: (context, avState) {
                            final items = avState.items;

                            // ✅ apply staff filter + must have availability for selected date
                            final filteredStaff =
                                staff.where((s) {
                                    if (_selectedStaffId != null &&
                                        s.id != _selectedStaffId) {
                                      return false;
                                    }
                                    return _hasAvailability(
                                      items: items,
                                      staffId: s.id,
                                      day: _selectedDay,
                                      orgFilter: _orgId,
                                    );
                                  }).toList()
                                  ..sort(
                                    (a, b) => a.name.toLowerCase().compareTo(
                                      b.name.toLowerCase(),
                                    ),
                                  );

                            final calendar = CalendarPanel(
                              focusedDay: _focusedDay,
                              selectedDay: _selectedDay,
                              loading: avState.loading,
                              hasAnyAvailability: (day) {
                                for (final s in staff) {
                                  if (_hasAvailability(
                                    items: items,
                                    staffId: s.id,
                                    day: day,
                                    orgFilter: _orgId,
                                  ))
                                    return true;
                                }
                                return false;
                              },
                              onDaySelected:
                                  (d, f) => setState(() {
                                    _selectedDay = d;
                                    _focusedDay = f;
                                  }),
                              onPageChanged: (f) {
                                setState(() => _focusedDay = f);
                                _loadMonth();
                              },
                            );

                            final list = AvailableStaffList(
                              selectedDay: _selectedDay,
                              orgFilter: _orgId,
                              orgs: orgs,
                              staff: filteredStaff,
                              getAvailability:
                                  (staffId) => _availabilityFor(
                                    items: items,
                                    staffId: staffId,
                                    day: _selectedDay,
                                    orgFilter: _orgId,
                                  ),
                              onAddShiftForStaff:
                                  (staff) => _openAddShift(
                                    _selectedDay,
                                    staff: staff,
                                    orgId: _orgId,
                                    availability: _availabilityFor(
                                      items: items,
                                      staffId: staff.id,
                                      day: _selectedDay,
                                      orgFilter: _orgId,
                                    ),
                                  ),
                            );

                            if (isDesktop) {
                              return Row(
                                children: [
                                  Expanded(flex: 6, child: calendar),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 5, child: list),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Expanded(flex: 6, child: calendar),
                                const SizedBox(height: 12),
                                Expanded(flex: 5, child: list),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
