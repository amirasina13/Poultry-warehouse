import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import '../independent/independent.dart';

class RestoreListview extends StatelessWidget {
  final List<dynamic> cardItemList;
  final List<dynamic> itemMappingList;
  final Color? backgroundColor;
  final double? borderCircular;
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? subtitleFontWeight;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final VoidCallback onTap;
  final int? widerColumnIndex;
  final List<int> rowPattern;
  final int cardIndex;

  const RestoreListview({
    super.key,
    required this.cardItemList,
    required this.itemMappingList,
    this.backgroundColor,
    this.borderCircular = 8,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 8,
    this.titleFontSize = AppSettings.fontSizeMain,
    this.subtitleFontSize = AppSettings.fontSizeMain,
    this.titleFontWeight = FontWeight.w300,
    this.subtitleFontWeight = FontWeight.w600,
    this.scaffoldKey,
    required this.onTap,
    this.widerColumnIndex,
    required this.rowPattern,
    this.cardIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    String notesValue = '';

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: device.height() * 0.01),
      color: backgroundColor ?? AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderCircular!),
        side: const BorderSide(
          color: Color(0xFFe3e3e4),
          width: 1,
        ),
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderCircular!),
                    bottomLeft: Radius.circular(borderCircular!),
                  )),
              alignment: Alignment.center,
              child: Text(
                '${cardIndex + 1}', // Replace with your card index variable
                style: const TextStyle(
                  fontSize: 15,
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
              // right: device.width() * 0.01,
              top: device.width() * 0.02,
              bottom: device.width() * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: mainAxisSpacing!, // Vertical spacing between rows
                  spacing:
                      crossAxisSpacing!, // Horizontal spacing between items
                  children: List.generate(itemMappingList.length, (index) {
                    final field = itemMappingList[index];

                    if (field["label"] == 'notes'.tr()) {
                      notesValue =
                          field["value"].isEmpty ? '-' : field["value"];
                      return const SizedBox.shrink();
                    }

                    // calculate base width (Total available width minus padding/spacing)
                    final totalAvailableWidth = device.width() -
                        (device.width() * 0.08) -
                        (crossAxisSpacing! * 2);

                    final row = getRow(index, rowPattern);
                    final colIndex = getColumnIndex(index, rowPattern);

                    // Define Widths (e.g., 40% for the first column, 30% for others)
                    double itemWidth = 0.0;
                    // int currentColumn = index % 3;
                    final colCount = rowPattern[row % rowPattern.length];

                    if (colCount <= 2) {
                      if (colCount == 1) {
                        // last column slightly wider (optional)
                        itemWidth = totalAvailableWidth;
                      } else {
                        itemWidth = totalAvailableWidth * 0.4;
                      }
                    }

                    // CASE 2: 3 columns
                    else if (colCount == 3) {
                      if (widerColumnIndex != null) {
                        // your original logic (priority)
                        if (colIndex == widerColumnIndex) {
                          itemWidth = totalAvailableWidth * 0.3;
                        } else {
                          itemWidth = totalAvailableWidth * 0.25;
                        }
                      } else {
                        // fallback to your previous design
                        itemWidth = totalAvailableWidth * 0.31;
                      }
                    }

                    return SizedBox(
                      width: itemWidth,
                      child: _buildColumn(
                        field["label"]!,
                        field["value"]!,
                        device,
                      ),
                    );
                  }),
                ),
                // const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _buildColumn(
                        'notes'.tr(),
                        notesValue,
                        device,
                      ),
                    ),
                    SizedBox(height: device.height() * 0.04),
                    Padding(
                      padding: EdgeInsets.only(right: device.width() * 0.02),
                      child: ButtonUIDisplay(
                        labelText: 'restore'.tr(),
                        fontSize: AppSettings.fontSizeMain,
                        backgroundColor: AppColors.restoreBtn,
                        icon: Icon(
                          Icons.restore,
                          color: AppColors.white,
                          size: 20,
                        ),
                        width: device.isTablet()
                            ? device.width() * 0.2
                            : device.width() * 0.29,
                        height: device.height() / 30,
                        onPressed: onTap,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String label, String value, OrientationHelper device) {
    Color textColor = Colors.black;

    if (label == "Status") {
      switch (value.toLowerCase()) {
        case "pending":
          textColor = AppColors.mainColor;
          value = "jobStatusPending".tr();
          break;
        case "complete":
        case "completed":
          textColor = AppColors.addBtn;
          value = "jobStatusCompleted".tr();
          break;
        case "ongoing":
          textColor = AppColors.mainColor;
          value = "jobStatusInProgress".tr();
          break;
        default:
          textColor = AppColors.black;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUIDisplay(
          labelText: label.tr(),
          fontSize: device.isTablet() ? AppSettings.fontSizeMain : 10,
        ),
        TextUIDisplay(
          labelText: value,
          fontSize: device.isTablet() ? AppSettings.fontSizeSubtitle : 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ],
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
}
