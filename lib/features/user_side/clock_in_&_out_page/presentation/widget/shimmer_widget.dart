import 'package:ezaal/core/widgets/shimmer.dart';
import 'package:flutter/material.dart';

Widget buildSlotCardShimmer(double screenWidth) {
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
        // Header with time and role
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UniversalShimmer(
              width: screenWidth * 0.3,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            UniversalShimmer(
              width: 60,
              height: 24,
              borderRadius: BorderRadius.circular(12),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        const SizedBox(height: 12),

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
        const SizedBox(height: 8),

        // Address
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
        const SizedBox(height: 16),

        // Status badges
        Row(
          children: [
            UniversalShimmer(
              width: 100,
              height: 32,
              borderRadius: BorderRadius.circular(8),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            const SizedBox(width: 12),
            UniversalShimmer(
              width: 100,
              height: 32,
              borderRadius: BorderRadius.circular(8),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: UniversalShimmer(
                height: 45,
                borderRadius: BorderRadius.circular(8),
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UniversalShimmer(
                height: 45,
                borderRadius: BorderRadius.circular(8),
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
