import 'package:ezaal/features/user_side/roster_page/presentation/widget/tab_view.dart';
import 'package:flutter/material.dart';

class RosterPage extends StatefulWidget {
  const RosterPage({super.key});

  @override
  State<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends State<RosterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: RosterTabView());
  }
}
