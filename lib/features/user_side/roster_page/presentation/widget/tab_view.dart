// presentation/pages/roster_tab_view.dart
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/widget/roster_scedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
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
    // Load rosters only once after dependencies are ready
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      // Use Future.microtask to ensure the bloc is fully initialized
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Roster',
        backgroundColor: primaryDarK,
        elevation: 2,
        // ✅ Refresh button
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
        // ✅ Custom bottom widget (TabBar)
        // We’ll pass it through PreferredSize in AppBar's bottom slot
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
            return const Center(child: CircularProgressIndicator());
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

          List<dynamic> selectedRosters = [];
          bool hasData = false;

          if (state is RosterLoaded) {
            selectedRosters = state.filteredList;
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
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                      ),
                    ),
                    // Show roster list only if data exists
                    if (hasData)
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectedRosters.length,
                        itemBuilder: (context, index) {
                          final roster = selectedRosters[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RosterCustomList(
                              date: roster.date,
                              day: roster.day,
                              time: roster.time,
                              location: roster.location,
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              "No roster available for this date",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                context.read<RosterBloc>().add(ResetFilter());
                                setState(() {
                                  _selectedDay = null;
                                });
                              },
                              child: const Text('Show All Rosters'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // List View Tab
              hasData
                  ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedRosters.length,
                    itemBuilder: (context, index) {
                      print("Count is ${selectedRosters.length}");
                      final roster = selectedRosters[index];
                      return RosterCustomList(
                        date: roster.date,
                        day: roster.day,
                        time: roster.time,
                        location: roster.location,
                      );
                    },
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "No roster available",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.read<RosterBloc>().add(ResetFilter());
                          },
                          child: const Text('Show All Rosters'),
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
