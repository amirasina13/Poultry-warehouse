import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';

class FieldButton extends StatelessWidget {
  final Widget fieldSection;
  final String buttonText;
  final IconData? buttonIcon;
  final VoidCallback onPressed;

  const FieldButton({
    super.key,
    required this.fieldSection,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var device = OrientationHelper(context);

    return Container(
      // Height should accommodate both the label and the text input
      height: device.height() * 0.055,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // TEXTFIELD SECTION
          Expanded(
            child: fieldSection,
          ),

          // JOINED BUTTON
          GestureDetector(
            onTap: onPressed,
            child: Container(
              height: double.infinity, // Fill the container height
              width: device.width() * 0.18,
              // padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.downloadBtn,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(buttonIcon, color: Colors.white, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
