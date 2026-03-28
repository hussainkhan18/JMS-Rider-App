import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isIntialized => _isInitialized;

  //initailze
  Future<void> initNotification() async {
    if (_isInitialized) return;
    //android and ios settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  //notification detail
  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'JAL - Rider Connect',
      'Notification',
      channelDescription: 'Order Recived',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  //show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
    );
  }
}
