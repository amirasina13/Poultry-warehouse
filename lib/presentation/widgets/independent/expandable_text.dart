import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/config.dart';
import '../../../custom_page_route.dart';
import '../../../helper/helper.dart';
import '../../features/good_issue/good_issue.dart';
import '../../features/good_receive/good_receive.dart';
import 'independent.dart';

class ExpandableBox extends StatefulWidget {
  final Map<dynamic, dynamic> data;
  final String jobType;
  final Widget endButton;

  const ExpandableBox({
    Key? key,
    required this.data,
    required this.jobType,
    this.endButton = const SizedBox(),
  }) : super(key: key);

  @override
  State<ExpandableBox> createState() => _ExpandableBoxState();
}

class _ExpandableBoxState extends State<ExpandableBox>
    with TickerProviderStateMixin {
  bool _isExpanded = true;
  late Map<String, String> fieldConfig;
  late Map<String, dynamic> fieldMapping;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    // context.watch<LanguageController>();

    // Define config (API key -> label)
    if (widget.jobType == 'GIN') {
      fieldConfig = {
        "t_type": "type".tr(),
        "d_time": "joDate".tr(),
        "pl_no": "pickingListNo".tr(),
        "fl_name": "locationFrom".tr(),
        "fa_name": "areaFrom".tr(),
        "remark": "remark".tr(),
        "tl_name": "locationTo".tr(),
        "ta_name": "areaTo".tr(),
      };
    } else {
      fieldConfig = {
        "t_type": "type".tr(),
        "d_time": "joDate".tr(),
        "s_document": "document".tr(),
        "fl_name": "locationFrom".tr(),
        "fa_name": "areaFrom".tr(),
        "remark": "remark".tr(),
        "tl_name": "locationTo".tr(),
        "ta_name": "areaTo".tr(),
      };
    }

    // Build mapping (Label -> Value)
    fieldMapping = fieldConfig.map(
      (key, label) => MapEntry(label, widget.data[key]),
    );

    final labels = fieldMapping.keys.toList();
    final visibleLabels = _isExpanded ? labels : labels.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.greyShade300),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 1),
                    curve: Curves.easeInOut,
                    child: Wrap(
                      spacing: 20, // Horizontal space between columns
                      runSpacing: 15,
                      children: visibleLabels.map((label) {
                        final value = fieldMapping[label] ?? "";

                        final totalAvailableWidth =
                            device.width() - (device.width() * 0.08);

                        double width;

                        // make all column have same width
                        width = totalAvailableWidth * 0.31;

                        return SizedBox(
                          width: width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextUIDisplay(
                                labelText: label,
                                fontSize: AppSettings.fontSizeMain,
                                color: Colors.grey[600],
                              ),
                              TextUIDisplay(
                                labelText: fieldMapping[label] == null
                                    ? ''
                                    : value.toString().isNotEmpty
                                        ? value.toString()
                                        : '-',
                                fontWeight: FontWeight.bold,
                                fontSize: AppSettings.fontSizeSubtitle,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (labels.length > 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: TextUIDisplay(
                              labelText: _isExpanded
                                  ? "showLessBtn".tr().toUpperCase()
                                  : "viewMoreBtn".tr().toUpperCase(),
                              fontSize: AppSettings.fontSizeMain,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editBtn,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ButtonUIDisplay(
                            labelText: 'editJob'.tr(),
                            fontSize: AppSettings.fontSizeMain,
                            backgroundColor: AppColors.editBtn,
                            icon: Icon(
                              Icons.edit,
                              color: AppColors.white,
                              size: 20,
                            ),
                            height: device.height() / 24,
                            // width: device.isTablet()
                            //     ? device.width() * 0.2
                            //     : device.width() * 0.29,
                            onPressed: widget.jobType == 'GIN'
                                ? () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      NoAnimationPageRoute(
                                          builder: (context) =>
                                              GINCreateJobView(
                                                pageTitle: 'edit'.tr(),
                                              )),
                                      (route) => false,
                                    );
                                  }
                                : () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      NoAnimationPageRoute(
                                          builder: (context) =>
                                              GRNCreateJobView(
                                                pageTitle: 'edit'.tr(),
                                              )),
                                      (route) => false,
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            widget.endButton,
          ],
        ),
      ),
    );
  }
}
