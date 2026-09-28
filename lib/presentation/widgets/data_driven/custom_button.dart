import 'package:flutter/material.dart';

import '../../../config/config.dart';

class CustomRadioButtonUI<T> extends StatefulWidget {
  final List<T> options;
  final T? initialValue;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final Axis direction;

  const CustomRadioButtonUI({
    Key? key,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.initialValue,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  State<CustomRadioButtonUI<T>> createState() => _CustomRadioButtonUIState<T>();
}

class _CustomRadioButtonUIState<T> extends State<CustomRadioButtonUI<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomRadioButtonUI<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final radioWidgets = widget.options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: InkWell(
          onTap: () {
            setState(() => _selectedValue = option);
            widget.onChanged(option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.greyShade400,
              ),
              borderRadius: BorderRadius.circular(8),
              color: _selectedValue == option
                  ? AppColors.manageBtn
                  : AppColors.white,
            ),
            child: Text(
              widget.labelBuilder(option),
              style: TextStyle(
                fontSize: AppSettings.fontSizeMain,
                color: _selectedValue == option
                    ? AppColors.white
                    : AppColors.black,
                fontWeight: _selectedValue == option
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return widget.direction == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: radioWidgets,
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: radioWidgets,
            ),
          );
  }
}

class CustomRadioModel {
  final int id;
  final String name;
  final int value;

  CustomRadioModel(this.id, this.name, this.value);
}
