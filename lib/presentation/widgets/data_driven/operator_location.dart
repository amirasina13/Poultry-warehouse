import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/config.dart';
import '../../../data/local/local.dart';
import '../../../helper/helper.dart';
import '../independent/independent.dart';

class OperatorAndLocation extends StatefulWidget {
  final VoidCallback? onLocationChanged;

  const OperatorAndLocation({Key? key, this.onLocationChanged})
      : super(key: key);

  @override
  State<OperatorAndLocation> createState() => _OperatorAndLocationState();
}

class _OperatorAndLocationState extends State<OperatorAndLocation> {
  bool isLoading = false;

  List locationList = [];
  List filteredLocations = [];

  final MenuController _menuController = MenuController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // _isMounted = true;
    getLocationFromAPI();

    _searchController.addListener(_filterLocations);
  }

  getLocationFromAPI() {
    setState(() {
      isLoading = true; // Start loading
    });

    var getLocationNameItem = ApiGlobalHelper().getLocationFromAPI();

    getLocationNameItem.then((value) {
      setState(() {
        isLoading = false;
      });

      if (value.isEmpty) {
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            isLoading = false;
          });
        });

        showErrorToast('noData'.tr(), context);
      } else {
        locationList = value;

        // List filteredData = value
        //     .where((entry) =>
        //         entry['location_type'] != 'FRM' &&
        //         entry['location_type'] != 'C-FRM' &&
        //         entry['status'].toString() == "1")
        //     .toList();

        filteredLocations = value
            .map((entry) => {
                  'location_id': entry['location_id'], // Include location_id
                  'location_code': entry['location_code'],
                  'name': entry['name'],
                  'tray_weight': entry['tray_weight'],
                })
            .toList();
      }
    }).catchError((error) {
      // FToast fToast = FToast();
      // fToast.init(context);
      showErrorToast('noConnection'.tr(), context);
    });
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredLocations = List.from(locationList);
      } else {
        filteredLocations = locationList
            .where(
                (loc) => loc['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var device = OrientationHelper(context);
    // context.watch<LanguageController>();

    const itemHeight = 48.0;
    const maxVisibleItems = 10;
    final dropdownHeight = (filteredLocations.length * itemHeight)
        .clamp(0, itemHeight * maxVisibleItems);

    Future<void> confirmChangeLocation(item) async {
      // Same-location guard: exit early if location hasn't changed
      if (item['location_id'].toString() ==
          Storage().selectedLocationID.toString()) {
        return;
      }

      var dateTime = DateTimeParser();

      // Await both database deletions to prevent race conditions
      await DBJobData().deleteAllAddJob();
      await DBGoodsData().deleteAllGoodsData();

      // Update in-memory storage state
      Storage().selectedLocationID = item['location_id'];
      Storage().selectedLocation = item['name'];
      Storage().trayWeight = ValueParser.parseDouble(item['tray_weight']);

      // Await database persistence for login details
      await DBMasterLoginList().updateLoginData(
          loginId: Storage().loginId,
          locationId: item['location_id'],
          locationName: item['name'],
          trayWeight: ValueParser.parseDouble(item['tray_weight']),
          updatedAt: dateTime.getCurrentDateTime());

      // trigger callback to refresh parent
      if (widget.onLocationChanged != null) {
        widget.onLocationChanged!();
      }

      if (mounted) {
        setState(() {});
        showGeneralToast('${'locationNow'.tr()}${item['name']}', context);
      }
    }

    Future<void> changeLocationConfirmationDialog(
        BuildContext context, item) async {
      if (item['location_id'].toString() ==
          Storage().selectedLocationID.toString()) {
        return;
      }

      await OptionDialog.show(
        context,
        title: 'location'.tr(),
        message: RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey),
            children: [
              TextSpan(
                text: 'changeLocPrompt'.tr(),
              ),
              // Item code
              TextSpan(
                text: 'changeLocProceed'.tr(),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black),
              ),
            ],
          ),
        ),
        typeDialog: 'reminder',
      ).then((value) async {
        if (value == true) {
          confirmChangeLocation(item);
        }
      });
    }

    // Operator widget
    var operatorWidget = ListTile(
      leading: SvgPicture.asset(
        'assets/icons/user.svg',
        // width: orientation == Orientation.portrait ? width * 0.08 : width * 0.2,
        height: device.isPotrait()
            ? device.height() * 0.045
            : device.height() * 0.08,
      ),
      title: Text(
        'operator'.tr(),
        maxLines: device.isPotrait() ? null : 1,
        overflow:
            device.isPotrait() ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(
          fontSize: AppSettings.fontSizeMain,
        ),
      ),
      subtitle: Text(
        Storage().loginName,
        maxLines: device.isPotrait() ? null : 1,
        overflow:
            device.isPotrait() ? TextOverflow.visible : TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(
          fontSize: AppSettings.fontSizeMain,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Location widget
    var locationWidget = LayoutBuilder(builder: ((context, constraints) {
      return MenuAnchor(
        controller: _menuController,
        style: const MenuStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
          elevation: MaterialStatePropertyAll(2),
        ),
        builder: (context, controller, child) {
          return InkWell(
            splashColor: AppColors.whiteBg,
            highlightColor: AppColors.whiteBg,
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/icons/map_loc.svg',
                height: device.isPotrait()
                    ? device.height() * 0.045
                    : device.height() * 0.08,
              ),
              title: Text(
                '${'location'.tr()}:',
                maxLines: device.isPotrait() ? null : 1,
                overflow: device.isPotrait()
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  fontSize: AppSettings.fontSizeMain,
                ),
              ),
              subtitle: Text(
                Storage().selectedLocation.isEmpty ||
                        Storage().selectedLocation == 'null'
                    ? "${'selectLocation'.tr()} "
                    : Storage().selectedLocation,
                maxLines: device.isPotrait() ? null : 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                    fontSize: AppSettings.fontSizeMain,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
          );
        },
        menuChildren: [
          Material(
            color: AppColors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: dropdownHeight + 60,
                maxWidth: constraints.maxWidth,
                minWidth: constraints.maxWidth,
              ),
              child: Column(
                //  mainAxisSize: MainAxisSize.min,
                children: [
                  // Search box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      cursorColor: AppColors.black,
                      controller: _searchController,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.black, width: 1.5),
                          ),
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.black),
                          hintText: '${'search'.tr()}...',
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.white),
                    ),
                  ),

                  if (filteredLocations.isEmpty) ...[
                    Expanded(
                        child: SizedBox(
                            height: device.height() * 0.05,
                            child: Center(child: Text('noLocation'.tr())))),
                  ] else ...[
                    // List of items
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: filteredLocations.map((item) {
                            return MenuItemButton(
                              onPressed: () async {
                                if (item == null) return;

                                var value =
                                    await DBMasterLoginList().getAllLoginList();
                                if (value != null && value.isNotEmpty) {
                                  if (value.first['location_id'] == null &&
                                      value.first['location_name'] == null) {
                                    await confirmChangeLocation(item);
                                  } else {
                                    if (!context.mounted) return;
                                    await changeLocationConfirmationDialog(
                                        context, item);
                                  }
                                }

                                _menuController.close();

                                // await DBMasterLoginList()
                                //     .getAllLoginList()
                                //     .then((value) {
                                //   if (value != null) {
                                //     if (value.first['location_id'] == null &&
                                //         value.first['location_name'] == null) {
                                //       confirmChangeLocation(item);
                                //     } else {
                                //       changeLocationConfirmationDialog(
                                //           context, item);
                                //     }
                                //   }
                                // });

                                // _menuController.close();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                // color:
                                //     item['name'] == Storage().selectedLocation
                                //         ? AppColors.saveBtn
                                //         : AppColors.white,
                                width: (!device.isTablet())
                                    ? device.width() * 0.8
                                    : !device.isPotrait()
                                        ? 600
                                        : device.width() * 0.435,
                                child: Text(
                                  item['name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: item['name'] ==
                                            Storage().selectedLocation
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: item['name'] ==
                                            Storage().selectedLocation
                                        ? AppColors.editBtn
                                        : AppColors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      );
    }));

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        color: AppColors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: operatorWidget),
            Expanded(child: locationWidget),
          ],
        )
        // child: device.isTablet()
        //     ? Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Expanded(child: operatorWidget),
        //           Expanded(child: locationWidget),
        //         ],
        //       )
        //     : Column(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: [
        //           Expanded(child: operatorWidget),
        //           Expanded(child: locationWidget),
        //         ],
        //       ),
        );
  }
}
