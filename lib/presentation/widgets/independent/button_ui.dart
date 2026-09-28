import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';

/* Widget class for standardize all button.  */

class ButtonUIDisplay extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback onPressed;
  final double iconSize;
  final Color backgroundColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsets? insidePadding;
  final Widget? icon;
  final String labelText;

  const ButtonUIDisplay({
    super.key,
    this.width,
    this.height,
    required this.onPressed,
    this.icon,
    required this.backgroundColor,
    this.iconSize = 18.0,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.borderRadius = 5,
    this.insidePadding,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final device = OrientationHelper(context);

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        // height: height,
        // height: height,
        // width: width ??
        //     (device.isPotrait()
        //         ? device.width() * 0.16
        //         : device.height() * 0.2),
        height: height ??
            (device.isPotrait() ? device.height() / 22 : device.height() / 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          // border: Border.all(color: AppColors.borderColorGrey),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: insidePadding ??
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: icon != null,
                child: Padding(
                    padding: const EdgeInsets.only(right: 5), child: icon),
              ),
              Flexible(child: _buildTitle(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      labelText,
      style: theme.textTheme.labelLarge?.copyWith(
        backgroundColor: theme.textTheme.labelLarge?.backgroundColor,
        color: AppColors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }
}
