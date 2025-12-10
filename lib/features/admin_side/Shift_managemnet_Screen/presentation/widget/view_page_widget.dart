// ===================== UNIVERSAL WIDGETS =====================

import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';

/// Generic info row used across screens
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;
  final Color? iconColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHighlightColor = highlightColor ?? primaryColor;
    final effectiveIconColor =
        iconColor ?? (highlight ? effectiveHighlightColor : Colors.orange);

    return Row(
      children: [
        Icon(icon, size: 18, color: effectiveIconColor),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: highlight ? effectiveHighlightColor : Colors.black87,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Universal clock row with optional "type" chip
class ClockRow extends StatelessWidget {
  final String title;
  final String clockIn;
  final String clockOut;
  final String? clockInType;
  final String? clockOutType;
  final bool showChip;

  const ClockRow({
    super.key,
    required this.title,
    required this.clockIn,
    required this.clockOut,
    this.clockInType,
    this.clockOutType,
    this.showChip = true,
  });

  Widget _buildValue(String value, String? type) {
    final showType = showChip && type != null && type.isNotEmpty && type != '-';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (showType) const SizedBox(height: 4),
        if (showType)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: _buildValue(clockIn, clockInType)),
          Expanded(child: _buildValue(clockOut, clockOutType)),
        ],
      ),
    );
  }
}

/// Universal key–value table for details
class DetailsTable extends StatelessWidget {
  final List<DetailRowData> rows;
  final double titleColumnWidth;
  final bool dense;

  const DetailsTable({
    super.key,
    required this.rows,
    this.titleColumnWidth = 130,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final titlePadding = dense ? 8.0 : 10.0;
    final valuePadding = dense ? 8.0 : 10.0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children:
            rows.map((row) {
              final isLast = row == rows.last;
              return Container(
                decoration: BoxDecoration(
                  border:
                      isLast
                          ? null
                          : Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: titleColumnWidth,
                      padding: EdgeInsets.all(titlePadding),
                      color: Colors.grey[100],
                      child: Text(
                        row.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(valuePadding),
                        child: Text(
                          row.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// Simple data holder for DetailsTable
class DetailRowData {
  final String title;
  final String value;

  DetailRowData({required this.title, required this.value});
}
