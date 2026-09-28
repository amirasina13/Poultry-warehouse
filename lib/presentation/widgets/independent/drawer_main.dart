import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';
import '../../../config/environment.dart';
import '../../../custom_page_route.dart';
import '../../../data/local/local.dart';
import '../../../helper/helper.dart';
import '../../features/good_issue/good_issue.dart';
import '../../features/good_receive/good_receive.dart';
import '../../features/good_record/good_record.dart';
import '../../features/home_view.dart';
import '../../features/picking_list/picking_list_view.dart';
import 'independent.dart';

class DrawerMain extends StatefulWidget {
  const DrawerMain({super.key});

  @override
  State<DrawerMain> createState() => _DrawerMainState();
}

class _DrawerMainState extends State<DrawerMain> {
  int _languageValue = 1;
  String? lang;
  // String buildVersionNum = '';

  // Initialize function
  @override
  void initState() {
    super.initState();

    // languageCheck();
    // getInfoAppAndData();
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String savedLang = prefs.getString('lang') ?? 'en';

    setState(() {
      lang = savedLang;
      _languageValue = lang == 'en' ? 1 : 2;
    });
  }

  void _changeLanguage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _languageValue = value;
    });

    if (value == 1) {
      await prefs.setString('lang', 'en');
      // ignore: use_build_context_synchronously
      context.setLocale(const Locale('en', 'US'));
      lang = 'en';
    } else {
      await prefs.setString('lang', 'ms');
      // ignore: use_build_context_synchronously
      context.setLocale(const Locale('ms', 'MY'));
      lang = 'ms';
    }
  }

  // // Get information detail
  // getInfoAppAndData() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //   String version = packageInfo.version;
  //   String buildNumber = packageInfo.buildNumber;

  //   buildVersionNum = '$version+$buildNumber';
  //   Storage().packageVersion = buildVersionNum;
  // }

  Future<List<VersionLog>> loadVersionLogs() async {
    final String response =
        await rootBundle.loadString('assets/log/version_log.json');
    // Decode the top-level list
    final List<dynamic> data = json.decode(response);
    // Map each element (which is a Map<String, dynamic>) to VersionLog
    return data.map((e) => VersionLog.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final device = OrientationHelper(context);

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                    child: Center(
                        child: Column(
                  children: [
                    Expanded(
                      child: Image(
                        image: AssetImage(EnvironmentConfig.drawerIcon),
                      ),
                    ),
                    showTestingTitle(),
                  ],
                ))),
                ListTile(
                  title: Text(
                    'dashboard'.tr(),
                    style: const TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    checkLocation(navigateTo: () async {
                      Navigator.pushAndRemoveUntil(
                        context,
                        NoAnimationPageRoute(
                            builder: (context) => const HomeView()),
                        (route) => false,
                      );
                    });
                  },
                ),
                ListTile(
                  title: const Text(
                    'Goods Issue (GIN)',
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
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
                  },
                ),
                ListTile(
                  title: const Text(
                    'Goods Receive (GRN)',
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
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
                  },
                ),
                ListTile(
                  title: const Text(
                    'Picking List',
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    checkLocation(
                      navigateTo: () async {
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                              builder: (context) => const PickingListView()),
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Goods Records',
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    checkLocation(
                      navigateTo: () async {
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                              builder: (context) => const GoodRecordView()),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            // This container holds all the children that will be aligned
            // on the bottom and should not scroll with the above ListView
            child: Column(
              children: <Widget>[
                const Divider(),
                ExpansionTile(
                  // The header of the tile
                  title: Text(
                    _languageValue == 1 ? 'English' : 'BM',
                    style: const TextStyle(
                      fontSize: AppSettings.fontSizeMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: Icon(Icons.language, color: AppColors.greyShade600),
                  shape:
                      const Border(), // Removes the default border lines when expanded
                  collapsedIconColor: AppColors.mainColor,
                  iconColor: AppColors.mainColor,
                  children: <Widget>[
                    // English Option
                    ListTile(
                      title: const Text(
                        'English',
                        style: TextStyle(
                          fontSize: AppSettings.fontSizeMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Radio<int>(
                        activeColor: AppColors.mainColor,
                        value: 1,
                        groupValue: _languageValue,
                        onChanged: (value) => _changeLanguage(value!),
                      ),
                      onTap: () => _changeLanguage(1),
                    ),
                    // BM Option
                    ListTile(
                      title: const Text(
                        'BM',
                        style: TextStyle(
                          fontSize: AppSettings.fontSizeMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Radio<int>(
                        activeColor: AppColors.mainColor,
                        value: 2,
                        groupValue: _languageValue,
                        onChanged: (value) => _changeLanguage(value!),
                      ),
                      onTap: () => _changeLanguage(2),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      buildVersion(device);
                    },
                    child: Text(
                      "${'buildVersion'.tr()}: ${Storage().packageVersion}",
                      style: const TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ListTile(
                    leading: const Icon(Icons.developer_board),
                    title: Text(
                      'developBy'.tr(),
                      style: const TextStyle(
                        fontSize: AppSettings.fontSizeMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
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

  buildVersion(OrientationHelper device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('versionLogTitle'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            height: device.height() * 0.7,
            child: FutureBuilder<List<VersionLog>>(
              future: loadVersionLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('${'error'.tr()}: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('noVersionLog'.tr()));
                } else {
                  final logs = snapshot.data!;

                  // final reversedLogs = logs.reversed.toList();

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            // '${'version'.tr()} ${reversedLogs[index].version}'),
                            '${'version'.tr()} ${logs[index].version}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: logs[index]
                              .features[lang]!
                              .map((desc) => Text("- $desc"))
                              .toList(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget showTestingTitle() {
    const env = String.fromEnvironment('ENV');
    bool isStagingEnv = env == 'farStaging' || env == 'wsiStaging';
    bool isInternalEnv = env == 'internal' || env.isEmpty;
    bool isfarUatEnv = env == 'farUat' || env.isEmpty;
    bool isProductionEnv = env == 'farProduction' || env == 'wsiProduction';

    debugPrint('ENV: $env');

    return Center(
      child: Text(
        isStagingEnv
            ? 'STAGING'
            : isInternalEnv
                ? 'INTERNAL'
                : isfarUatEnv
                    ? 'INTERNAL UAT'
                    : isProductionEnv
                        ? 'LIVE'
                        : '',
        style: TextStyle(
            fontSize: AppSettings.fontSizeMain,
            fontWeight: FontWeight.bold,
            color: AppColors.red),
      ),
    );
  }
}
