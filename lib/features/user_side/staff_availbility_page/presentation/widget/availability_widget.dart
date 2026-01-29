import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_bloc.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

/// =========================
/// Calendar Card (NO overflow)
/// =========================

class AvailabilityCalendarCard extends StatelessWidget {
  const AvailabilityCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.loading,
    required this.hasAvailability,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.bottomPanel,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final bool loading;
  final bool Function(DateTime day) hasAvailability;
  final Future<void> Function(DateTime selected, DateTime focused)
  onDaySelected;
  final void Function(DateTime focused) onPageChanged;
  final Widget bottomPanel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;

            // allocate top area for calendar; bottom area for panel
            final calH = (h * 0.68).clamp(140.0, h);

            // These heights are used by TableCalendar layout
            const headerH = 56.0; // safe header height
            const dowH = 20.0; // days-of-week row height
            const minRowH = 22.0;
            const maxRowH = 56.0;

            // If calendar area is too small for a month grid, switch to 2 weeks.
            final isTight = calH < (headerH + dowH + 6 * minRowH); // ~208
            final format =
                isTight ? CalendarFormat.twoWeeks : CalendarFormat.month;

            // Month view uses up to 6 rows; twoWeeks uses 2 rows.
            final rows = (format == CalendarFormat.month) ? 6 : 2;

            // Compute row height from remaining space so it NEVER overflows.
            final availableForRows = (calH - headerH - dowH).clamp(0.0, calH);
            final rowHeight = (availableForRows / rows).clamp(minRowH, maxRowH);

