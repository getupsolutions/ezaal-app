// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVGImageView extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? boxFit;

  final Color? color;
  SVGImageView({
    required this.image,
    this.height,
    this.width,
    this.boxFit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      image,
      fit: BoxFit.cover,
      height: height,
      width: width,
      color: color,
    );
  }
}
