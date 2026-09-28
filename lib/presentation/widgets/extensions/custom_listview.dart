import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import '../independent/independent.dart';

class CustomListview extends StatelessWidget {
  final List<Map<String, dynamic>> itemList;
  final Color? backgroundColor;
  final double? borderCircular;
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? subtitleFontWeight;
  final VoidCallback? onTap;
  final int cardIndex;

  const CustomListview({
    super.key,
    required this.itemList,
    this.backgroundColor,
    this.borderCircular = 12,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 10,
    this.childAspectRatio = 3.3,
    this.titleFontSize = AppSettings.fontSizeTitle,
    this.subtitleFontSize = AppSettings.fontSizeSubtitle,
    this.titleFontWeight = FontWeight.normal,
    this.subtitleFontWeight = FontWeight.w700,
    this.onTap,
    this.cardIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    // context.watch<LanguageController>();

    return InkWell(
      onTap: onTap,
      child: Container(
        // padding: EdgeInsets.symmetric(
        //     horizontal: device.width() * 0.01, vertical: device.width() * 0.03),
        margin: EdgeInsets.only(bottom: device.height() * 0.01),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              // right: 0,
              left: 0,
              width: device.width() * 0.05, // Set your desired fixed width
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${cardIndex + 1}', // Replace with your card index variable
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: device.width() *
                    0.06, // Reserve space so content doesn't go under the badge
                right: device.width() * 0.01,
                top: device.width() * 0.03,
                bottom: device.width() * 0.03,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  return Wrap(
                    runSpacing: mainAxisSpacing!,
                    spacing: crossAxisSpacing!,
                    children: itemList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final pattern = [2, 2, 3, 3];

                      // Row number (0-based)
                      // final row = index ~/ 3; // since first rows are 3 columns
                      final row = getRow(index, pattern);
                      final colIndex = getColumnIndex(index, pattern);

                      double itemWidth;
                      if (pattern[row % pattern.length] == 2) {
                        // 2-column row
                        if (colIndex == 1) {
                          itemWidth = width * 0.5; // wider last item
                        } else {
                          itemWidth = width * 0.28;
                        }
                        // itemWidth = width * 0.48;
                      } else {
                        // 3-column row
                        if (colIndex == 2) {
                          itemWidth = width * 0.40; // wider last item
                        } else {
                          itemWidth = width * 0.28;
                        }
                      }

                      // COMBINE VERSION
                      // if (row == 2) {
                      //   // 👉 third row → force 2 columns only
                      //   itemWidth = width * 0.48;
                      // } else {
                      //   // 👉 rows 1 & 2 → use 3-column layout
                      //   if ((index % 3) == 2) {
                      //     // third column wider
                      //     itemWidth = width * 0.40;
                      //   } else {
                      //     // first & second column normal
                      //     itemWidth = width * 0.28;
                      //   }
                      // }

                      // // COLUMN ONLY
                      // if ((index % 3) == 2) {
                      //   // third column → make wider
                      //   itemWidth = width * 0.4;
                      // } else {
                      //   // first and second column normal
                      //   itemWidth = width * 0.28;
                      // }

                      // ROW ONLY
                      // if (row == 2) {
                      //   // 👉 third row → 2 columns only
                      //   itemWidth = width * 0.48; // ~50% each
                      // } else {
                      //   // 👉 first & second rows → 3 columns
                      //   itemWidth = width * 0.30; // ~33% each
                      // }

                      return SizedBox(
                        width: itemWidth,
                        child: buildGridItem(item['label']!, item['value']),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getRow(int index, List<int> pattern) {
    int count = 0;
    int row = 0;

    while (true) {
      int col = pattern[row % pattern.length];

      if (index < count + col) {
        return row;
      }

      count += col;
      row++;
    }
  }

  int getColumnIndex(int index, List<int> pattern) {
    int count = 0;
    int row = 0;

    while (true) {
      int col = pattern[row % pattern.length];

      if (index < count + col) {
        return index - count;
      }

      count += col;
      row++;
    }
  }

  Widget buildGridItem(String label, String value) {
    Color textColor = Colors.black;
    String displayValue = value;

    if (label == "Status") {
      final status = JobStatus.fromString(value);
      if (status != JobStatus.unknown) {
        textColor = status.textColor;
        displayValue = status.localizedName;
      }
    }

    // if (label == "Status") {
    //   switch (value.toLowerCase()) {
    //     case "pending":
    //       textColor = AppColors.pendingStatus;
    //       value = "jobStatusPending".tr();
    //       break;
    //     case "complete":
    //     case "completed":
    //       textColor = AppColors.completeStatus;
    //       value = "jobStatusCompleted".tr();
    //       break;
    //     case "ongoing":
    //       textColor = AppColors.inProgressStatus;
    //       value = "jobStatusInProgress".tr();
    //       break;
    //     case "in progress":
    //       textColor = AppColors.inProgressStatus;
    //       value = "jobStatusInProgress".tr();
    //       break;
    //     default:
    //       textColor = AppColors.black;
    //   }
    // }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUIDisplay(
          labelText: label,
          fontSize: titleFontSize!,
          fontWeight: titleFontWeight!,
        ),
        label == "Status"
            ? Container(
                decoration: BoxDecoration(
                    color: textColor, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                child: TextUIDisplay(
                  labelText: displayValue.isEmpty ? '-' : displayValue,
                  fontSize: subtitleFontSize!,
                  fontWeight: subtitleFontWeight!,
                  color: AppColors.white,
                ),
              )
            : TextUIDisplay(
                labelText: displayValue.isEmpty ? '-' : displayValue,
                fontSize: subtitleFontSize!,
                fontWeight: subtitleFontWeight!,
                color: textColor,
              ),
      ],
    );
  }
}
