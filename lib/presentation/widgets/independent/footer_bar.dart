import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';
import '../../../helper/orientation_helper.dart';
import '../../../helper/version_log_helper.dart';

class Footerbar extends StatefulWidget {
  final bool isFullFooter;

  const Footerbar({
    super.key,
    this.isFullFooter = false,
  });

  @override
  State<Footerbar> createState() => _FooterbarState();
}

class _FooterbarState extends State<Footerbar> {
  int _languageValue = 1;
  String? lang;

  // Initialize function
  @override
  void initState() {
    super.initState();

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

    return Container(
      // color: Colors.grey.shade200,
      height: device.height() * 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT
          widget.isFullFooter == true
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('language'.tr()),
                      PopupMenuButton<int>(
                        initialValue: _languageValue,
                        surfaceTintColor: AppColors.white,
                        onSelected: (int value) async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            _languageValue = value;
                          });

                          if (value == 1) {
                            await prefs.setString('lang', 'en');
                            // ignore: use_build_context_synchronously
                            context.setLocale(const Locale('en', 'US'));
                            lang = 'en';
                          } else if (value == 2) {
                            await prefs.setString('lang', 'ms');
                            // ignore: use_build_context_synchronously
                            context.setLocale(const Locale('ms', 'MY'));
                            lang = 'ms';
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 1,
                            child: Text('English'),
                          ),
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text('BM'),
                          ),
                        ],
                        // 1. The visible part that looks like a Dropdown
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _languageValue == 1 ? 'English' : 'BM',
                              style: const TextStyle(
                                  fontSize: AppSettings.fontSizeMain,
                                  fontWeight: FontWeight.w600),
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: AppColors.greyShade600),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: 0),

          // CENTER (always present)
          Expanded(
            child: Text(
              'developBy'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // RIGHT
          widget.isFullFooter == true
              ? Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap:
                        // EnvironmentConfig.app == 'internal'
                        //     ?
                        () {
                      buildVersion(device);
                    },
                    // : () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'buildVersion'.tr(),
                          style: TextStyle(
                            color: AppColors.linkColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          Storage().packageVersion,
                          style: TextStyle(
                            color: AppColors.linkColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: 0),
        ],
      ),
    );
  }

  //

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
}
