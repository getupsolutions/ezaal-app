import 'package:flutter/material.dart';
import 'package:ezaal/core/constant/constant.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionText;
  final VoidCallback onTap;
  final Color? color;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.actionText,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;

        // 📌 Responsive multipliers
        final isTablet = size.width > 600;
        final isDesktop = size.width > 1000;

        final iconSize =
            isDesktop
                ? size.width * 0.025
                : isTablet
                ? size.width * 0.045
                : size.width * 0.07;

        final titleFontSize =
            isDesktop
                ? size.width * 0.018
                : isTablet
                ? size.width * 0.03
                : size.width * 0.045;

        final containerHeight =
            isDesktop
                ? size.height * 0.10
                : isTablet
                ? size.height * 0.11
                : size.height * 0.12;

        return InkWell(
          onTap: onTap,
          child: Container(
            height: containerHeight,
            padding: EdgeInsets.symmetric(
              horizontal:
                  isDesktop
                      ? 40
                      : isTablet
                      ? 30
                      : 20,
              vertical:
                  isDesktop
                      ? 20
                      : isTablet
                      ? 18
                      : 16,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-5, -5),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(5, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: kWhite, size: iconSize),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kWhite,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  actionText,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize:
                        isDesktop
                            ? 18
                            : isTablet
                            ? 16
                            : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
