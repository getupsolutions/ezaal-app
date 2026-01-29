// presentation/pages/roster_tab_view.dart
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/core/widgets/shimmer.dart';
import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/pages/roster_details_page.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/widget/roster_scedule_card.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/widget/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // ✅ Added for formatting
import '../bloc/roster_bloc.dart';

class RosterTabView extends StatefulWidget {
  const RosterTabView({super.key});

  @override
  State<RosterTabView> createState() => _RosterTabViewState();
}

class _RosterTabViewState extends State<RosterTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      Future.microtask(() {
        if (mounted) {
          context.read<RosterBloc>().add(LoadRosters());
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _hasRosterOnDate(DateTime day, List<dynamic> allRosters) {
    final dateString =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return allRosters.any((roster) => roster.date == dateString);
  }

  /// ✅ Helper: convert "yyyy-MM-dd" → "dd MMM yyyy" (day month year)
  String _formatDisplayDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      // Change this pattern if you want full month name: 'dd MMMM yyyy'
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      // Fallback to the raw value if parsing fails
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Roster',
        backgroundColor: primaryDarK,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<RosterBloc>().add(LoadRosters());
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            labelColor: kWhite,
            controller: _tabController,
            indicatorColor: kWhite,
            tabs: const [Tab(text: 'Grid & Calendar'), Tab(text: 'List View')],
          ),
        ),
      ),
      body: BlocBuilder<RosterBloc, RosterState>(
        builder: (context, state) {
          if (state is RosterLoading) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Calendar Tab Shimmer
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar Shimmer
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: UniversalShimmer(
                          height: 350,
                          borderRadius: BorderRadius.circular(10),
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                        ),
                      ),
                      // List Shimmer
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return buildRosterCardShimmer(screenWidth);
                        },
                      ),
                    ],
                  ),
                ),
                // List View Tab Shimmer
                ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return buildRosterCardShimmer(screenWidth);
                  },
                ),
              ],
            );
          }

          if (state is RosterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RosterBloc>().add(LoadRosters());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<RosterEntity> selectedRosters = [];
          List<RosterEntity> allRosters = [];
          bool hasData = false;

          if (state is RosterLoaded) {
            selectedRosters = state.filteredList;
            allRosters = state.rosterList;
            hasData = selectedRosters.isNotEmpty;
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Grid & Calendar Tab
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate:
                              (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });

                            final dateString =
                                "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

                            print('Selected date from calendar: $dateString');

                            context.read<RosterBloc>().add(
                              FilterRostersByDate(dateString),
                            );
                          },
                          eventLoader: (day) {
                            if (_hasRosterOnDate(day, allRosters)) {
                              return ['event'];
                            }
                            return [];
                          },
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            todayDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 1,
                            markerSize: 7.0,
                            markerMargin: const EdgeInsets.symmetric(
                              horizontal: 1.0,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                      ),
                    ),
                    if (hasData)
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectedRosters.length,
                        itemBuilder: (context, index) {
                          final roster = selectedRosters[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap:
                                  () => NavigatorHelper.push(
                                    RosterDetailsPage(roster: roster),
                                  ),
                              child: RosterCustomList(
                                // ✅ Date formatted as day month year
                                date: _formatDisplayDate(roster.date),
                                day: roster.day,
                                time: roster.time,
                                location: roster.location,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No roster available for this date",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Select a date with an orange dot to view roster",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // List View Tab
              hasData
                  ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: selectedRosters.length,
                          itemBuilder: (context, index) {
                            print("Count is ${selectedRosters.length}");
                            final roster = selectedRosters[index];
                            return RosterCustomList(
                              // ✅ Date formatted as day month year
                              date: _formatDisplayDate(roster.date),
                              day: roster.day,
                              time: roster.time,
                              location: roster.location,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No roster available",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDay != null
                              ? "Try selecting a different date"
                              : "No rosters found in the system",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
