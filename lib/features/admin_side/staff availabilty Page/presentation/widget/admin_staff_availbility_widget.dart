import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// ---------- Filter Dialog ----------
class FilterResult {
  final int? orgId;
  final int? staffId;
  const FilterResult({required this.orgId, required this.staffId});
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    super.key,
    required this.orgs,
    required this.staff,
    required this.initialOrgId,
    required this.initialStaffId,
  });

  final List<OrganizationDto> orgs;
  final List<StaffDto> staff;
  final int? initialOrgId;
  final int? initialStaffId;

  @override
  State<FilterDialog> createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  int? _orgId;
  int? _staffId;
  String _staffQuery = "";

  @override
  void initState() {
    super.initState();
    _orgId = widget.initialOrgId;
    _staffId = widget.initialStaffId;
  }

  @override
  Widget build(BuildContext context) {
    final sortedStaff = [...widget.staff]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final filteredStaff =
        sortedStaff.where((s) {
          final q = _staffQuery.trim().toLowerCase();
          if (q.isEmpty) return true;
          return s.name.toLowerCase().contains(q);
        }).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Organization dropdown (small list -> safe)
              DropdownButtonFormField<int?>(
                initialValue: _orgId,
                decoration: const InputDecoration(
                  labelText: "Organization",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("All Organizations"),
                  ),
                  ...widget.orgs.map(
                    (o) => DropdownMenuItem<int?>(
                      value: o.id,
                      child: Text(o.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _orgId = v),
              ),

              const SizedBox(height: 12),

              // Staff search field (no overflow)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Search staff",
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _staffQuery = v),
              ),

              const SizedBox(height: 10),

              // Staff list with radio selection
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                ),
                child: ListView(
                  children: [
                    RadioListTile<int?>(
                      value: null,
                      groupValue: _staffId,
                      onChanged: (v) => setState(() => _staffId = v),
                      title: const Text(
                        "All Staff",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Divider(height: 1),
                    ...filteredStaff.map(
                      (s) => RadioListTile<int?>(
                        value: s.id,
                        groupValue: _staffId,
                        onChanged: (v) => setState(() => _staffId = v),
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (filteredStaff.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "No staff match your search.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _orgId = null;
                          _staffId = null;
                          _staffQuery = "";
                        });
                      },
                      child: const Text("Clear"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          FilterResult(orgId: _orgId, staffId: _staffId),
                        );
                      },
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- Small Filter Chip ----------
class ChipPill extends StatelessWidget {
  const ChipPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// ---------- Calendar Panel ----------
class CalendarPanel extends StatelessWidget {
  const CalendarPanel({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.loading,
    required this.hasAnyAvailability,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final bool loading;
  final bool Function(DateTime day) hasAnyAvailability;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, c) {
            const legendHeight = 64.0;
            const gapBelowCalendar = 12.0;

            const headerHeight = 52.0;
            const dowHeight = 22.0;

            final availableForCalendar = (c.maxHeight -
                    legendHeight -
                    gapBelowCalendar)
                .clamp(0.0, double.infinity);

            final rowHeight =
                ((availableForCalendar - headerHeight - dowHeight) / 6).clamp(
                  28.0,
                  54.0,
                );

            return Column(
              children: [
                SizedBox(
                  height: availableForCalendar,
                  child: Stack(
                    children: [
                      TableCalendar(
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: focusedDay,
                        selectedDayPredicate: (d) => isSameDay(selectedDay, d),
                        onDaySelected: onDaySelected,
                        onPageChanged: onPageChanged,

                        sixWeekMonthsEnforced: false,
                        shouldFillViewport: true,

                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          headerPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        daysOfWeekHeight: dowHeight,

                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: Colors.blueAccent.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, _) {
                            if (!hasAnyAvailability(day)) return null;
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          },
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
                const SizedBox(height: gapBelowCalendar),
                Container(
                  height: legendHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE3E3E3)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Green dot: at least one staff is available on that date (based on current filter).",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
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

/// ---------- List ----------
// Replace the AvailableStaffList widget in your admin_staff_availbility_widget.dart

class AvailableStaffList extends StatelessWidget {
  const AvailableStaffList({
    super.key,
    required this.selectedDay,
    required this.orgFilter,
    required this.orgs,
    required this.staff,
    required this.getAvailabilities, // Changed from getAvailability
    required this.onAddShiftForStaff,
  });

  final DateTime selectedDay;
  final int? orgFilter;
  final List<OrganizationDto> orgs;
  final List<StaffDto> staff;
  final List<AdminAvailablitEntity> Function(int staffId)
  getAvailabilities; // Changed
  final void Function(
    StaffDto staff,
    List<AdminAvailablitEntity> availabilities,
  )
  onAddShiftForStaff; // Updated

  String _orgName(int? id) {
    if (id == null) return "All Organizations";
    for (final o in orgs) {
      if (o.id == id) return o.name;
    }
    return "Organization #$id";
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = AvailabilityUtils.fmtDate(selectedDay);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Staff",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: $dateLabel  •  ${_orgName(orgFilter)}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (staff.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No staff available for selected date (with current filters).",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: staff.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = staff[i];
                    final availabilities = getAvailabilities(s.id); // Get list

                    return InkWell(
                      onTap: () => onAddShiftForStaff(s, availabilities),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE3E3E3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    availabilities.isEmpty
                                        ? "Availability saved"
                                        : AvailabilityUtils.summaryLineMultiple(
                                          context,
                                          availabilities,
                                        ),
                                    maxLines:
                                        6, // Increased to show multiple shifts
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: const [
                                Icon(Icons.add_circle_outline),
                                SizedBox(height: 2),
                                Text(
                                  "Add\nShift",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

/// ---------- Utils ----------
class AvailabilityUtils {
  static String ymd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  static String fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

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

  // ✅ NEW: Handle single availability entity with shift
  static String summaryLine(BuildContext context, AdminAvailablitEntity a) {
    String fmt(String? s) {
      final t = parseTimeOfDay(s);
      return t == null ? "" : t.format(context);
    }

    final from = fmt(a.fromtime);
    final to = fmt(a.totime);

    String timeStr = '';
    if (from.isNotEmpty && to.isNotEmpty) {
      timeStr = '$from - $to';
    }

    final base = '${a.shift}${timeStr.isNotEmpty ? ': $timeStr' : ''}';

    final note = (a.notes ?? "").trim();
    if (note.isNotEmpty) return "$base\nNotes: $note";
    return base;
  }

  // ✅ NEW: Handle multiple shifts for one staff member on one date
  static String summaryLineMultiple(
    BuildContext context,
    List<AdminAvailablitEntity> availabilities,
  ) {
    if (availabilities.isEmpty) return "No availability";
    if (availabilities.length == 1)
      return summaryLine(context, availabilities.first);

    // Sort by shift order: AM, PM, NIGHT
    final sorted = [...availabilities]..sort((a, b) {
      final shiftOrder = {'AM': 0, 'PM': 1, 'NIGHT': 2};
      return (shiftOrder[a.shift] ?? 3).compareTo(shiftOrder[b.shift] ?? 3);
    });

    final parts = sorted.map((a) => summaryLine(context, a)).toList();
    return parts.join('\n');
  }
}
