import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'nutrition_channel';
  static const _channelName = 'Nutrition Reminder';
  static const _channelDesc = 'Reminds user to check nutrition';

  /// 🔹 Initialize notifications
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Create channel (Android)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 🔹 Setup timezone (call once in main)
  static Future<void> setupTimezone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }

  /// 🔹 Show instant notification
  static Future<void> showNow() async {
    await _notifications.show(
      0,
      'Reminder ⏰',
      'Check your nutrition!',
      _details(),
    );
  }

  /// 🔹 Schedule one-time notification
  static Future<void> scheduleOnce(Duration delay) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _notifications.zonedSchedule(
      1,
      'Reminder ⏰',
      'Check your nutrition!',
      scheduledTime,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔹 Schedule daily notification
  static Future<void> scheduleDaily({
    required int hour,
    required int minute,
  }) async {
    final scheduledTime = _nextInstance(hour, minute);

    await _notifications.zonedSchedule(
      2,
      'Daily Reminder 🥗',
      'Don’t forget to check your nutrition!',
      scheduledTime,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 🔹 Cancel specific notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// 🔹 Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 🔹 Notification style
  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  /// 🔹 Helper: get next scheduled time
  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}