            return Column(
              children: [
                SizedBox(
                  height: calH,
                  child: Stack(
                    children: [
                      TableCalendar(
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: focusedDay,
                        calendarFormat: format, // ✅ adaptive (month/twoWeeks)
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.twoWeeks: '2 weeks',
                        },
                        // keep layout predictable
                        sixWeekMonthsEnforced: true,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate:
                            (day) => isSameDay(selectedDay, day),
                        onDaySelected: (d, f) => onDaySelected(d, f),
                        onPageChanged: onPageChanged,

                        // ✅ key bits that prevent overflow
                        daysOfWeekHeight: dowH,
                        rowHeight: rowHeight,

                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            if (hasAvailability(day)) {
                              return Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          headerPadding: EdgeInsets.symmetric(vertical: 6),
                          leftChevronPadding: EdgeInsets.zero,
                          rightChevronPadding: EdgeInsets.zero,
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.withAlpha(18),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      if (loading)
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0x22FFFFFF),
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ bottom panel uses remaining height and scrolls if needed
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: bottomPanel,
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

class AvailabilityBottomPanel extends StatelessWidget {
  const AvailabilityBottomPanel({
    super.key,
    required this.selectedDay,
    required this.entity,
    required this.selectedOrgId,
    required this.onRemove,
  });

  final DateTime? selectedDay;
  final AvailabilityEntity? entity;
  final int? selectedOrgId;
  final void Function(AvailabilityEntity entity) onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = selectedDay;
    final data = entity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Green dot = availability saved",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.touch_app, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              const Text(
                "Tap any date",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.event_available, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected == null
                      ? "Select a date to mark availability."
                      : (data == null
                          ? "No availability added for selected date."
                          : AvailabilityUtils.summaryLine(context, data)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (selected != null && data != null)
                TextButton(
                  onPressed: () => onRemove(data),
                  child: const Text("Remove"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AvailabilityListCard extends StatelessWidget {
  const AvailabilityListCard({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onRemove,
  });

  final List<AvailabilityEntity> items;
  final void Function(AvailabilityEntity entity) onEdit;
  final void Function(AvailabilityEntity entity) onRemove;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) => a.date.compareTo(b.date));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Marked Availability",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your saved dates and availability details.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // ✅ List takes remaining height and is scrollable
            Expanded(
              child:
                  sorted.isEmpty
                      ? const _EmptyAvailabilityState()
                      : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final a = sorted[i];
                          return _AvailabilityTile(
                            title: AvailabilityUtils.fmtDate(a.date),
                            subtitle: AvailabilityUtils.summaryLine(context, a),
                            notes: a.notes,
                            onEdit: () => onEdit(a),
                            onRemove: () => onRemove(a),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// Helpers
/// =========================

class AvailabilityUtils {
  static String ymd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  static String fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  static DateTime firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime lastDayOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0);

  static TimeOfDay? parseTimeOfDay(String? s) {
    if (s == null) return null;
    final v = s.trim();
    if (v.isEmpty) return null;
    final parts = v.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static bool validTimePair(TimeOfDay? f, TimeOfDay? t) {
    if (f == null && t == null) return true;
    if (f == null || t == null) return false;
    final fm = f.hour * 60 + f.minute;
    final tm = t.hour * 60 + t.minute;
    return tm > fm;
  }

  static String summaryLine(BuildContext context, AvailabilityEntity a) {
    final parts = <String>[];

    String fmt(String? s) {
      final t = parseTimeOfDay(s);
      return t == null ? "" : t.format(context);
    }

    if ((a.amFrom ?? "").isNotEmpty && (a.amTo ?? "").isNotEmpty) {
      parts.add("AM: ${fmt(a.amFrom)} - ${fmt(a.amTo)}");
    }
    if ((a.pmFrom ?? "").isNotEmpty && (a.pmTo ?? "").isNotEmpty) {
      parts.add("PM: ${fmt(a.pmFrom)} - ${fmt(a.pmTo)}");
    }
    if ((a.n8From ?? "").isNotEmpty && (a.n8To ?? "").isNotEmpty) {
      parts.add("N8: ${fmt(a.n8From)} - ${fmt(a.n8To)}");
    }

    final base = parts.isEmpty ? "Availability saved" : parts.join("  •  ");

    if ((a.notes ?? "").trim().isNotEmpty) {
      return "$base\nNotes: ${a.notes!.trim()}";
    }
    return base;
  }
}

/// =========================
/// Small UI widgets
/// =========================

class _EmptyAvailabilityState extends StatelessWidget {
  const _EmptyAvailabilityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.black54),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "No availability saved yet. Tap a date on the calendar to add.",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? notes;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _AvailabilityTile({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onRemove,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotes = (notes ?? "").trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: hasNotes ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.delete_outline, color: danger),
          ),
        ],
      ),
    );
  }
}

enum AvShift { am, pm, night }

Future<void> showAddAvailabilityDialog({
  required BuildContext context,
  required List<OrganizationDto> organizations,
  int? initialOrganiz,
  DateTime? initialDate,
  AvailabilityEntity? existing,
}) async {
  final df = DateFormat('dd-MM-yyyy');

  DateTime start = existing?.date ?? initialDate ?? DateTime.now();
  DateTime end = existing?.date ?? initialDate ?? DateTime.now();

  AvShift shift = AvShift.am;
  String? existingFrom;
  String? existingTo;

  int? organiz = existing?.organiz ?? initialOrganiz;

  if (existing != null) {
    if ((existing.amFrom ?? '').isNotEmpty &&
        (existing.amTo ?? '').isNotEmpty) {
      shift = AvShift.am;
      existingFrom = existing.amFrom;
      existingTo = existing.amTo;
    } else if ((existing.pmFrom ?? '').isNotEmpty &&
        (existing.pmTo ?? '').isNotEmpty) {
      shift = AvShift.pm;
      existingFrom = existing.pmFrom;
      existingTo = existing.pmTo;
    } else if ((existing.n8From ?? '').isNotEmpty &&
        (existing.n8To ?? '').isNotEmpty) {
      shift = AvShift.night;
      existingFrom = existing.n8From;
      existingTo = existing.n8To;
    }
  }

  String apiToDisplay(String? api) {
    final t = AvailabilityUtils.parseTimeOfDay(api);
    if (t == null) return "12:00 PM";
    final dt = DateTime(2020, 1, 1, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  final fromCtrl = TextEditingController(
    text: existingFrom != null ? apiToDisplay(existingFrom) : "12:00 PM",
  );
  final toCtrl = TextEditingController(
    text: existingTo != null ? apiToDisplay(existingTo) : "12:00 PM",
  );
  final notesCtrl = TextEditingController(text: existing?.notes ?? "");

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart) {
        start = picked;
        if (end.isBefore(start)) end = start;
      } else {
        end = picked;
        if (end.isBefore(start)) end = start;
      }
    }
  }

  Future<void> pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final t = await showTimePicker(context: context, initialTime: now);
    if (t == null) return;
    final dt = DateTime(2020, 1, 1, t.hour, t.minute);
    ctrl.text = DateFormat('hh:mm a').format(dt);
  }

  String? displayToApi(String? display) {
    final v = display?.trim() ?? "";
    if (v.isEmpty) return null;
    try {
      final dt = DateFormat('hh:mm a').parseStrict(v);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "$hh:$mm:00";
    } catch (_) {
      return null;
    }
  }

  bool validApiPair(String? fromApi, String? toApi) {
    final f = AvailabilityUtils.parseTimeOfDay(fromApi);
    final t = AvailabilityUtils.parseTimeOfDay(toApi);
    return AvailabilityUtils.validTimePair(f, t);
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final w = MediaQuery.of(ctx).size.width;
      final dialogW = w < 520 ? w * 0.92 : 520.0;

      InputDecoration deco(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      );

      Widget dateField(
        String label,
        String value,
        VoidCallback onTap, {
        bool enabled = true,
      }) {
        return InkWell(
          onTap: enabled ? onTap : null,
          child: IgnorePointer(
            child: TextFormField(
              decoration: deco(label).copyWith(enabled: enabled),
              initialValue: value,
            ),
          ),
        );
      }

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: dialogW,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: StatefulBuilder(
              builder: (ctx, setState) {
                final isEditing = existing != null;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isEditing
                                  ? "Edit Availability"
                                  : "Add Availability",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<int?>(
                        initialValue: organiz,
                        decoration: deco("Organization (Optional)"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("All / Not specified"),
                          ),
                          ...organizations.map(
                            (o) => DropdownMenuItem<int?>(
                              value: o.id,
                              child: Text(o.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => organiz = v),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: dateField(
                              "Start Date",
                              df.format(start),
                              () async {
                                await pickDate(true);
                                setState(() {});
                              },
                              enabled: !isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: dateField(
                              "End Date",
                              df.format(end),
                              () async {
                                await pickDate(false);
                                setState(() {});
                              },
                              enabled: !isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<AvShift>(
                        initialValue: shift,
                        decoration: deco("Shift"),
                        items: const [
                          DropdownMenuItem(
                            value: AvShift.am,
                            child: Text("AM"),
                          ),
                          DropdownMenuItem(
                            value: AvShift.pm,
                            child: Text("PM"),
                          ),
                          DropdownMenuItem(
                            value: AvShift.night,
                            child: Text("NIGHT"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => shift = v);
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await pickTime(fromCtrl);
                                setState(() {});
                              },
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: fromCtrl,
                                  decoration: deco("From time"),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await pickTime(toCtrl);
                                setState(() {});
                              },
                              child: IgnorePointer(
                                child: TextFormField(
                                  controller: toCtrl,
                                  decoration: deco("To time"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: deco("Notes"),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Close"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final fromApi = displayToApi(fromCtrl.text);
                              final toApi = displayToApi(toCtrl.text);

                              if (fromApi == null || toApi == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select From & To time.",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              if (!validApiPair(fromApi, toApi)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "To time must be after From time.",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              DateTime d = DateTime(
                                start.year,
                                start.month,
                                start.day,
                              );
                              final last = DateTime(
                                end.year,
                                end.month,
                                end.day,
                              );

                              while (!d.isAfter(last)) {
                                String? amFrom,
                                    amTo,
                                    pmFrom,
                                    pmTo,
                                    n8From,
                                    n8To;

                                if (shift == AvShift.am) {
                                  amFrom = fromApi;
                                  amTo = toApi;
                                } else if (shift == AvShift.pm) {
                                  pmFrom = fromApi;
                                  pmTo = toApi;
                                } else {
                                  n8From = fromApi;
                                  n8To = toApi;
                                }

                                final entity = AvailabilityEntity(
                                  date: d,
                                  organiz: organiz,
                                  amFrom: amFrom,
                                  amTo: amTo,
                                  pmFrom: pmFrom,
                                  pmTo: pmTo,
                                  n8From: n8From,
                                  n8To: n8To,
                                  notes:
                                      notesCtrl.text.trim().isEmpty
                                          ? null
                                          : notesCtrl.text.trim(),
                                );

                                context.read<AvailabilityBloc>().add(
                                  existing != null
                                      ? EditAvailabilityForDate(entity)
                                      : SaveAvailabilityForDate(entity),
                                );

                                d = d.add(const Duration(days: 1));
                              }

                              Navigator.pop(ctx);
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
