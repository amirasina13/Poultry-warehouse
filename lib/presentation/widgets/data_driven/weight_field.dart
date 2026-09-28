import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import '../independent/independent.dart';

class WeightSectionWidget extends StatelessWidget {
  final BluetoothHelper bluetoothState;
  final OrientationHelper device;
  final bool weightControl;
  final double goodsWeightMax;
  final double availableWeight;
  final TextEditingController ginBluetoothWeightController;
  final TextEditingController ginWeightController;
  final TextEditingController ginWeightNetController;
  final FocusNode bluetoothFocus;
  final ValueNotifier<double> netWeightNotifier;
  final VoidCallback onWeightChanged;
  final String jobType;
  final Widget? availableView;

  const WeightSectionWidget({
    super.key,
    required this.bluetoothState,
    required this.device,
    required this.weightControl,
    required this.goodsWeightMax,
    required this.availableWeight,
    required this.ginBluetoothWeightController,
    required this.ginWeightController,
    required this.ginWeightNetController,
    required this.bluetoothFocus,
    required this.netWeightNotifier,
    required this.onWeightChanged,
    required this.jobType,
    this.availableView = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    // context.watch<LanguageController>();
    // If weightControl is true (based on your original logic), hide the section
    if (!weightControl) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),

        TextUIDisplay(
          labelText: 'weightUpper'.tr(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),

        ValueListenableBuilder<bool>(
          valueListenable: bluetoothState.connected,
          builder: (context, isConnected, _) {
            return ValueListenableBuilder<String>(
              valueListenable: bluetoothState.weightData,
              builder: (context, weight, _) {
                if (isConnected &&
                    // !bluetoothFocus.hasFocus &&
                    ginBluetoothWeightController.text != weight) {
                  ginBluetoothWeightController.text = weight;
                }

                return FieldButton(
                  fieldSection: TextFieldInput(
                    controller: ginBluetoothWeightController,
                    labelText: 'captureWeight'.tr(),
                    // focusNode: bluetoothFocus,
                    keyboardType: TextInputType.number,
                    obscureToggleEnabled: false,
                    hideBorder: true,
                    readOnly: true,
                    readOnlyColor: AppColors.white,
                    onChanged: (value) {
                      if (!isConnected) {
                        bluetoothState.weightData.value =
                            (double.tryParse(value) ?? 0.0).toStringAsFixed(1);
                      }
                    },
                  ),
                  buttonIcon: Icons.scale_rounded,
                  buttonText: 'getWeight'.tr(),
                  onPressed: () {
                    double val =
                        double.tryParse(ginBluetoothWeightController.text) ??
                            0.0;
                    ginWeightController.text = val.toStringAsFixed(2);
                    onWeightChanged();
                    // netWeightNotifier.value =
                    //     double.parse(ginWeightController.text);
                  },
                );
              },
            );
          },
        ),
        Row(
          children: [
            // TEXTFIELD EXPECTED WEIGHT
            Expanded(
              child: Column(
                children: [
                  TextFieldInput(
                    controller: ginWeightController,
                    labelText: 'expectedWeight'.tr(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    isRequired: weightControl,
                    hintText: '0.00',
                    onChanged: (value) {
                      onWeightChanged();
                    },
                  ),
                  jobType == 'GIN'
                      ? SizedBox(
                          height: device.height() * 0.04,
                        )
                      : const SizedBox()
                ],
              ),
            ),
            // TEXTFIELD NET WEIGHT
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: netWeightNotifier,
                builder: (context, value, _) {
                  // Keep the controller text in sync with the notifier
                  ginWeightNetController.text = value.toStringAsFixed(2);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFieldInput(
                        controller: ginWeightNetController,
                        labelText: 'netWeight'.tr(),
                        obscureToggleEnabled: false,
                        readOnly: true,
                      ),
                      jobType == 'GIN'
                          ? SizedBox(
                              height: device.height() * 0.04,
                              child: availableView)
                          : const SizedBox()
                    ],
                  );
                },
              ),
            ),
          ].where((widget) => widget is! SizedBox).expand((widget) sync* {
            yield widget;
            yield const SizedBox(width: 15);
          }).toList()
            ..removeLast(),
        ),
        // const SizedBox(height: 5),
      ].where((widget) => widget is! SizedBox).expand((widget) sync* {
        yield const SizedBox(height: 5);
        yield widget;
        yield const SizedBox(height: 5);
      }).toList()
        ..removeLast(),
    );
  }
}
