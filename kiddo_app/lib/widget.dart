//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter/material.dart';

class CustomPrimaryContainer extends StatelessWidget {
  // 1. Define the properties
  final Color forgroundColor; // A function with no arguments
  final Color backgroundColor;
  final double height;
  final double width;
  final double border;
  final Widget? child;
  final double curve;
  final double extension;

  // 2. Add them to the constructor
  const CustomPrimaryContainer({
    super.key,
    required this.forgroundColor, // "required" means you MUST provide this
    required this.backgroundColor,
    required this.height,
    required this.width,
    required this.border,
    required this.curve,
    required this.extension,
    this.child,
    // Default value if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: height + extension,
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            color: backgroundColor, // Use the passed-in color
            borderRadius: BorderRadius.circular(curve),
          ),
        ),

        Container(
          height: height,
          width: width,
          //padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Where the gradient starts and ends
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,

              // The colors you want to mix
              colors: [
                forgroundColor.withOpacity(0.3),
                const Color.fromARGB(255, 238, 238, 238).withOpacity(0.8),
              ],

              // Optional: Where the colors transition (0.0 to 1.0)
              // stops: [0.2, 0.8],
            ), // Use the passed-in color
            borderRadius: BorderRadius.circular(curve),
          ),
          child: Padding(
            padding: EdgeInsets.all(border),
            child: Container(
              decoration: BoxDecoration(
                color: forgroundColor, // Use the passed-in color
                borderRadius: BorderRadius.circular(curve),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final Color forgroundColor1; // A function with no arguments
  final Color forgroundColor2; // A function with no arguments
  final Color backgroundColor;
  final double height;
  final double width;
  final double curve;
  final String text;
  final double extension;
  final double border;
  final double fontSize;
  final Color fontColor;

  const PrimaryButton({
    super.key,
    required this.forgroundColor1,
    required this.forgroundColor2,
    required this.backgroundColor,
    required this.height,
    required this.width,
    required this.curve,
    required this.text,
    required this.extension,
    required this.border,
    required this.fontSize,
    required this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height + extension,
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(curve),
          ),
        ),
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [forgroundColor1, forgroundColor2],
            ),
            borderRadius: BorderRadius.circular(curve),
            border: BoxBorder.all(width: border, color: forgroundColor1),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'dongle',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: fontColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
