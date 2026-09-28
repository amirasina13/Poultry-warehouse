import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../helper/helper.dart';
import '../extensions/extensions.dart';
import '../independent/independent.dart';

class DrawerListview extends StatelessWidget {
  final List<dynamic> transactions;
  final String? pickingList;

  const DrawerListview({
    super.key,
    required this.transactions,
    this.pickingList = '',
  });

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    // context.watch<LanguageController>();

    final fieldMapping = {
      "status": "status".tr(),
      // "sku": "sku".tr(),
      "desc": "skuNameCode".tr(),
      "exp_date": "expireDate".tr(),
      "batch_no": "prodBatchNo".tr(),
      "qty": "quantity".tr(),
      "weight": "weight".tr(),
      "brand_name": "brand".tr(),
      "rack_name": "rack".tr(),
    };

    return Drawer(
      width: device.width() * 0.75,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: device.isTablet()
                  ? device.isPotrait()
                      ? device.height() * 0.12
                      : device.height() * 0.15
                  : device.height() * 0.12,
              width: device.width(),
              color: AppColors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextUIDisplay(
                labelText: pickingList!,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'noItem'.tr(),
                          style: const TextStyle(
                            fontSize: AppSettings.fontSizeTitle,
                            fontFamily: "PublicSansMedium",
                            color: Color(0xff6C707B),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final item = transactions[index];

                          final changeValue = {
                            "status": (String value) {
                              var statusMapping = {
                                '1': 'jobStatusPending'.tr(),
                                '2': 'jobStatusInProgress'.tr(),
                                '3': 'jobStatusCompleted'.tr(),
                              };
                              return statusMapping[value] ?? value;
                            },
                            // "weight_uom_unit": (String value) {
                            //   return value.toUpperCase(); // example: "kg" → "KG"
                            // },
                            // you can add more here later
                          };

                          final fields = fieldMapping.entries.map((entry) {
                            var value = item[entry.key] ?? "";

                            // apply transformer if exists
                            if (changeValue.containsKey(entry.key)) {
                              value = changeValue[entry.key]!(value.toString());
                            }

                            if (entry.key == 'qty') {
                              value =
                                  '${item[entry.key] ?? ''} ${item['qty_uom_unit'] ?? ''}';
                            } else if (entry.key == 'weight') {
                              value =
                                  '${item[entry.key] ?? ''} ${item['weight_uom_unit'] ?? ''}';
                            } else if (entry.key == 'desc') {
                              value =
                                  '${item[entry.key]}/ ${item['sku'] ?? ''}';
                            } else if (entry.key == 'exp_date') {
                              value = DateTimeParser()
                                  .parseDate(item[entry.key] ?? '');
                            }

                            return {
                              "label": entry.value,
                              "value": value,
                            };
                          }).toList();

                          return CustomListview(
                            itemList: fields,
                            onTap: () {},
                            cardIndex: index,
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
