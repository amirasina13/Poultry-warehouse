import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../../../config/config.dart';
import '../config/environment.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  EnvironmentConfig.init();

  if (EnvironmentConfig.firebaseOptions != null) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: EnvironmentConfig.firebaseOptions!,
      );
    }

    // handle the notification
    await NotificationService._showNotification(message, isBackground: true);
  } else {
    debugPrint(
        "Background message ignored: No Firebase config for this flavor.");
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static late BuildContext context;

  NotificationService._privateConstructor();

  static final NotificationService _instance =
      NotificationService._privateConstructor();

  static NotificationService get instance => _instance;

  // Callback for handling foreground message updates (optional)
  Function(RemoteMessage)? onForegroundMessage;

  Future<void> initialize() async {
    // Request permissions for iOS
    // NotificationSettings settings =
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // log('firebase :: User granted permission: ${settings.authorizationStatus}');

    // Configure Local Notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // log(
      //   'firebase :: Received a foreground message: ${message.notification!.android}',
      // );
      _showNotification(message);

      // If there's a foreground message handler, call it
      if (onForegroundMessage != null) {
        onForegroundMessage!(message);
      }
    });

    // Handle when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // log(
      //   'firebase :: Notification clicked! Message: ${message.notification?.title}',
      // );
      _handleNotificationClick(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Show local notification
  static Future<void> _showNotification(
    RemoteMessage message, {
    bool isBackground = false,
  }) async {
    String? imgUrl = message.data['image'];
    final title = message.notification?.title;
    final body = message.notification?.body;
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    // ByteArrayAndroidBitmap? largeIcon;
    // converting image into base65 to show in notification bar
    BigPictureStyleInformation? bigPictureStyleInformation;
    if (imgUrl != null) {
      try {
        final response = await http.get(Uri.parse(imgUrl));
        if (response.statusCode == 200) {
          final byteArray = response.bodyBytes;
          bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(byteArray),
            largeIcon: ByteArrayAndroidBitmap(byteArray),
            contentTitle: title,
            summaryText: body,
          );
        }
      } catch (e) {
        // print('Error fetching image: $e');
      }
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      // largeIcon: largeIcon, // This sets the small image on the right side ofnotification title
      styleInformation: bigPictureStyleInformation,
      vibrationPattern: vibrationPattern,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  // Handle notification click action
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    // log('firebase :: User tapped on notification: $message');
    // You can navigate to a specific screen using Navigator here
    // if (message.data['target'] != null) {
    //   if (message.data['target'] == 'voucher') {
    //     // sl<NavigationService>().navigatorKey.currentState?.pushNamed(
    //     //       MainRoutes.rewardDetails,
    //     //       arguments: RewardDetailsParameters(
    //     //         rewardId: int.parse(message.data['target_id']),
    //     //         title: message.data['target_title'],
    //     //         indexPage: 3,
    //     //       ),
    //     //     );
    //   }
    // }
  }

  // Called when a notification is tapped (foreground or background)
  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    // final String? payload = notificationResponse.payload;
    // final Map<String, dynamic> payloadData = jsonDecode(payload!);
    // log('firebase :: Notification payload: $payload');

    // print('NOTIFICATION MESSAGE:: $payloadData');
    // Navigate or perform an action based on the payload

    // if (payloadData['target'] != null) {
    //   if (payloadData['target'] == 'voucher') {
    //     // sl<NavigationService>().navigatorKey.currentState?.pushNamed(
    //     //       MainRoutes.rewardDetails,
    //     //       arguments: RewardDetailsParameters(
    //     //         rewardId: int.parse(payloadData['target_id']),
    //     //         title: payloadData['target_title'],
    //     //         indexPage: 3,
    //     //       ),
    //     //     );
    //   }
    // }
  }

  // Background handler (required for background notifications)
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // log('firebase :: Handling a background message: ${message.messageId}');
  }

  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    // ... your background notification logic ...
    // if (message.data['target'] != null) {
    //   // if (message.data['target'] == 'voucher') {
    //   //   sl<NavigationService>().navigatorKey.currentState?.pushNamed(
    //   //         MainRoutes.rewardDetails,
    //   //         arguments: RewardDetailsParameters(
    //   //           rewardId: int.parse(message.data['target_id']),
    //   //           title: message.data['target_title'],
    //   //           indexPage: 3,
    //   //         ),
    //   //       );
    //   // }
    // }
  }

  Future<String?> getDeviceToken() async {
    // Try to get cached token first to avoid network lag
    String? cachedToken = await Storage().secureStorage.read(key: 'push_token');

    if (cachedToken != null) {
      debugPrint('FCM TOKEN (Cached): $cachedToken');
      return cachedToken;
    }

    // If no cache, fetch from Firebase (this is the slow part)
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _saveTokenToStorage(fcmToken);
      }
      return fcmToken;
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
      return null;
    }
  }

  Future<void> _saveTokenToStorage(String token) async {
    await Storage().secureStorage.write(key: 'push_token', value: token);
    debugPrint('FCM TOKEN Saved: $token');
  }

  // // Get device token (you can send this to your server for targeted notifications)
  // Future<String?> getDeviceToken() async {
  //   String? fcmToken = await _firebaseMessaging.getToken();

  //   await Storage().secureStorage.write(key: 'push_token', value: fcmToken);
  //   debugPrint('FCM TOKEN: $fcmToken');

  //   return fcmToken;
  // }
}
