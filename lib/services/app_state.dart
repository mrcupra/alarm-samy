import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_models.dart';
import 'notification_service.dart';
import 'sound_generator_service.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  bool _isDarkMode = true;
  bool _isPro = false;
  String _proPlanTitle = 'النسخة المجانية';
  int _wakeStreakDays = 7;
  int _completedChallengesCount = 24;
  bool _backgroundGuardianEnabled = true;

  List<AlarmItem> _alarms = [];
  List<ReminderItem> _reminders = [];
  List<RingtoneItem> _customRingtones = [];

  AlarmItem? _activeRingingAlarm;
  final Map<String, String> _triggeredAlarmMinuteMap = {};
  Timer? _clockTimer;
  Timer? _backgroundTestTimer;
  int _backgroundTestCountdown = 0;
  DateTime _now = DateTime.now();

  bool get isDarkMode => _isDarkMode;
  bool get isPro => _isPro;
  String get proPlanTitle => _proPlanTitle;
  int get wakeStreakDays => _wakeStreakDays;
  int get completedChallengesCount => _completedChallengesCount;
  bool get backgroundGuardianEnabled => _backgroundGuardianEnabled;
  int get backgroundTestCountdown => _backgroundTestCountdown;
  DateTime get now => _now;
  AlarmItem? get activeRingingAlarm => _activeRingingAlarm;

  List<AlarmItem> get alarms => List.unmodifiable(_alarms);
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);

  static const List<RingtoneItem> defaultRingtones = [
    RingtoneItem(
      id: 'samy_dawn',
      name: 'نبض الفجر الأزرق (Samy Dawn)',
      subtitle: 'نغمة صباحية مشرقة متدرجة تبعث على النشاط',
      category: 'صباحي هادئ',
      isPro: false,
      melodyFrequencies: [523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50],
      noteDurationMs: 210,
    ),
    RingtoneItem(
      id: 'samy_chime',
      name: 'أجراس الكريستال (Crystal Bell)',
      subtitle: 'رنين نقي وواضح للتذكيرات والاستيقاظ السريع',
      category: 'كلاسيكي',
      isPro: false,
      melodyFrequencies: [587.33, 739.99, 880.00, 1174.66, 880.00, 1174.66],
      noteDurationMs: 190,
    ),
    RingtoneItem(
      id: 'samy_radar',
      name: 'رادار الآيفون الذكي (iOS Radar Blue)',
      subtitle: 'مستوحى من نغمة الآيفون الشهيرة بطابع سامي',
      category: 'كلاسيكي',
      isPro: false,
      melodyFrequencies: [880.0, 987.77, 1046.50, 987.77, 880.0, 1174.66],
      noteDurationMs: 160,
    ),
    RingtoneItem(
      id: 'samy_thunder',
      name: 'إنذار الصاعقة القصوى 🚨 (Ultra Siren)',
      subtitle: 'صوت قوي جداً ومستمر لأصحاب النوم الثقيل جداً',
      category: 'نوم ثقيل 🔥',
      isPro: true,
      melodyFrequencies: [784.0, 1174.66, 784.0, 1318.51, 880.0, 1567.98],
      noteDurationMs: 135,
    ),
    RingtoneItem(
      id: 'samy_royal',
      name: 'سيمفونية القمة الملكية 👑 (Royal Symphony)',
      subtitle: 'مقطوعة أوركسترالية إلكترونية فخمة لبدء يوم استثنائي',
      category: 'حصري Pro 👑',
      isPro: true,
      melodyFrequencies: [
        440.0,
        554.37,
        659.25,
        880.0,
        659.25,
        880.0,
        1108.73
      ],
      noteDurationMs: 200,
    ),
    RingtoneItem(
      id: 'samy_cyber',
      name: 'طاقة المستقبل الإلكترونية ⚡ (Cyber Pulse)',
      subtitle: 'إيقاع سينثوايف سريع يشحن طاقتك في ثوانٍ',
      category: 'حصري Pro 👑',
      isPro: true,
      melodyFrequencies: [
        329.63,
        493.88,
        659.25,
        987.77,
        783.99,
        1174.66,
        1318.51
      ],
      noteDurationMs: 145,
    ),
  ];

  List<RingtoneItem> get allRingtones => [
        ...defaultRingtones,
        ..._customRingtones,
      ];

  RingtoneItem getRingtoneById(String id) {
    return allRingtones.firstWhere(
      (r) => r.id == id,
      orElse: () => defaultRingtones.first,
    );
  }

  AlarmItem? get nextUpcomingAlarm {
    final enabled = _alarms.where((a) => a.isEnabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) => a
        .timeUntilNextTrigger(_now)
        .compareTo(b.timeUntilNextTrigger(_now)));
    return enabled.first;
  }

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('samy_dark_mode') ?? true;
    _isPro = prefs.getBool('samy_is_pro') ?? false;
    _proPlanTitle = prefs.getString('samy_pro_plan') ?? 'النسخة المجانية';
    _wakeStreakDays = prefs.getInt('samy_streak') ?? 7;
    _completedChallengesCount = prefs.getInt('samy_challenges_solved') ?? 24;
    _backgroundGuardianEnabled =
        prefs.getBool('samy_bg_guardian') ?? true;

    // Load alarms
    final alarmsJson = prefs.getStringList('samy_alarms');
    if (alarmsJson != null && alarmsJson.isNotEmpty) {
      _alarms = alarmsJson
          .map((e) => AlarmItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } else {
      _alarms = [
        const AlarmItem(
          id: 'default_1',
          hour: 6,
          minute: 30,
          label: 'صلاة الفجر وبداية اليوم 🌅',
          isEnabled: true,
          repeatDays: [0, 1, 2, 3, 4, 5, 6],
          challengeType: WakeChallengeType.math,
          difficulty: ChallengeDifficulty.medium,
          questionCount: 3,
          ringtoneId: 'samy_dawn',
        ),
        const AlarmItem(
          id: 'default_2',
          hour: 8,
          minute: 0,
          label: 'الاستعداد للعمل / الجامعة 💼',
          isEnabled: true,
          repeatDays: [1, 2, 3, 4, 5],
          challengeType: WakeChallengeType.burstTap,
          difficulty: ChallengeDifficulty.easy,
          questionCount: 2,
          ringtoneId: 'samy_radar',
        ),
        const AlarmItem(
          id: 'default_3',
          hour: 17,
          minute: 30,
          label: 'وقت التمرين والجيم 💪',
          isEnabled: false,
          repeatDays: [0, 2, 4],
          challengeType: WakeChallengeType.typing,
          difficulty: ChallengeDifficulty.medium,
          questionCount: 1,
          ringtoneId: 'samy_chime',
        ),
      ];
      await _saveAlarms();
    }

    // Load reminders
    final remindersJson = prefs.getStringList('samy_reminders');
    if (remindersJson != null && remindersJson.isNotEmpty) {
      _reminders = remindersJson
          .map((e) =>
              ReminderItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    } else {
      final now = DateTime.now();
      _reminders = [
        ReminderItem(
          id: 'rem_1',
          title: 'مراجعة خطة الأسبوع وأهداف العمل',
          notes: 'ترتيب الأولويات المهمة وتجهيز المهام الصباحية',
          scheduledAt: now.add(const Duration(hours: 2)),
          category: ReminderCategory.work,
          isHighPriority: true,
        ),
        ReminderItem(
          id: 'rem_2',
          title: 'شرب ٢ لتر ماء والفيتامينات اليومية 💧',
          notes: 'الحفاظ على الترطيب والنشاط طوال اليوم',
          scheduledAt: now.add(const Duration(hours: 4)),
          category: ReminderCategory.health,
          isHighPriority: false,
        ),
        ReminderItem(
          id: 'rem_3',
          title: 'تحديث مشروع GitHub وبناء نسخة Codemagic 🚀',
          notes: 'رفع كود Alarm Samy وتحميل ملف الـ IPA للآيفون',
          scheduledAt: now.add(const Duration(hours: 1)),
          category: ReminderCategory.study,
          isHighPriority: true,
        ),
      ];
      await _saveReminders();
    }

    // Load custom ringtones
    final customRingsJson = prefs.getStringList('samy_custom_ringtones');
    if (customRingsJson != null) {
      _customRingtones = customRingsJson
          .map((e) =>
              RingtoneItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
    }

    unawaited(
      NotificationService().initialize(
        onTap: (payload) {
          if (payload != null) {
            final match = _alarms.where((a) => a.id == payload).toList();
            if (match.isNotEmpty) {
              triggerAlarmNow(match.first);
            } else if (_alarms.isNotEmpty) {
              triggerAlarmNow(_alarms.first);
            }
          }
        },
      ).then((_) => _syncBackgroundServices()),
    );

    _startClockTicker();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Ensure background audio keep-alive and OS notifications are armed when leaving app
      _syncBackgroundServices();
    } else if (state == AppLifecycleState.resumed) {
      _now = DateTime.now();
      _checkScheduledAlarms();
      notifyListeners();
    }
  }

  Future<void> _syncBackgroundServices() async {
    final hasActiveAlarms =
        _backgroundGuardianEnabled && _alarms.any((a) => a.isEnabled);
    await SoundGeneratorService().syncBackgroundKeepAlive(hasActiveAlarms);
    await NotificationService().syncScheduledAlarms(_alarms);
  }

  Future<void> toggleBackgroundGuardian(bool enabled) async {
    _backgroundGuardianEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('samy_bg_guardian', enabled);
    await _syncBackgroundServices();
  }

  /// Starts a 10-second countdown so the user can exit/minimize the app and test background ringing!
  void startTenSecondBackgroundTest() {
    _backgroundTestTimer?.cancel();
    _backgroundTestCountdown = 10;
    SoundGeneratorService().syncBackgroundKeepAlive(true);
    notifyListeners();

    _backgroundTestTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_backgroundTestCountdown > 1) {
        _backgroundTestCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
        _backgroundTestCountdown = 0;
        final testAlarm = _alarms.isNotEmpty
            ? _alarms.first
            : const AlarmItem(
                id: 'bg_test_alarm',
                hour: 7,
                minute: 0,
                label: 'اختبار الرنين في الخلفية بنجاح 🚀',
                challengeType: WakeChallengeType.math,
                difficulty: ChallengeDifficulty.medium,
                questionCount: 2,
                ringtoneId: 'samy_thunder',
              );
        triggerAlarmNow(testAlarm);
      }
    });
  }

  void cancelTenSecondBackgroundTest() {
    _backgroundTestTimer?.cancel();
    _backgroundTestCountdown = 0;
    notifyListeners();
  }

  void _startClockTicker() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      _checkScheduledAlarms();
      notifyListeners();
    });
  }

  void _checkScheduledAlarms() {
    if (_activeRingingAlarm != null) return;
    final minuteKey =
        '${_now.year}-${_now.month}-${_now.day}-${_now.hour}:${_now.minute}';

    // Check across the entire minute (0..59s) so background timer coalescing never misses!
    for (final alarm in _alarms) {
      if (alarm.isEnabled &&
          alarm.hour == _now.hour &&
          alarm.minute == _now.minute) {
        if (_triggeredAlarmMinuteMap[alarm.id] != minuteKey) {
          _triggeredAlarmMinuteMap[alarm.id] = minuteKey;
          triggerAlarmNow(alarm);
          break;
        }
      }
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('samy_dark_mode', _isDarkMode);
  }

  Future<void> activateProPlan(String planTitle) async {
    _isPro = true;
    _proPlanTitle = planTitle;
    notifyListeners();
    await SoundGeneratorService().playSuccessChime();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('samy_is_pro', true);
    await prefs.setString('samy_pro_plan', planTitle);
  }

  Future<void> switchToFreeTierForTesting() async {
    _isPro = false;
    _proPlanTitle = 'النسخة المجانية';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('samy_is_pro', false);
    await prefs.setString('samy_pro_plan', 'النسخة المجانية');
  }

  Future<void> addOrUpdateAlarm(AlarmItem alarm) async {
    final idx = _alarms.indexWhere((a) => a.id == alarm.id);
    if (idx >= 0) {
      _alarms[idx] = alarm;
    } else {
      _alarms.insert(0, alarm);
    }
    // Clear any previous trigger lock for this alarm ID so newly edited time can ring immediately
    _triggeredAlarmMinuteMap.remove(alarm.id);
    notifyListeners();
    await _saveAlarms();
    await _syncBackgroundServices();
  }

  Future<void> toggleAlarm(String id) async {
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _alarms[idx] = _alarms[idx].copyWith(isEnabled: !_alarms[idx].isEnabled);
      _triggeredAlarmMinuteMap.remove(id);
      notifyListeners();
      await _saveAlarms();
      await _syncBackgroundServices();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    _triggeredAlarmMinuteMap.remove(id);
    notifyListeners();
    await _saveAlarms();
    await _syncBackgroundServices();
  }

  Future<void> createQuickNapAlarm(int minutesFromNow) async {
    final target = DateTime.now().add(Duration(minutes: minutesFromNow));
    final napAlarm = AlarmItem(
      id: 'nap_${DateTime.now().millisecondsSinceEpoch}',
      hour: target.hour,
      minute: target.minute,
      label: 'قيلولة سريعة ($minutesFromNow دقيقة) ⚡',
      isEnabled: true,
      repeatDays: const [],
      challengeType: WakeChallengeType.burstTap,
      difficulty: ChallengeDifficulty.easy,
      questionCount: 1,
      ringtoneId: 'samy_dawn',
    );
    _alarms.insert(0, napAlarm);
    notifyListeners();
    await _saveAlarms();
    await _syncBackgroundServices();
  }

  void triggerAlarmNow(AlarmItem alarm) {
    _activeRingingAlarm = alarm;
    final ringtone = getRingtoneById(alarm.ringtoneId);
    SoundGeneratorService().playRingtone(ringtone, loop: true);
    NotificationService().showAlarmRingingNotification(alarm);
    notifyListeners();
  }

  Future<void> completeActiveAlarmChallenge() async {
    await SoundGeneratorService().stopRingtone();
    await SoundGeneratorService().playSuccessChime();
    _activeRingingAlarm = null;
    _completedChallengesCount += 1;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('samy_challenges_solved', _completedChallengesCount);
    await _syncBackgroundServices();
  }

  Future<void> snoozeActiveAlarm() async {
    final current = _activeRingingAlarm;
    await SoundGeneratorService().stopRingtone();
    _activeRingingAlarm = null;
    if (current != null) {
      final snoozedTime =
          DateTime.now().add(Duration(minutes: current.snoozeMinutes));
      final snoozeAlarm = current.copyWith(
        id: 'snooze_${DateTime.now().millisecondsSinceEpoch}',
        hour: snoozedTime.hour,
        minute: snoozedTime.minute,
        label: '${current.label} (غفوة)',
        repeatDays: const [],
        isEnabled: true,
      );
      _alarms.insert(0, snoozeAlarm);
      await _saveAlarms();
      await _syncBackgroundServices();
    }
    notifyListeners();
  }

  // Reminders CRUD
  Future<void> addReminder(ReminderItem item) async {
    _reminders.insert(0, item);
    notifyListeners();
    await _saveReminders();
  }

  Future<void> toggleReminderCompleted(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final newVal = !_reminders[idx].isCompleted;
      _reminders[idx] = _reminders[idx].copyWith(isCompleted: newVal);
      if (newVal) {
        SoundGeneratorService().playSuccessChime();
      }
      notifyListeners();
      await _saveReminders();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveReminders();
  }

  // Custom Ringtones CRUD
  Future<void> addCustomRingtone(RingtoneItem ringtone) async {
    _customRingtones.insert(0, ringtone);
    notifyListeners();
    await _saveCustomRingtones();
  }

  Future<void> deleteCustomRingtone(String id) async {
    _customRingtones.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveCustomRingtones();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'samy_alarms',
      _alarms.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'samy_reminders',
      _reminders.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  Future<void> _saveCustomRingtones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'samy_custom_ringtones',
      _customRingtones.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _backgroundTestTimer?.cancel();
    super.dispose();
  }
}
