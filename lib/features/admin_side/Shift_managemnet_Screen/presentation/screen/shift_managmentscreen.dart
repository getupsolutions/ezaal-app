import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ShiftManagmentscreen extends StatefulWidget {
  const ShiftManagmentscreen({super.key});

  @override
  State<ShiftManagmentscreen> createState() => _ShiftManagmentscreenState();
}

class _ShiftManagmentscreenState extends State<ShiftManagmentscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Shift Management',
        backgroundColor: primaryDarK,
      ),
    );
  }
}
