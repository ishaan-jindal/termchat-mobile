import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../router/app_router.dart';

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestSoundPermission: true,
            requestBadgePermission: true,
          ),
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    const mentionsChannel = AndroidNotificationChannel(
      'mentions_channel',
      'Mentions',
      description: 'Notifications for when you are mentioned in a room.',
      importance: Importance.max,
      playSound: true,
    );

    const messagesChannel = AndroidNotificationChannel(
      'messages_channel',
      'Messages',
      description: 'New messages in your rooms.',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(mentionsChannel);
    await androidPlugin?.createNotificationChannel(messagesChannel);

    await androidPlugin?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {
    final roomCode = response.payload;
    if (roomCode != null && roomCode.isNotEmpty) {
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go('/chat/$roomCode');
      }
    }
  }

  static Future<void> showMentionNotification({
    required String roomName,
    required String sender,
    required String content,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'mentions_channel',
          'Mentions',
          channelDescription:
              'Notifications for when you are mentioned in a room.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Mentioned in $roomName',
      body: '$sender: $content',
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> showMessageNotification({
    required String roomCode,
    required String sender,
    required String content,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'messages_channel',
          'Messages',
          channelDescription: 'New messages in your rooms.',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    final id =
        roomCode.hashCode ^ DateTime.now().millisecondsSinceEpoch.hashCode;

    await _localNotificationsPlugin.show(
      id: id,
      title: sender,
      body: content,
      notificationDetails: notificationDetails,
      payload: roomCode,
    );
  }
}
