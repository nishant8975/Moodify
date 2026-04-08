import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientGlow extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double blurRadius;

  const AmbientGlow({
    super.key,
    required this.color,
    this.width = 200,
    this.height = 200,
    this.blurRadius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: blurRadius / 2,
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
