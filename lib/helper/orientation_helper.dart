import 'package:flutter/material.dart';

class OrientationHelper {
  final BuildContext context;

  OrientationHelper(this.context);

  // ScreenSize.width >= 600

  /// Return true if the screen is tablet size or larger (>=600px width)
  bool isTablet() {
    return MediaQuery.of(context).size.width >= 600;
  }

  bool isPotrait() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait;
  }

  double width() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;
  }

  double height() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.height;
  }

  // UI Space Area
  double getViewHeightOverall() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.9
        : MediaQuery.of(context).size.height * 0.9;
  }

  double getSelectedWidthOverall() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;
  }

  double getSelectedHeightOverall() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.15
        : MediaQuery.of(context).size.height * 0.25;
  }

  // // Table Area
  // double getTableColumnWidth() {
  //   Orientation orientation = MediaQuery.of(context).orientation;
  //   return orientation == Orientation.portrait
  //       ? MediaQuery.of(context).size.width*0.9
  //       : MediaQuery.of(context).size.width*0.7;
  // }

  // double getTableColumnHeight() {
  //   Orientation orientation = MediaQuery.of(context).orientation;
  //   return orientation == Orientation.portrait
  //       ? MediaQuery.of(context).size.height
  //       : MediaQuery.of(context).size.height;
  // }

  // double getTableHeight() {
  //   Orientation orientation = MediaQuery.of(context).orientation;
  //   return orientation == Orientation.portrait
  //       ? MediaQuery.of(context).size.height * 0.35
  //       : MediaQuery.of(context).size.height * 0.45;
  // }

  // EdgeInsets getTableMargin() {
  //   Orientation orientation = MediaQuery.of(context).orientation;
  //   return orientation == Orientation.portrait
  //       ? const EdgeInsets.all(0.0) // Adjust as needed for portrait mode
  //       : const EdgeInsets.only(bottom: 5); // Adjust as needed for landscape mode
  // }

  // Button Area
  double getButtonHeight() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.04
        : MediaQuery.of(context).size.height * 0.08;
  }

  // Popup Message Area
  double getPopupMessageHeight() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.3
        : MediaQuery.of(context).size.height * 0.5;
  }

  double getPopupMessageHeightButton() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.2
        : MediaQuery.of(context).size.height * 0.4;
  }

  double getPopupMessageWidthButton() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width * 0.7
        : MediaQuery.of(context).size.width * 0.6;
  }

  EdgeInsets getPopupMessagePadding() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? const EdgeInsets.all(0.0) // Adjust as needed for portrait mode
        : const EdgeInsets.all(0.0); // Adjust as needed for landscape mode
  }

  EdgeInsets getPopupMessageMargin() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? const EdgeInsets.only(bottom: 20, top: 10) // Margin for portrait mode
        : const EdgeInsets.only(
            bottom: 20, top: 10); // Margin for landscape mode
  }
}
