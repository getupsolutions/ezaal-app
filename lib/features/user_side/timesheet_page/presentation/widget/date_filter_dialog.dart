import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterDialog extends StatefulWidget {
  final Function(String startDate, String endDate) onApplyFilter;

  const DateFilterDialog({super.key, required this.onApplyFilter});

  @override
  State<DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<DateFilterDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilter() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    widget.onApplyFilter(startDateStr, endDateStr);
    Navigator.pop(context);
  }

  void _setLastWeek() {
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      _startDate = now.subtract(const Duration(days: 7));
    });
  }

  void _setLastMonth() {
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      _startDate = DateTime(now.year, now.month - 1, now.day);
    });
  }

  void _setLastThreeMonths() {
    final now = DateTime.now();
    setState(() {
      _endDate = now;
      _startDate = DateTime(now.year, now.month - 3, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.filter_list, color: Color(0xff0c2340)),
          SizedBox(width: 8),
          Text('Filter by Date'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Filters
            const Text(
              'Quick Filters:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickFilterChip('Last Week', _setLastWeek),
                _buildQuickFilterChip('Last Month', _setLastMonth),
                _buildQuickFilterChip('Last 3 Months', _setLastThreeMonths),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Custom Date Selection
            const Text(
              'Custom Date Range:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Start Date
            InkWell(
              onTap: _selectStartDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startDate == null
                                ? 'Select start date'
                                : DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_startDate!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  _startDate == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              color:
                                  _startDate == null
                                      ? Colors.grey.shade500
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // End Date
            InkWell(
              onTap: _selectEndDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endDate == null
                                ? 'Select end date'
                                : DateFormat('MMM dd, yyyy').format(_endDate!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  _endDate == null
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              color:
                                  _endDate == null
                                      ? Colors.grey.shade500
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyFilter,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0c2340),
          ),
          child: const Text(
            'Apply Filter',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(color: Colors.blue.shade700),
      side: BorderSide(color: Colors.blue.shade200),
    );
  }
}
