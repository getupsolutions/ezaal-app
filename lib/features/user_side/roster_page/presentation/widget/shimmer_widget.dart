import 'package:ezaal/core/widgets/shimmer.dart';
import 'package:flutter/material.dart';

Widget buildRosterCardShimmer(double screenWidth) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Day
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UniversalShimmer(
              width: screenWidth * 0.35,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            UniversalShimmer(
              width: 80,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Time
        Row(
          children: [
            UniversalShimmer(
              width: 20,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            const SizedBox(width: 8),
            UniversalShimmer(
              width: screenWidth * 0.4,
              height: 16,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Location
        Row(
          children: [
            UniversalShimmer(
              width: 20,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: UniversalShimmer(
                height: 16,
                borderRadius: BorderRadius.circular(4),
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
