import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:farmiera_warehouse/firebase_options_iqsb_internal.dart'
    as internal;
import 'package:farmiera_warehouse/firebase_options_wsi_staging.dart'
    as wsi_staging;
import 'package:farmiera_warehouse/firebase_options_far_staging.dart'
    as far_staging;
import 'package:farmiera_warehouse/firebase_options_far_prod.dart' as far_prod;

class EnvironmentConfig {
  static late final String apiUrl;
  static late final FirebaseOptions? firebaseOptions;
  static late final String app;
  static late final String brandName;
  static late final String drawerIcon;

  static void init() {
    const env = String.fromEnvironment('ENV');

    switch (env) {
      case 'internal':
        apiUrl = 'https://ppwms-internal.iqes.com.my/api/v2';
        firebaseOptions = internal.DefaultFirebaseOptions.currentPlatform;
        app = 'internal';
        brandName = 'IQSB';
        drawerIcon = 'assets/app_icon/iqsb.png';
        break;
      case 'farUat':
        apiUrl = 'https://ppwms-farmiera-uat.iqes.com.my/api/v2';
        firebaseOptions = internal.DefaultFirebaseOptions.currentPlatform;
        app = 'farUat';
        brandName = 'Far';
        drawerIcon = 'assets/app_icon/iqsb.png';
        break;
      case 'farStaging':
        apiUrl = 'https://ppwms-staging.farmiera.com/api/v2';
        firebaseOptions = far_staging.DefaultFirebaseOptions.currentPlatform;
        app = 'farmiera';
        brandName = 'Farmiera';
        drawerIcon = 'assets/app_icon/f_logo.jpeg';
        break;
      case 'farProd':
        apiUrl = 'https://ppwms.farmiera.com/api/v2';
        firebaseOptions = far_prod.DefaultFirebaseOptions.currentPlatform;
        app = 'farmiera';
        brandName = 'Farmiera';
        drawerIcon = 'assets/app_icon/f_logo.jpeg';
        break;
      case 'wsiStaging':
        apiUrl = 'https://ppwms-wsi.iqes.com.my/api/v2';
        firebaseOptions = wsi_staging.DefaultFirebaseOptions.currentPlatform;
        app = 'wsi';
        brandName = 'WSI';
        drawerIcon = 'assets/app_icon/wsi.png';
        break;
      case 'wsiProd':
        apiUrl = ''; //
        firebaseOptions = wsi_staging.DefaultFirebaseOptions.currentPlatform;
        app = 'wsi';
        brandName = 'WSI';
        drawerIcon = 'assets/app_icon/wsi.png';
        break;
      default:
        apiUrl = 'https://ppwms-internal.iqes.com.my/public/api/v2';
        firebaseOptions = internal.DefaultFirebaseOptions.currentPlatform;
        app = 'internal';
        brandName = 'IQSB';
        drawerIcon = 'assets/app_icon/iqsb.png';
        break;
    }

    debugPrint('Running in [$env] with API: $apiUrl');
  }
}
