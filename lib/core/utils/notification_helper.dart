import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  NotificationHelper._();

  /// Invoked when a notification is tapped, with the room code payload.
  static void Function(String? roomCode)? onNotificationTap;

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
      onDidReceiveNotificationResponse: (response) {
        final roomCode = response.payload;
        if (roomCode != null && roomCode.isNotEmpty) {
          onNotificationTap?.call(roomCode);
        }
      },
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

  /// Requests the OS notification permission via permission_handler and
  /// reports whether it was granted.
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    return status.isGranted;
  }

  /// Startup prompt: requests the permission only when it has not been
  /// granted yet. Callers should schedule this after the first frame so the
  /// dialog never blocks the initial UI.
  static Future<void> requestNotificationPermissionIfNeeded() async {
    if (await hasNotificationPermission()) return;

    await requestNotificationPermission();
  }

  /// Reads the current OS notification permission state.
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;

    return status.isGranted;
  }

  /// Monotonic notification id so two mentions in the same second never
  /// overwrite each other (the old `msSinceEpoch ~/ 1000` collided).
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
