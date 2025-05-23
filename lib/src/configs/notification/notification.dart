import 'firebase_messaging.dart';
import 'local_notification.dart';

notificationInitialed() async {
  await FirebaseCloudMessaging.initFirebaseMessaging();
  await NotificationService.init();
  await LocalNotification.setup();
}
