import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_data.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;

class LocalNotification {
  static const String _id = '_ID';
  static const String _channel = '_Channel';
  static const String _description = '_Description';

  static setup() async {
    notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid = const AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          try {
            Data payloadData = Data.fromJson(jsonDecode(notificationResponse.payload!));
            switch (notificationResponse.notificationResponseType) {
              case NotificationResponseType.selectedNotification:
              case NotificationResponseType.selectedNotificationAction:
                onClickNotification(payloadData);
                break;
            }
          } catch (e) {
            debugPrint("Lỗi khi parse JSON từ payload: $e");
          }
        }
      },
    );
  }

  static Future<void> showNotification(String? title, String? body, String? payload) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(_id, _channel,
        channelDescription: _description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: 'ic_launcher'
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
        presentAlert: true);
    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await flutterLocalNotificationsPlugin.show(notificationId, title ?? 'Say hi!',
        body ?? 'Nice to meet you again!', platformChannelSpecifics,
        payload: payload);
  }

  static onClickNotification(Data data) async {}
}
