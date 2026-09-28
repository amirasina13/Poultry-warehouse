import 'package:flutter/material.dart';

import '../../../config/config.dart';

class SecondaryBar extends StatelessWidget {
  final Widget? leading;
  final Widget? end;
  final double? height;
  final EdgeInsetsGeometry? paddingBar;
  final bool isShowDivider;
  final Color? colorBox;

  const SecondaryBar({
    Key? key,
    this.leading,
    this.end,
    this.height,
    this.paddingBar,
    this.isShowDivider = true,
    this.colorBox,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyShade300),
              color: colorBox ?? AppColors.whiteBg,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const VerticalDivider(
                      thickness: 1,
                      width: 20, // Provides padding around the line
                    ),
                  ],

                  const Spacer(), // Pushes the 'end' widget to the far right

                  if (end != null) end!,
                ],
              ),
            ),
          ),
          isShowDivider == false
              ? const SizedBox()
              : const Divider(thickness: 0, height: 1, color: Colors.grey),
        ],
      ),
    );
  }
}
