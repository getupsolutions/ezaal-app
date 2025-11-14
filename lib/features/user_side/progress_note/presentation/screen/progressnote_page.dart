import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ProgressnotePage extends StatefulWidget {
  const ProgressnotePage({super.key});

  @override
  State<ProgressnotePage> createState() => _ProgressnotePageState();
}

class _ProgressnotePageState extends State<ProgressnotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Progress Note",
        backgroundColor: primaryDarK,
      ),
    );
  }
}
