import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../custom_page_route.dart';
import '../../data/local/local.dart';
import '../../helper/helper.dart';
import '../widgets/data_driven/data_driven.dart';
import '../widgets/independent/independent.dart';
import 'good_issue/good_issue.dart';
import 'good_receive/grn_create_job_view.dart';
import 'good_receive/grn_list_view.dart';
import 'good_record/good_record.dart';
import 'picking_list/picking_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // bool _isMounted = true;
  var getLocationNameItem = ApiGlobalHelper();
  List<Map<String, dynamic>> homeMenuItems = [];
  List locationList = [];
  List<Map<String, dynamic>> filteredLocations = [];

  final TextEditingController locController = TextEditingController();
  final GlobalKey<TextFieldInputState> locKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    checkLocation();
  }

  checkLocation({Future<void> Function()? navigateTo}) async {
    var device = OrientationHelper(context);

    await DBMasterLoginList().getAllLoginList().then((value) {
      if (value != null) {
        if (value.first['location_id'] == null &&
            value.first['location_name'] == null) {
          OptionDialog.show(
            context,
            title: 'location'.tr(),
            message: Text(
              'locationDialogPrompt'.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            typeDialog: 'alert',
            dialogHeight: device.height() * 0.17,
          );
        } else {
          navigateTo?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);
    context.locale;

    homeMenuItems = [
      {
        'icon': 'assets/icons/good_issue.svg',
        'title': 'Goods Issue \n(GIN)',
        'subtitle': 'ginSubtitle'.tr(),
        'onTap': () {
          checkLocation(navigateTo: () async {
            DBHomepageHelper()
                .checkJobStatus('OUT', 'ONGOING', context)
                .then((value) {
              if (value == null) {
                // Navigate
                Navigator.pushAndRemoveUntil(
                  context,
                  NoAnimationPageRoute(
                      builder: (context) => GINCreateJobView(
                            pageTitle: 'create'.tr(),
                          )),
                  (route) => false,
                );
              } else {
                // Navigate
                Navigator.pushAndRemoveUntil(
                  context,
                  NoAnimationPageRoute(
                      builder: (context) => const GINListView()),
                  (route) => false,
                );
              }
            });
          });
        }
      },
      {
        'icon': 'assets/icons/good_receive.svg',
        'title': 'Goods Receive \n(GRN)',
        'subtitle': 'grnSubtitle'.tr(),
        'onTap': () {
          checkLocation(navigateTo: () async {
            // Check if got any current job
            DBHomepageHelper()
                .checkJobStatus('IN', 'ONGOING', context)
                .then((value) {
              if (value == null) {
                // Navigate
                Navigator.pushAndRemoveUntil(
                  context,
                  NoAnimationPageRoute(
                      builder: (context) => GRNCreateJobView(
                            pageTitle: 'create'.tr(),
                          )),
                  (route) => false,
                );
              } else {
                // Navigate
                Navigator.pushAndRemoveUntil(
                  context,
                  NoAnimationPageRoute(
                      builder: (context) => const GRNListView()),
                  (route) => false,
                );
              }
            });
          });
        }
      },
      {
        'icon': 'assets/icons/picking_list.svg',
        'title': 'Picking List',
        'subtitle': 'pickingListSubtitle'.tr(),
        'onTap': () {
          checkLocation(
            navigateTo: () async {
              Navigator.push(
                context,
                NoAnimationPageRoute(
                    builder: (context) => const PickingListView()),
              );
            },
          );
        }
      },
      {
        'icon': 'assets/icons/good_records.svg',
        'title': 'Goods Records',
        'subtitle': 'goodRecordSubtitle'.tr(),
        'onTap': () {
          checkLocation(
            navigateTo: () async {
              Navigator.push(
                context,
                NoAnimationPageRoute(
                    builder: (context) => const GoodRecordView()),
              );
            },
          );
        }
      }, // add/remove dynamically
    ];

    return PoultryScaffold(
      showAppbar: true,
      showLogout: true,
      title: 'dashboard'.tr(),
      // bluetoothState: bluetoothState,
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.whiteBg,
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: AppColors.greyShade400,
                    ),
                  ),
                ),
                child: OperatorAndLocation(
                  onLocationChanged: () {
                    // setState(() {
                    //   // checkForOngoingJobs();
                    // });
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: device.height() * 0.05,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth;
                      bool isTablet = maxWidth > 600;

                      return HomeButton(
                        heightCard: !isTablet
                            ? maxWidth * 0.45
                            : device.isPotrait()
                                ? maxWidth * 0.4
                                : maxWidth * 0.3,
                        widthCard: isTablet ? maxWidth * 0.46 : maxWidth * 0.45,
                        homeItemList: homeMenuItems,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
