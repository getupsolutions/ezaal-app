import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';

class ShiftCardWidget extends StatelessWidget {
  const ShiftCardWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.time,
    required this.date,
    required this.agencyName,
    this.duration,
    required this.notes,
    required this.location,
    this.buttonText = 'Claim Shift',
    this.onButtonPressed,
    this.isPending = false,
  });

  final double screenHeight;
  final double screenWidth;
  final String time;
  final String date;
  final String agencyName;
  final String? duration;
  final String notes;
  final String location;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * 0.02,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: screenHeight * 0.02,
                color: kBlack,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(fontWeight: FontWeight.w600, color: kBlack),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Row(
            children: [
              Icon(Icons.apartment, size: screenHeight * 0.02),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  agencyName,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.coffee, size: screenHeight * 0.02),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    (duration?.isNotEmpty ?? false)
                        ? duration!
                        : 'Duration not available',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.04,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isPending ? Colors.grey : primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isPending ? null : onButtonPressed,
                  child: Text(
                    isPending ? 'Shift Pending' : buttonText,
                    style: TextStyle(
                      fontSize: screenHeight * 0.011,
                      color: kWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            notes,
            style: TextStyle(color: kGrey, fontWeight: FontWeight.normal),
          ),
          Text(location),
        ],
      ),
    );
  }
}
