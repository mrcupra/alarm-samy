import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  void Function(String? payload)? onNotificationTapped;

  Future<void> initialize({
    void Function(String? payload)? onTap,
  }) async {
    onNotificationTapped = onTap;
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
    } catch (_) {}

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Alarm Samy',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin
          .initialize(
            initSettings,
            onDidReceiveNotificationResponse: (NotificationResponse response) {
              onNotificationTapped?.call(response.payload);
            },
          )
          .timeout(const Duration(milliseconds: 600));

      // Explicitly request iOS & Android 13+ permissions
      if (!kIsWeb) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        await iosImpl
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            )
            .timeout(const Duration(milliseconds: 600));

        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl
            ?.requestNotificationsPermission()
            .timeout(const Duration(milliseconds: 600));
        await androidImpl
            ?.requestExactAlarmsPermission()
            .timeout(const Duration(milliseconds: 600));
      }
      _initialized = true;
    } catch (_) {
      // Gracefully ignore on unsupported desktop test runners
    }
  }

  NotificationDetails _alarmNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'alarm_samy_critical_channel',
      'منبهات سامي الذكية (صوت عالي)',
      channelDescription: 'إشعارات رنين المنبه في الخلفية وعلى شاشة القفل',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  /// Fires an immediate notification when the alarm triggers while the user is outside the app
  Future<void> showAlarmRingingNotification(AlarmItem alarm) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        alarm.id.hashCode.abs() % 100000,
        '🚨 منبه سامي يرن الآن: ${alarm.label}',
        'ادخل للتطبيق وحل تحدي (${alarm.challengeType.arabicTitle}) لإيقاف صوت المنبه!',
        _alarmNotificationDetails(),
        payload: alarm.id,
      );
    } catch (_) {}
  }

  /// Syncs all enabled alarms with the OS native notification scheduler
  Future<void> syncScheduledAlarms(List<AlarmItem> alarms) async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
      final now = DateTime.now();

      for (final alarm in alarms) {
        if (!alarm.isEnabled) continue;

        DateTime scheduled = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.hour,
          alarm.minute,
        );
        if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

        await _plugin.zonedSchedule(
          alarm.id.hashCode.abs() % 100000,
          '⏰ حان موعد المنبه: ${alarm.label}',
          'اضغط لفتح تحدي (${alarm.challengeType.arabicTitle}) وإيقاف الرنين',
          tzScheduled,
          _alarmNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: alarm.id,
        );
      }
    } catch (_) {}
  }
}
