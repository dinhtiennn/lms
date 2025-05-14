import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification.dart';
import 'notification_data.dart';

class FirebaseCloudMessaging {
  static final FirebaseMessaging instance = FirebaseMessaging.instance;

  static initFirebaseMessaging() async {
    if (Platform.isIOS) {
      await instance.requestPermission();
    }
    FirebaseMessaging.onMessage.listen((message) {
      log("OnMessage: ${message.data}");
      Platform.isAndroid ? _handler(message) : null;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("OnMessageOpenedApp: ${message.data}");
      Data payloadData = Data.fromJson(message.data);
      onClickNotification(payloadData);
    });
  }

  static _handler(RemoteMessage message) {
    if (message.notification != null) {
      Data payload = Data.fromJson(message.data);
      LocalNotification.showNotification(
          message.notification?.title, message.notification?.body, payload.toString());
    }
  }

  static onClickNotification(Data data) async {}
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Cấu hình Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Yêu cầu quyền thông báo
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Yêu cầu quyền từ Firebase Messaging
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // if (settings.authorizationStatus == AuthorizationStatus.denied) {
    //   print('🔴 Quyền thông báo bị từ chối');
    // } else if (settings.authorizationStatus == AuthorizationStatus.authorized ||
    //     settings.authorizationStatus == AuthorizationStatus.provisional) {
    //   print('✅ Quyền thông báo được cấp');
    // }

    // Yêu cầu quyền từ flutter_local_notifications
    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlatform?.requestNotificationsPermission();
  }
}
