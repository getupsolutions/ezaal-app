import 'dart:async';

import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_bloc.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_event.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_state.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/widget/availability_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffAvailbilityPage extends StatefulWidget {
  const StaffAvailbilityPage({super.key});

  @override
  State<StaffAvailbilityPage> createState() => _StaffAvailbilityPageState();
}

class _StaffAvailbilityPageState extends State<StaffAvailbilityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime? _lastSuccessAt;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      ),
    );
  }

  void _debouncedReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 350), _loadMonth);
  }

  List<AvailabilityEntity> _findForDate(
    List<AvailabilityEntity> items,
    DateTime day,
  ) {
    final key = AvailabilityUtils.ymd(day);
    return items.where((e) => AvailabilityUtils.ymd(e.date) == key).toList();
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    AvailabilityEntity entity,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Availability'),
            content: Text(
              'Are you sure you want to delete ${entity.shift} shift on ${AvailabilityUtils.fmtDate(entity.date)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    return result ?? false;
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
              child: BlocBuilder<AvailabilityBloc, AvailabilityState>(
                builder: (context, state) {
                  final items = state.items;
                  final selectedEntities =
                      _selectedDay == null
                          ? <AvailabilityEntity>[]
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
                                (day) => _findForDate(items, day).isNotEmpty,
                            onDaySelected: (day, focused) async {
                              setState(() {
                                _selectedDay = day;
                                _focusedDay = focused;
                              });

                              final existing = _findForDate(items, day);

                              await showAddAvailabilityDialog(
                                context: context,
                                initialDate: day,
                                existingList: existing,
                              );
                            },
                            onPageChanged: (focused) {
                              setState(() => _focusedDay = focused);
                              _loadMonth();
                            },
                            bottomPanel: AvailabilityBottomPanel(
                              selectedDay: _selectedDay,
                              entities: selectedEntities,
                              onRemove: (e) async {
                                final confirmed = await _showDeleteConfirmation(
                                  context,
                                  e,
                                );
                                if (confirmed && context.mounted) {
                                  context.read<AvailabilityBloc>().add(
                                    DeleteAvailabilityForDate(
                                      date: e.date,
                                      shift: e.shift,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: AvailabilityListCard(
                            items: items,
                            onEdit: (e) async {
                              setState(() {
                                _selectedDay = e.date;
                                _focusedDay = e.date;
                              });

                              final existing = _findForDate(items, e.date);

                              await showAddAvailabilityDialog(
                                context: context,
                                initialDate: e.date,
                                existingList: existing,
                              );
                            },
                            onRemove: (e) async {
                              final confirmed = await _showDeleteConfirmation(
                                context,
                                e,
                              );
                              if (confirmed && context.mounted) {
                                context.read<AvailabilityBloc>().add(
                                  DeleteAvailabilityForDate(
                                    date: e.date,
                                    shift: e.shift,
                                  ),
                                );
                              }
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
                                  (day) => _findForDate(items, day).isNotEmpty,
                              onDaySelected: (day, focused) async {
                                setState(() {
                                  _selectedDay = day;
                                  _focusedDay = focused;
                                });

                                final existing = _findForDate(items, day);

                                await showAddAvailabilityDialog(
                                  context: context,
                                  initialDate: day,
                                  existingList: existing,
                                );
                              },
                              onPageChanged: (focused) {
                                setState(() => _focusedDay = focused);
                                _loadMonth();
                              },
                              bottomPanel: AvailabilityBottomPanel(
                                selectedDay: _selectedDay,
                                entities: selectedEntities,
                                onRemove: (e) async {
                                  final confirmed =
                                      await _showDeleteConfirmation(context, e);
                                  if (confirmed && context.mounted) {
                                    context.read<AvailabilityBloc>().add(
                                      DeleteAvailabilityForDate(
                                        date: e.date,
                                        shift: e.shift,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            flex: isShort ? 4 : 5,
                            child: AvailabilityListCard(
                              items: items,
                              onEdit: (e) async {
                                setState(() {
                                  _selectedDay = e.date;
                                  _focusedDay = e.date;
                                });

                                final existing = _findForDate(items, e.date);

                                await showAddAvailabilityDialog(
                                  context: context,
                                  initialDate: e.date,
                                  existingList: existing,
                                );
                              },
                              onRemove: (e) async {
                                final confirmed = await _showDeleteConfirmation(
                                  context,
                                  e,
                                );
                                if (confirmed && context.mounted) {
                                  context.read<AvailabilityBloc>().add(
                                    DeleteAvailabilityForDate(
                                      date: e.date,
                                      shift: e.shift,
                                    ),
                                  );
                                }
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
          ),
        ),
      ),
    );
  }
}
