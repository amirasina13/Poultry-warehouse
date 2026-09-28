import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import 'independent.dart';

/* Widget class for standardize all button.  */
class HomeButton extends StatelessWidget {
  final double? widthCard;
  final double? heightCard;
  final List<Map<String, dynamic>> homeItemList;
  final double borderRadius;
  final Color? backgroundColor;

  const HomeButton(
      {super.key,
      required this.widthCard,
      required this.heightCard,
      required this.homeItemList,
      this.borderRadius = 12,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);

    return Wrap(
      spacing: 15, // horizontal space
      runSpacing: 15, // vertical space
      alignment: WrapAlignment.center, // center the last row
      children: List.generate(homeItemList.length, (index) {
        final item = homeItemList[index];

        // Set color based on index
        Color cardColor;
        switch (index) {
          case 0:
            cardColor = AppColors.white;
            break;
          case 1:
            cardColor = backgroundColor ?? AppColors.white;
            break;
          case 2:
            cardColor = AppColors.white;
            break;
          case 3:
            cardColor = AppColors.white;
            break;
          default:
            cardColor = backgroundColor ?? AppColors.white;
        }

        return FittedBox(
          child: SizedBox(
            width: widthCard,
            height: heightCard,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: const BorderSide(color: Colors.transparent),
              ),
              color: cardColor,
              surfaceTintColor: AppColors.white,
              elevation: 2,
              child: InkWell(
                onTap: item['onTap'],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgIcon(
                      item['icon'],
                      size: device.width() * 0.18,
                      // size: device.isTablet()
                      //     ? device.width() * 0.13
                      //     : device.width() * 0.2,
                      // color: AppColors.linkColor,
                    ),
                    ListTile(
                      title: Text(
                        item["title"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        item["subtitle"],
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
