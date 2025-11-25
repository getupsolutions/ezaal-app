import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back,
    this.onLeadingPressed,
    this.actions,
    this.elevation = 4.0,
    this.bottom,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize {
    // ✅ Adjust height dynamically if TabBar or bottom widget exists
    double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: true,
      bottom: bottom,
      leading:
          leadingIcon != null
              ? IconButton(
                icon: Icon(
                  leadingIcon,
                  size: screenHeight * 0.030,
                  color: kWhite,
                ),
                onPressed: onLeadingPressed ?? () => Navigator.pop(context),
              )
              : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenHeight * 0.020,
          fontWeight: FontWeight.bold,
          color: kWhite,
        ),
      ),
      actions: actions,
    );
  }
}
