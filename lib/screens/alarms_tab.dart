import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/alarm_models.dart';
import '../services/app_state.dart';
import '../services/sound_generator_service.dart';
import '../theme/app_theme.dart';

class AlarmsTab extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenPaywall;

  const AlarmsTab({
    super.key,
    required this.appState,
    required this.onOpenPaywall,
  });

  void _openAlarmEditor(BuildContext context, {AlarmItem? existing}) {
    // Check Free tier limit when adding a new alarm (> 4 alarms requires Pro)
    if (existing == null && !appState.isPro && appState.alarms.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SamyColors.primaryBlue,
          action: SnackBarAction(
            label: 'تفعيل Pro مجاناً 👑',
            textColor: SamyColors.proGold,
            onPressed: onOpenPaywall,
          ),
          content: const Text(
            'النسخة المجانية تتيح حتى ٤ منبهات. فعّل النسخة البرو مجاناً لعدد غير محدود!',
          ),
        ),
      );
      onOpenPaywall();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlarmEditorSheet(
        appState: appState,
        existingAlarm: existing,
        onOpenPaywall: onOpenPaywall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final alarms = appState.alarms;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: SamyColors.primaryGradient(isDark),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: SamyColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'منبهات سامي الذكية ⏰',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'لا مزيد من العودة للنوم! اختر تحدي معادلات حسابية أو ذاكرة لكل منبه',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openAlarmEditor(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SamyColors.primaryBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_alarm_rounded, size: 20),
                    label: const Text(
                      'منبه جديد',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (alarms.isEmpty)
              Container(
                padding: const EdgeInsets.all(36),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.alarm_off_rounded,
                      size: 64,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد منبهات مضافة حالياً',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? SamyColors.darkTextSecondary
                            : SamyColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...alarms.map((alarm) => _buildAlarmCard(context, alarm, isDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildAlarmCard(
      BuildContext context, AlarmItem alarm, bool isDark) {
    final ringtone = appState.getRingtoneById(alarm.ringtoneId);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: alarm.isEnabled
              ? (isDark
                  ? SamyColors.electricCyan.withValues(alpha: 0.5)
                  : SamyColors.primaryBlue.withValues(alpha: 0.45))
              : (isDark
                  ? SamyColors.darkCardBorder
                  : SamyColors.lightCardBorder),
          width: alarm.isEnabled ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: alarm.isEnabled
                ? SamyColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.09)
                : Colors.transparent,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Label + Edit/Delete + Switch
          Row(
            children: [
              Expanded(
                child: Text(
                  alarm.label,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: alarm.isEnabled
                        ? (isDark ? Colors.white : SamyColors.lightTextPrimary)
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _openAlarmEditor(context, existing: alarm),
                icon: Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: isDark
                      ? SamyColors.darkTextSecondary
                      : SamyColors.lightTextSecondary,
                ),
                tooltip: 'تعديل المنبه',
              ),
              IconButton(
                onPressed: () => appState.deleteAlarm(alarm.id),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: SamyColors.dangerRed,
                ),
                tooltip: 'حذف المنبه',
              ),
              Switch.adaptive(
                value: alarm.isEnabled,
                activeTrackColor: SamyColors.primaryBlue,
                onChanged: (_) => appState.toggleAlarm(alarm.id),
              ),
            ],
          ),

          // Big Time Display + Repeat Days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      alarm.formattedTime12,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: alarm.isEnabled
                            ? (isDark
                                ? Colors.white
                                : SamyColors.lightTextPrimary)
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    alarm.periodArabic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: alarm.isEnabled
                          ? (isDark
                              ? SamyColors.electricCyan
                              : SamyColors.primaryBlue)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                alarm.repeatSummaryArabic,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? SamyColors.darkTextSecondary
                      : SamyColors.lightTextSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          const SizedBox(height: 12),

          // Challenge Badge + Ringtone + Test Button
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: SamyColors.primaryBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alarm.challengeType.icon,
                      size: 16,
                      color: isDark
                          ? SamyColors.electricCyan
                          : SamyColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${alarm.challengeType.arabicTitle} (${alarm.difficulty.arabicName} • ${alarm.questionCount} أسئلة)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? SamyColors.electricCyan
                            : SamyColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 15,
                      color: SamyColors.electricCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ringtone.name.split('(').first.trim(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? SamyColors.darkTextSecondary
                            : SamyColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => appState.triggerAlarmNow(alarm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamyColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.notifications_active_rounded, size: 16),
                label: const Text(
                  'تجربة التحدي الآن',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlarmEditorSheet extends StatefulWidget {
  final AppState appState;
  final AlarmItem? existingAlarm;
  final VoidCallback onOpenPaywall;

  const _AlarmEditorSheet({
    required this.appState,
    this.existingAlarm,
    required this.onOpenPaywall,
  });

  @override
  State<_AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<_AlarmEditorSheet> {
  late int _hour;
  late int _minute;
  late TextEditingController _labelCtrl;
  late List<int> _repeatDays;
  late WakeChallengeType _challengeType;
  late ChallengeDifficulty _difficulty;
  late int _questionCount;
  late String _ringtoneId;
  late bool _wakeUpCheck;
  late bool _gradualVolume;

  static const List<String> _dayShortNames = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existingAlarm;
    _hour = e?.hour ?? 7;
    _minute = e?.minute ?? 0;
    _labelCtrl =
        TextEditingController(text: e?.label ?? 'منبه الصباح النشط 🚀');
    _repeatDays = List<int>.from(e?.repeatDays ?? [0, 1, 2, 3, 4, 5, 6]);
    _challengeType = e?.challengeType ?? WakeChallengeType.math;
    _difficulty = e?.difficulty ?? ChallengeDifficulty.medium;
    _questionCount = e?.questionCount ?? 3;
    _ringtoneId = e?.ringtoneId ?? 'samy_dawn';
    _wakeUpCheck = e?.wakeUpCheck ?? false;
    _gradualVolume = e?.gradualVolume ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    SoundGeneratorService().stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;
    final isPro = widget.appState.isPro;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF091530) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? SamyColors.darkCardBorder : SamyColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                Text(
                  widget.existingAlarm == null
                      ? 'إضافة منبه جديد'
                      : 'تعديل المنبه',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : SamyColors.lightTextPrimary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newAlarm = AlarmItem(
                      id: widget.existingAlarm?.id ??
                          'alarm_${DateTime.now().millisecondsSinceEpoch}',
                      hour: _hour,
                      minute: _minute,
                      label: _labelCtrl.text.trim().isEmpty
                          ? 'منبه سامي'
                          : _labelCtrl.text.trim(),
                      isEnabled: true,
                      repeatDays: _repeatDays,
                      challengeType: _challengeType,
                      difficulty: _difficulty,
                      questionCount: _questionCount,
                      ringtoneId: _ringtoneId,
                      wakeUpCheck: _wakeUpCheck,
                      gradualVolume: _gradualVolume,
                    );
                    widget.appState.addOrUpdateAlarm(newAlarm);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamyColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'حفظ المنبه',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                // iOS Style Cupertino Time Wheel Picker
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F2044)
                        : const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime:
                          DateTime(2026, 1, 1, _hour, _minute),
                      onDateTimeChanged: (dt) {
                        setState(() {
                          _hour = dt.hour;
                          _minute = dt.minute;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Alarm Label
                TextField(
                  controller: _labelCtrl,
                  decoration: InputDecoration(
                    labelText: 'عنوان المنبه (مثال: صلاة الفجر، العمل، المذاكرة)',
                    prefixIcon: const Icon(Icons.label_important_rounded),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0F2044)
                        : const Color(0xFFF0F6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Repeat Days Selector
                const Text(
                  'أيام التكرار:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (idx) {
                    final selected = _repeatDays.contains(idx);
                    return FilterChip(
                      selected: selected,
                      selectedColor: SamyColors.primaryBlue,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : SamyColors.lightTextPrimary),
                        fontWeight: FontWeight.w700,
                      ),
                      label: Text(_dayShortNames[idx]),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _repeatDays.add(idx);
                            _repeatDays.sort();
                          } else {
                            _repeatDays.remove(idx);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Wake-up Challenge Picker
                const Text(
                  'تحدي الاستيقاظ (للتأكد أنك استيقظت تماماً):',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...WakeChallengeType.values.map((cType) {
                  final isSelected = _challengeType == cType;
                  final locked = cType.isProOnly && !isPro;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (locked) {
                          Navigator.pop(context);
                          widget.onOpenPaywall();
                          return;
                        }
                        setState(() {
                          _challengeType = cType;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SamyColors.primaryBlue.withValues(alpha: 0.18)
                              : (isDark
                                  ? const Color(0xFF0F2044)
                                  : const Color(0xFFF0F6FF)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? SamyColors.electricCyan
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cType.icon,
                              color: isSelected
                                  ? SamyColors.electricCyan
                                  : SamyColors.primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        cType.arabicTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (cType.isProOnly) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: SamyColors.proGold
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PRO 👑',
                                            style: TextStyle(
                                              color: SamyColors.proGold,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    cType.arabicDescription,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark
                                          ? SamyColors.darkTextSecondary
                                          : SamyColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              locked
                                  ? Icons.lock_rounded
                                  : (isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined),
                              color: locked
                                  ? SamyColors.proGold
                                  : (isSelected
                                      ? SamyColors.electricCyan
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Difficulty & Question Count
                const Text(
                  'مستوى صعوبة التحدي وعدد الأسئلة:',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ChallengeDifficulty.values.map((diff) {
                    final selected = _difficulty == diff;
                    final locked = diff.isProOnly && !isPro;
                    return ChoiceChip(
                      selected: selected,
                      selectedColor: SamyColors.primaryBlue,
                      label: Text(
                        '${diff.arabicName}${locked ? ' 👑' : ''}',
                        style: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onSelected: (_) {
                        if (locked) {
                          Navigator.pop(context);
                          widget.onOpenPaywall();
                          return;
                        }
                        setState(() {
                          _difficulty = diff;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  _difficulty.sampleHint,
                  style: const TextStyle(
                    color: SamyColors.electricCyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'عدد الأسئلة المطلوبة لإيقاف المنبه:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    ...[1, 2, 3, 4, 5].map((cnt) {
                      final active = _questionCount == cnt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _questionCount = cnt),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: active
                                ? SamyColors.primaryBlue
                                : Colors.grey.withValues(alpha: 0.2),
                            child: Text(
                              '$cnt',
                              style: TextStyle(
                                color: active ? Colors.white : null,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 20),

                // Ringtone Selection with instant preview
                const Text(
                  'نغمة المنبه (اضغط على زر التشغيل للمعاينة):',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ...widget.appState.allRingtones.map((tone) {
                  final selected = _ringtoneId == tone.id;
                  final locked = tone.isPro && !isPro;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: selected
                        ? SamyColors.primaryBlue.withValues(alpha: 0.16)
                        : null,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: SamyColors.electricCyan,
                        size: 30,
                      ),
                      onPressed: () =>
                          SoundGeneratorService().playRingtone(tone),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tone.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        if (tone.isPro)
                          const Text(
                            'PRO 👑',
                            style: TextStyle(
                              color: SamyColors.proGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      tone.subtitle,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: Icon(
                      locked
                          ? Icons.lock_rounded
                          : (selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded),
                      color: locked
                          ? SamyColors.proGold
                          : SamyColors.electricCyan,
                    ),
                    onTap: () {
                      if (locked) {
                        Navigator.pop(context);
                        widget.onOpenPaywall();
                        return;
                      }
                      setState(() => _ringtoneId = tone.id);
                      SoundGeneratorService().playRingtone(tone);
                    },
                  );
                }),

                const SizedBox(height: 14),

                // Pro Smart Options
                SwitchListTile.adaptive(
                  value: _wakeUpCheck,
                  activeTrackColor: SamyColors.primaryBlue,
                  title: const Row(
                    children: [
                      Text(
                        'التأكد من الاستيقاظ بعد ٥ دقائق',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PRO 👑',
                        style: TextStyle(
                          color: SamyColors.proGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'يرسل تنبيهاً هادئاً بعد ٥ دقائق للتأكد أنك لم تعد للنوم',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) {
                    if (!isPro) {
                      Navigator.pop(context);
                      widget.onOpenPaywall();
                      return;
                    }
                    setState(() => _wakeUpCheck = val);
                  },
                ),
                SwitchListTile.adaptive(
                  value: _gradualVolume,
                  activeTrackColor: SamyColors.primaryBlue,
                  title: const Row(
                    children: [
                      Text(
                        'تدرج الصوت الذكي الهادئ',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'PRO 👑',
                        style: TextStyle(
                          color: SamyColors.proGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'يبدأ الصوت منخفضاً ثم يرتفع تدريجياً لحماية الجهاز العصبي',
                    style: TextStyle(fontSize: 12),
                  ),
                  onChanged: (val) {
                    if (!isPro) {
                      Navigator.pop(context);
                      widget.onOpenPaywall();
                      return;
                    }
                    setState(() => _gradualVolume = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
