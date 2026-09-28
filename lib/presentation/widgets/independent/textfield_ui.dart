import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import 'text_ui.dart';

class TextFieldInput extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureToggleEnabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool isEnabled;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? fillColor;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool hasError;
  final String textError;
  final bool readOnly;
  final Color? readOnlyColor;
  final VoidCallback? onTap;
  final bool isLargeTextfield;
  final bool hideBorder;
  final double contentVertical;

  const TextFieldInput({
    Key? key,
    required this.labelText,
    this.hintText,
    this.controller,
    this.obscureToggleEnabled = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isRequired = false,
    this.isEnabled = true,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.fillColor,
    this.onChanged,
    this.focusNode,
    this.hasError = false,
    this.textError = '',
    this.readOnly = false,
    this.readOnlyColor,
    this.onTap,
    this.isLargeTextfield = false,
    this.hideBorder = false,
    this.contentVertical = 0.0,
  }) : super(key: key);

  @override
  State<TextFieldInput> createState() => TextFieldInputState();
}

class TextFieldInputState extends State<TextFieldInput> {
  bool _isObscured = true;
  String textHint = "";
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  // void updateLabel(String newLabel) {
  //   setState(() {
  //     localizedLabel = newLabel.tr();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var device = OrientationHelper(context);

    final bool shouldObscure =
        widget.obscureToggleEnabled ? _isObscured : false;
    return GestureDetector(
      onTap: () {
        if (widget.isEnabled && !widget.readOnly) {
          _focusNode.requestFocus();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
            decoration: BoxDecoration(
              color: widget.readOnly == true
                  ? widget.readOnlyColor ?? AppColors.greyShade200
                  : AppColors.white,
              borderRadius: !widget.hideBorder
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(10),
              border: !widget.hideBorder
                  ? Border.all(
                      color: widget.hasError
                          ? AppColors.red
                          : AppColors.greyShade300,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.labelText,
                      style: TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyShade700,
                      ),
                    ),
                    if (widget.isRequired) ...[
                      Text(
                        "*",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.deleteBtn,
                          fontFamily: "PublicSansMedium",
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height:
                      widget.isLargeTextfield ? device.height() * 0.08 : null,
                  child: TextField(
                    controller: widget.controller,
                    obscureText: shouldObscure,
                    enabled: widget.isEnabled,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    onChanged: widget.onChanged,
                    focusNode: _focusNode,
                    readOnly: widget.readOnly,
                    onTap: widget.onTap,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: AppSettings.fontSizeMain),
                    maxLines: widget.isLargeTextfield ? 4 : 1,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      isDense: true,
                      // isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: widget.contentVertical),
                      fillColor: widget.fillColor ?? AppColors.white,
                      hintStyle: TextStyle(
                        color: AppColors.greyShade600,
                        fontWeight: FontWeight.w400,
                        fontSize: AppSettings.fontSizeMain,
                      ),
                      disabledBorder: InputBorder.none,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: widget.obscureToggleEnabled
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(vertical: -4),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                              icon: Icon(
                                  _isObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.darkGrey),
                              color: AppColors.darkGrey)
                          // ? InkWell(
                          //     child: Icon(
                          //       _isObscured
                          //           ? Icons.visibility
                          //           : Icons.visibility_off,
                          //     ),
                          //     onTap: () {
                          //       setState(() {
                          //         _isObscured = !_isObscured;
                          //       });
                          //     },
                          //   )
                          : widget.suffixIcon,
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 23,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // error message
          if (widget.hasError && widget.textError.isNotEmpty)
            Container(
              alignment: Alignment.centerLeft,
              child: TextUIDisplay(
                labelText: widget.textError,
                fontSize: AppSettings.fontSizeMain,
                color: AppColors.deleteBtn,
              ),
            )
        ],
      ),
    );
  }
}
