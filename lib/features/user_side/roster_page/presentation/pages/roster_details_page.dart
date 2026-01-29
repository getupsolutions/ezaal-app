import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/roster_entity.dart';

class RosterDetailsPage extends StatelessWidget {
  final RosterEntity roster;

  const RosterDetailsPage({super.key, required this.roster});

  String _formatDisplayDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _formatDisplayDate(roster.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        title: 'Roster Details',
        backgroundColor: primaryDarK,
        elevation: 2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryDarK,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roster.organizationName.isEmpty
                        ? 'Organization'
                        : roster.organizationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$displayDate • ${roster.day}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _infoTile(
              icon: Icons.access_time,
              title: 'Shift Time',
              value: roster.time,
            ),
            _infoTile(
              icon: Icons.badge_outlined,
              title: 'Designation',
              value: roster.designation,
            ),
            _infoTile(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: roster.location,
            ),
            _infoTile(
              icon: Icons.note_alt_outlined,
              title: 'Notes',
              value: roster.notes,
            ),
            _infoTile(
              icon: Icons.person_outline,
              title: 'Staff Name',
              value: roster.staffName,
            ),

            _infoTile(
              icon: Icons.free_breakfast_outlined,
              title: 'Break',
              value: '${roster.breakMinutes} min',
            ),

            const SizedBox(height: 10),

            // Optional: quick actions
            // If you want, you can add buttons like "Open Map", "Share", etc.
            // Keep disabled if you haven't implemented them.
          ],
        ),
      ),
    );
  }
}
