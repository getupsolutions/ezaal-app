import 'dart:async';

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_state.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shiftevent.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_bloc.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_event.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_state.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/widget/availability_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffAvailbilityPage extends StatefulWidget {
  const StaffAvailbilityPage({super.key, this.selectedOrgId});
  final int? selectedOrgId;

  @override
  State<StaffAvailbilityPage> createState() => _StaffAvailbilityPageState();
}

class _StaffAvailbilityPageState extends State<StaffAvailbilityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime? _lastSuccessAt;
  Timer? _reloadDebounce;

  int? _orgId;

  @override
  void initState() {
    super.initState();
    _orgId = widget.selectedOrgId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminShiftBloc>().add(LoadShiftMastersEvent());
      _loadMonth();
    });
  }

  @override
  void dispose() {
    _reloadDebounce?.cancel();
    super.dispose();
  }

  void _loadMonth() {
    final start = AvailabilityUtils.firstDayOfMonth(_focusedDay);
    final end = AvailabilityUtils.lastDayOfMonth(_focusedDay);

    context.read<AvailabilityBloc>().add(
      LoadAvailabilityRange(
        startDate: AvailabilityUtils.ymd(start),
        endDate: AvailabilityUtils.ymd(end),
        organiz: _orgId,
      ),
    );
  }

  void _debouncedReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 350), _loadMonth);
  }

  AvailabilityEntity? _findForDate(
    List<AvailabilityEntity> items,
    DateTime day,
  ) {
    final key = AvailabilityUtils.ymd(day);
    for (final e in items) {
      if (AvailabilityUtils.ymd(e.date) == key && e.organiz == _orgId) return e;
      if (_orgId == null && AvailabilityUtils.ymd(e.date) == key) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Breakpoints
    final isDesktop = w >= 900;
    final maxW = isDesktop ? 1200.0 : double.infinity;

    return BlocListener<AvailabilityBloc, AvailabilityState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.success != null) {
          final now = DateTime.now();
          final last = _lastSuccessAt;
          final shouldShow =
              last == null ||
              now.difference(last) > const Duration(milliseconds: 800);

          if (shouldShow) {
            _lastSuccessAt = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.success!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          _debouncedReload();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F8),
        appBar: CustomAppBar(
          title: "Staff Availability",
          elevation: 0,
          backgroundColor: primaryDarK,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // BlocBuilder<AdminShiftBloc, AdminShiftState>(
                  //   builder: (context, mState) {
                  //     final orgs =
                  //         (mState is ShiftMastersLoaded)
                  //             ? mState.masters.organizations
                  //             : <OrganizationDto>[];

                  //     return Card(
                  //       elevation: 1,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(12),
                  //         child: Row(
                  //           children: [
                  //             const Icon(Icons.business, size: 18),
                  //             const SizedBox(width: 10),
                  //             Expanded(
                  //               child: DropdownButtonFormField<int?>(
                  //                 value: _orgId,
                  //                 decoration: const InputDecoration(
                  //                   labelText: "Organization (Optional Filter)",
                  //                   border: OutlineInputBorder(),
                  //                   isDense: true,
                  //                 ),
                  //                 items: [
                  //                   const DropdownMenuItem<int?>(
                  //                     value: null,
                  //                     child: Text("All Organizations"),
                  //                   ),
                  //                   ...orgs.map(
                  //                     (o) => DropdownMenuItem<int?>(
                  //                       value: o.id,
                  //                       child: Text(o.name),
                  //                     ),
                  //                   ),
                  //                 ],
                  //                 onChanged: (v) {
                  //                   setState(() => _orgId = v);
                  //                   _loadMonth();
                  //                 },
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 12),

                  // ✅ Main responsive area
                  Expanded(
                    child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
                      builder: (context, state) {
                        final items = state.items;
                        final selectedEntity =
                            _selectedDay == null
                                ? null
                                : _findForDate(items, _selectedDay!);

                        // ✅ Desktop: side-by-side
                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: AvailabilityCalendarCard(
                                  focusedDay: _focusedDay,
                                  selectedDay: _selectedDay,
                                  loading: state.loading,
                                  hasAvailability:
                                      (day) => _findForDate(items, day) != null,
                                  onDaySelected: (day, focused) async {
                                    setState(() {
                                      _selectedDay = day;
                                      _focusedDay = focused;
                                    });

                                    final existing = _findForDate(items, day);

                                    final mState =
                                        context.read<AdminShiftBloc>().state;
                                    final orgs =
                                        (mState is ShiftMastersLoaded)
                                            ? mState.masters.organizations
                                            : <OrganizationDto>[];

                                    await showAddAvailabilityDialog(
                                      context: context,
                                      organizations: orgs,
                                      initialOrganiz: _orgId,
                                      initialDate: day,
                                      existing: existing,
                                    );
                                  },
                                  onPageChanged: (focused) {
                                    setState(() => _focusedDay = focused);
                                    _loadMonth();
                                  },
                                  bottomPanel: AvailabilityBottomPanel(
                                    selectedDay: _selectedDay,
                                    entity: selectedEntity,
                                    selectedOrgId: _orgId,
                                    onRemove: (e) {
                                      context.read<AvailabilityBloc>().add(
                                        DeleteAvailabilityForDate(
                                          date: e.date,
                                          organiz: e.organiz,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: AvailabilityListCard(
                                  items:
                                      items.where((e) {
                                        if (_orgId == null) return true;
                                        return e.organiz == _orgId;
                                      }).toList(),
                                  onEdit: (e) async {
                                    setState(() {
                                      _selectedDay = e.date;
                                      _focusedDay = e.date;
                                    });

                                    final mState =
                                        context.read<AdminShiftBloc>().state;
                                    final orgs =
                                        (mState is ShiftMastersLoaded)
                                            ? mState.masters.organizations
                                            : <OrganizationDto>[];

                                    await showAddAvailabilityDialog(
                                      context: context,
                                      organizations: orgs,
                                      initialOrganiz: e.organiz,
                                      initialDate: e.date,
                                      existing: e,
                                    );
                                  },
                                  onRemove: (e) {
                                    context.read<AvailabilityBloc>().add(
                                      DeleteAvailabilityForDate(
                                        date: e.date,
                                        organiz: e.organiz,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        // ✅ Mobile/Tablet: vertical split
                        return LayoutBuilder(
                          builder: (context, c) {
                            final isShort = c.maxHeight < 650;

                            return Column(
                              children: [
                                Expanded(
                                  flex: isShort ? 6 : 7,
                                  child: AvailabilityCalendarCard(
                                    focusedDay: _focusedDay,
                                    selectedDay: _selectedDay,
                                    loading: state.loading,
                                    hasAvailability:
                                        (day) =>
                                            _findForDate(items, day) != null,
                                    onDaySelected: (day, focused) async {
                                      setState(() {
                                        _selectedDay = day;
                                        _focusedDay = focused;
                                      });

                                      final existing = _findForDate(items, day);

                                      final mState =
                                          context.read<AdminShiftBloc>().state;
                                      final orgs =
                                          (mState is ShiftMastersLoaded)
                                              ? mState.masters.organizations
                                              : <OrganizationDto>[];

                                      await showAddAvailabilityDialog(
                                        context: context,
                                        organizations: orgs,
                                        initialOrganiz: _orgId,
                                        initialDate: day,
                                        existing: existing,
                                      );
                                    },
                                    onPageChanged: (focused) {
                                      setState(() => _focusedDay = focused);
                                      _loadMonth();
                                    },
                                    bottomPanel: AvailabilityBottomPanel(
                                      selectedDay: _selectedDay,
                                      entity: selectedEntity,
                                      selectedOrgId: _orgId,
                                      onRemove: (e) {
                                        context.read<AvailabilityBloc>().add(
                                          DeleteAvailabilityForDate(
                                            date: e.date,
                                            organiz: e.organiz,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  flex: isShort ? 4 : 5,
                                  child: AvailabilityListCard(
                                    items:
                                        items.where((e) {
                                          if (_orgId == null) return true;
                                          return e.organiz == _orgId;
                                        }).toList(),
                                    onEdit: (e) async {
                                      setState(() {
                                        _selectedDay = e.date;
                                        _focusedDay = e.date;
                                      });

                                      final mState =
                                          context.read<AdminShiftBloc>().state;
                                      final orgs =
                                          (mState is ShiftMastersLoaded)
                                              ? mState.masters.organizations
                                              : <OrganizationDto>[];

                                      await showAddAvailabilityDialog(
                                        context: context,
                                        organizations: orgs,
                                        initialOrganiz: e.organiz,
                                        initialDate: e.date,
                                        existing: e,
                                      );
                                    },
                                    onRemove: (e) {
                                      context.read<AvailabilityBloc>().add(
                                        DeleteAvailabilityForDate(
                                          date: e.date,
                                          organiz: e.organiz,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
