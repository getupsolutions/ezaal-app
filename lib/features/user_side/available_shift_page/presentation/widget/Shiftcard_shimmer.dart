import 'package:ezaal/core/widgets/shimmer.dart';
import 'package:flutter/material.dart';

Widget buildShiftCardShimmer(double screenWidth, double screenHeight) {
  return Container(
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and agency name
        Row(
          children: [
            UniversalShimmer(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(8),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UniversalShimmer(
                    width: screenWidth * 0.5,
                    height: 18,
                    borderRadius: BorderRadius.circular(4),
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                  ),
                  SizedBox(height: 6),
                  UniversalShimmer(
                    width: screenWidth * 0.3,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Time and duration
        Row(
          children: [
            UniversalShimmer(
              width: 16,
              height: 16,
              borderRadius: BorderRadius.circular(3),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            SizedBox(width: 8),
            UniversalShimmer(
              width: screenWidth * 0.4,
              height: 14,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        SizedBox(height: 12),

        // Location
        Row(
          children: [
            UniversalShimmer(
              width: 16,
              height: 16,
              borderRadius: BorderRadius.circular(3),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            SizedBox(width: 8),
            UniversalShimmer(
              width: screenWidth * 0.6,
              height: 14,
              borderRadius: BorderRadius.circular(4),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
          ],
        ),
        SizedBox(height: 12),

        // Notes
        UniversalShimmer(
          width: screenWidth * 0.8,
          height: 14,
          borderRadius: BorderRadius.circular(4),
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
        ),
        SizedBox(height: 6),
        UniversalShimmer(
          width: screenWidth * 0.6,
          height: 14,
          borderRadius: BorderRadius.circular(4),
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
        ),
        SizedBox(height: 16),

        // Button
        UniversalShimmer(
          width: double.infinity,
          height: 45,
          borderRadius: BorderRadius.circular(8),
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
        ),
      ],
    ),
  );
}
