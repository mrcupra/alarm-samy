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
    } catch (_) {}
  }

  NotificationDetails _alarmNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'alarm_samy_critical_channel_v2',
      'منبهات سامي الذكية (رنين متواصل)',
      channelDescription: 'إشعارات رنين المنبه المتواصل في الخلفية وشاشة القفل',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      playSound: true,
      ongoing: true,
      autoCancel: false,
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
      sound: 'samy_masry.caf',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  /// Fires an immediate notification when the alarm triggers while the user is outside the app or screen is locked
  Future<void> showAlarmRingingNotification(AlarmItem alarm) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        alarm.id.hashCode.abs() % 90000,
        '🚨 منبه سامي يرن الآن: ${alarm.label}',
        'افتح التطبيق وحل تحدي (${alarm.challengeType.arabicTitle}) لإيقاف الرنين المتواصل!',
        _alarmNotificationDetails(),
        payload: alarm.id,
      );
    } catch (_) {}
  }

  Future<void> cancelAllActiveNotifications() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Syncs all enabled alarms with the OS native notification scheduler, including a repeating burst for Lock Screen
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

        final baseId = (alarm.id.hashCode.abs() % 10000) * 10;

        // Schedule a burst of 5 consecutive lock-screen notifications (at +0s, +12s, +24s, +36s, +48s)
        // so even if the app was force-closed, the Lock Screen keeps ringing continuously!
        for (int burst = 0; burst < 5; burst++) {
          final burstTime = scheduled.add(Duration(seconds: burst * 12));
          final tzScheduled = tz.TZDateTime.from(burstTime, tz.local);

          await _plugin.zonedSchedule(
            baseId + burst,
            burst == 0
                ? '⏰ حان موعد المنبه: ${alarm.label}'
                : '🚨 ما زال المنبه يرن! (${alarm.label})',
            'اضغط لفتح التطبيق وحل تحدي (${alarm.challengeType.arabicTitle}) لإيقاف الصوت',
            tzScheduled,
            _alarmNotificationDetails(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents:
                burst == 0 ? DateTimeComponents.time : null,
            payload: alarm.id,
          );
        }
      }
    } catch (_) {}
  }
}
