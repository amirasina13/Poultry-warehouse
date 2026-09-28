import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TextUIDisplay extends StatelessWidget {
  final String labelText;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;

  const TextUIDisplay({
    Key? key,
    required this.labelText,
    this.fontSize = 14, // Default size
    this.color,
    this.fontWeight = FontWeight.w500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Text(
        labelText.tr(),
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
