import 'package:ezaal/features/user_side/timesheet_page/domain/entity/timesheet_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimesheetCard extends StatelessWidget {
  final TimesheetEntity timesheet;

  const TimesheetCard({super.key, required this.timesheet});

  @override
  Widget build(BuildContext context) {
    final hasClockIn = timesheet.clockInTime != '-';
    final hasClockOut = timesheet.clockOutTime != '-';
    final isComplete =
        hasClockIn && hasClockOut && timesheet.hasManagerSignature;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isComplete ? Colors.purple : Colors.grey.shade300,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Date
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getHeaderColor(isComplete),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(timesheet.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _getDayOfWeek(timesheet.date),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // User Name Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.purple.shade100),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      timesheet.userName.isNotEmpty
                          ? timesheet.userName
                          : 'User Name Not Available',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scheduled Time
                  _buildInfoRow(
                    Icons.access_time,
                    'Scheduled',
                    '${timesheet.fromTime} - ${timesheet.toTime}',
                  ),
                  const SizedBox(height: 12),

                  // Organization
                  _buildInfoRow(
                    Icons.business,
                    'Facility Name',
                    timesheet.organizationName,
                  ),
                  const SizedBox(height: 12),

                  // Facility Address
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Facility Location',
                    timesheet.address,
                  ),
                  const SizedBox(height: 12),

                  // User Clock-in Location (NEW)
                  if (timesheet.userClockinLocation != null &&
                      timesheet.userClockinLocation!.isNotEmpty) ...[
                    _buildInfoRow(
                      Icons.my_location,
                      'Clock-In Location',
                      timesheet.userClockinLocation!,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Notes
                  if (timesheet.notes.isNotEmpty) ...[
                    _buildInfoRow(Icons.notes, 'Notes', timesheet.notes),
                    const SizedBox(height: 12),
                  ],

                  const Divider(),
                  const SizedBox(height: 12),

                  // Clock In/Out Times
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeBox(
                          'Clock In',
                          timesheet.clockInTime,
                          hasClockIn ? Colors.purple : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeBox(
                          'Clock Out',
                          timesheet.clockOutTime,
                          hasClockOut ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total Hours & Break
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          'Total Hours',
                          timesheet.totalHours,
                          Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatBox(
                          'Break',
                          '${timesheet.breakTime} Min',
                          Icons.free_breakfast,
                        ),
                      ),
                    ],
                  ),

                  // Manager Info (if available)
                  if (timesheet.managerName.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Manager Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Name: ${timesheet.managerName}'),
                          const SizedBox(height: 4),
                          Text('Designation: ${timesheet.managerDesignation}'),
                          if (timesheet.hasManagerSignature) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Signature Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Status Badge
                  if (isComplete) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeaderColor(bool isComplete) {
    return isComplete ? Colors.purple : const Color(0xff0c2340);
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMMM dd, yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  String _getDayOfWeek(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEEE').format(dt);
    } catch (e) {
      return '';
    }
  }
}
