import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';

//Basic Custom Elevated Button

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color backgroundColor;
  final double borderRadius;
  final double widthFactor;
  final double heightFactor;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8,
    this.widthFactor = 0.9, // 90% of screen width
    this.heightFactor = 0.07, // 7% of screen height
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: screenHeight * 0.02), // Responsive text
        ),
      ),
    );
  }
}

//Custom Outlined Button

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color borderColor;
  final double borderRadius;
  final double widthFactor;
  final double heightFactor;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor = Colors.blue,
    this.borderRadius = 8,
    this.widthFactor = 0.9,
    this.heightFactor = 0.07,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: screenHeight * 0.02)),
      ),
    );
  }
}

//Custom Text Button

class CustomTextButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color textColor;
  final double fontSizeFactor;

  const CustomTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = Colors.blue,
    this.fontSizeFactor = 0.02, // Font size relative to screen height
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: screenHeight * fontSizeFactor,
        ),
      ),
    );
  }
}

//Custom Icon Button with Label

class CustomIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function()? onPressed;
  final Color backgroundColor;
  final double widthFactor;
  final double heightFactor;
  final double fontSizeFactor;
  final double iconSizeFactor;

  const CustomIconButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.widthFactor = 0.9,
    this.heightFactor = 0.07,
    this.fontSizeFactor = 0.02,
    this.iconSizeFactor = 0.03,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: screenHeight * iconSizeFactor),
        label: Text(
          label,
          style: TextStyle(fontSize: screenHeight * fontSizeFactor),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      ),
    );
  }
}

//Custom Rounded Button
class CustomRoundedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final double heightFactor;
  final double widthFactor;
  final Color? backgroundColor;
  final double borderRadius;

  const CustomRoundedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.heightFactor = 0.05,
    this.widthFactor = 0.9,
    this.backgroundColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * heightFactor,
      width: screenWidth * widthFactor,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: screenHeight * 0.02, color: kWhite),
        ),
      ),
    );
  }
}
