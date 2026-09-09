import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mentions_channel',
      'Mentions',
      description: 'Notifications for when you are mentioned in a room.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    return status.isGranted;
  }

  /// Only prompts if not granted; call after the first frame.
  static Future<void> requestNotificationPermissionIfNeeded() async {
    if (await hasNotificationPermission()) return;

    await requestNotificationPermission();
  }

  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;

    return status.isGranted;
  }

  /// Monotonic id so concurrent mentions don't overwrite each other.
  static int _nextNotificationId = 0;

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
          ticker: 'New mention',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    _nextNotificationId++;

    await _localNotificationsPlugin.show(
      id: _nextNotificationId,
      title: 'Mentioned in $roomName',
      body: '$sender: $content',
      notificationDetails: notificationDetails,
      payload: roomName,
    );
  }
}
