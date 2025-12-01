import 'package:flutter/material.dart';

class ViewRequestDialog extends StatelessWidget {
  const ViewRequestDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isSmallScreen = screenWidth < 600;

          return Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenWidth * 0.95 : 600,
              maxHeight: screenHeight * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(context),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateAndOrganization(isSmallScreen),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            icon: Icons.access_time,
                            text: 'Break: 30 Minutes',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.person,
                            text: 'Staff: Hushanpreet KAUR',
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.location_on,
                            text:
                                'Location: 142 Cornish Street Castlemaine 3450',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            text:
                                'Accepted date: 25 November 2025 07:47 PM Hushanpreet KAUR',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildNotes(),
                          const SizedBox(height: 24),
                          _buildClockDetails(isSmallScreen),
                          const SizedBox(height: 24),
                          _buildAuthorisedPersonDetails(isSmallScreen),
                          const SizedBox(height: 20),
                          _buildActionButtons(isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                ),

                // Close button
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'View request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndOrganization(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wed 26 November 2025',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '07:00 to 15:30',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Dhelkaya Health',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'PCA',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, color: color)),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Notes: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'Thompson',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildClockDetails(bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clock in Details:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildClockDetailItem('Time', '06:58', 'ontime'),
                  const SizedBox(height: 8),
                  _buildClockDetailItem('Notes', '-', null),
                ],
              ),
            ),
            if (!isSmallScreen) const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clock out Details:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildClockDetailItem('Time', '15:26', 'ontime'),
                  const SizedBox(height: 8),
                  _buildClockDetailItem('Notes', '-', null),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClockDetailItem(String label, String value, String? badge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: badge != null ? Colors.blue : Colors.black87,
            fontWeight: badge != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorisedPersonDetails(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Authorised Person details:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: {
            0: FixedColumnWidth(isSmallScreen ? 120 : 180),
            1: const FlexColumnWidth(),
          },
          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
          children: [
            _buildTableRow('Name', 'Bree dannatt', hasSignature: true),
            _buildTableRow('Designation', 'Anum'),
            _buildTableRow('Break Taken', '30 Minutes'),
            _buildTableRow('Department', 'Thompson House'),
            _buildTableRow('Total hours worked', '07:58:16 hour(s)'),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(
    String label,
    String value, {
    bool hasSignature = false,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              if (hasSignature)
                const Text(
                  'BD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check_box, size: 18),
          label: const Text('Modify Clockin/Clockout timings'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD81B60),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check_box, size: 18),
          label: const Text('Approved / Unapproved'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

// Function to show the dialog
void showViewRequestDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const ViewRequestDialog());
}
