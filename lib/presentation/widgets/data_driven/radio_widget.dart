import 'package:flutter/material.dart';

class RadioButtonUI<T> extends StatefulWidget {
  final List<T> options;
  final T? initialValue;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final Axis direction;

  const RadioButtonUI({
    Key? key,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.initialValue,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  State<RadioButtonUI<T>> createState() => _RadioButtonUIState<T>();
}

class _RadioButtonUIState<T> extends State<RadioButtonUI<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant RadioButtonUI<T> oldWidget) {
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
      return InkWell(
        onTap: () {
          setState(() => _selectedValue = option);
          widget.onChanged(option);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<T>(
              value: option,
              groupValue: _selectedValue,
              onChanged: (val) {
                setState(() => _selectedValue = val);
                widget.onChanged(val as T);
              },
            ),
            Text(widget.labelBuilder(option)),
          ],
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

class RadioOptionsModel {
  final int id;
  final String name;

  RadioOptionsModel(this.id, this.name);
}
