import 'package:flutter/material.dart';

class HexToColor extends Color {
  static _hexToColor(String code) {
    return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
  }

  HexToColor(final String code) : super(_hexToColor(code));
}

class AppColors {
  static final HexToColor mainColor = HexToColor('#FFC30D');
  static final HexToColor primaryColor = HexToColor('#FFC30D');
  static final HexToColor white = HexToColor('#FFFFFF');
  static final HexToColor black = HexToColor('#000000');
  static final HexToColor linkColor = HexToColor('#253238');
  static final HexToColor addBtn = HexToColor('#198754');
  static final HexToColor deleteBtn = HexToColor('#dc3545');
  static final HexToColor downloadBtn = HexToColor('#6f42c1');
  static final HexToColor editBtn = HexToColor('#0d6efd');
  static final HexToColor saveBtn = HexToColor('#20c997');
  static final HexToColor manageBtn = HexToColor('#6c757d');
  static final HexToColor clickedManageBtn = HexToColor('#cce5ff');
  static final HexToColor clickedManageHyperlink = HexToColor('#004085');
  static final HexToColor unclickedManageBtn = HexToColor('#f0f4f8');
  static final HexToColor borderColor = HexToColor('#5B656E');
  static final HexToColor royalBlue = HexToColor('#0162D7');
  static final HexToColor whiteBg = HexToColor('#f9f9f9');
  static final HexToColor red = HexToColor('#f44336');
  static final HexToColor transparent = HexToColor('#00000000');
  static final HexToColor greyShade400 = HexToColor('#bdbdbd');
  static final HexToColor darkGrey = HexToColor('#777980');
  static final HexToColor greyShade200 = HexToColor('#eeeeee');
  static final HexToColor successColor = HexToColor('#04ca53');
  static final HexToColor blueShade900 = HexToColor('#0d47a1');
  static final HexToColor greyShade600 = HexToColor('#757575');
  static final HexToColor greyShade50 = HexToColor('#fafafa');
  static final HexToColor greyShade300 = HexToColor('#e0e0e0');
  static final HexToColor greyShade700 = HexToColor('#616161');
  static final HexToColor grey = HexToColor('#9e9e9e');
  static final HexToColor borderColorGrey = HexToColor('#999999');
  static final HexToColor restoreBtn = HexToColor('#4f46e5');
  static final HexToColor inProgressStatus = HexToColor('#00cfe8');
  static final HexToColor pendingStatus = HexToColor('#82868b');
  static final HexToColor completeStatus = HexToColor('#28c76f');
}
