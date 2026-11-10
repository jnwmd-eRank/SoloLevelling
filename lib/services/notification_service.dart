import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/schedule_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    _configureLocalTimeZone();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    // Request permissions explicitly for iOS & Android 13+
    await requestPermissions();

    _initialized = true;
  }

  void _configureLocalTimeZone() {
    try {
      final now = DateTime.now();
      final targetOffset = now.timeZoneOffset;
      for (final entry in tz.timeZoneDatabase.locations.entries) {
        if (entry.value.currentTimeZone.offset == targetOffset) {
          tz.setLocalLocation(entry.value);
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Could not set local timezone location: $e');
    }
  }

  Future<void> requestPermissions() async {
    // iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  int _getNotificationId(String id) {
    return id.hashCode & 0x7FFFFFFF;
  }

  Future<void> scheduleItemNotification(ScheduleItem item) async {
    if (item.isCompleted) return;

    try {
      final scheduledDateTime = _parseScheduleDateTime(item.date, item.time);
      if (scheduledDateTime == null) return;

      // Don't schedule notifications in the past
      if (scheduledDateTime.isBefore(DateTime.now())) return;

      final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
      final id = _getNotificationId(item.id);

      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedule Alerts',
          channelDescription:
              'Notifications for scheduled daily routine and activities',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final String bodyText = item.description.isNotEmpty
          ? item.description
          : 'Scheduled activity starting at ${item.time}';

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'SYSTEM: ${item.title}',
        body: bodyText,
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) print('Failed to schedule notification: $e');
    }
  }

  Future<void> cancelItemNotification(String itemId) async {
    try {
      final id = _getNotificationId(itemId);
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      if (kDebugMode) print('Failed to cancel notification: $e');
    }
  }

  Future<void> syncAllScheduleNotifications(List<ScheduleItem> items) async {
    final now = DateTime.now();
    for (final item in items) {
      if (!item.isCompleted) {
        final dt = _parseScheduleDateTime(item.date, item.time);
        if (dt != null && dt.isAfter(now)) {
          await scheduleItemNotification(item);
        }
      }
    }
  }

  DateTime? _parseScheduleDateTime(String dateStr, String timeStr) {
    try {
      final cleanTime = timeStr.trim();
      final parts = cleanTime.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0].trim());
        final minStr = parts[1].trim().split(' ')[0];
        final minute = int.parse(minStr);
        final baseDate = DateFormat('yyyy-MM-dd').parse(dateStr);
        return DateTime(
            baseDate.year, baseDate.month, baseDate.day, hour, minute);
      }
    } catch (_) {}
    return null;
  }
}
