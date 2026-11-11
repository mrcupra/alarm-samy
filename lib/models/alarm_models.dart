import 'package:flutter/material.dart';

enum WakeChallengeType {
  math,
  burstTap,
  typing,
  memoryGrid,
  numberOrder,
  colorMatch,
}

extension WakeChallengeTypeExt on WakeChallengeType {
  String get arabicTitle {
    switch (this) {
      case WakeChallengeType.math:
        return 'معادلات حسابية ذكية';
      case WakeChallengeType.burstTap:
        return 'شحن طاقة الاستيقاظ السريع';
      case WakeChallengeType.typing:
        return 'كتابة العبارة الصباحية';
      case WakeChallengeType.memoryGrid:
        return 'تحدي الذاكرة المضيئة';
      case WakeChallengeType.numberOrder:
        return 'ترتيب الأرقام التصاعدي';
      case WakeChallengeType.colorMatch:
        return 'تحدي التركيز اللوني الخادع';
    }
  }

  String get arabicDescription {
    switch (this) {
      case WakeChallengeType.math:
        return 'حل عمليات حسابية متدرجة الصعوبة لإيقاف صوت المنبه والتأكد من نشاط عقلك';
      case WakeChallengeType.burstTap:
        return 'اضغط بسرعة متتالية لشحن عداد الطاقة حتى 100% وطرد الكسل فوراً';
      case WakeChallengeType.typing:
        return 'اكتب الجملة التحفيزية المطلوبة بدقة كاملة بدون أخطاء لإغلاق المنبه';
      case WakeChallengeType.memoryGrid:
        return 'احفظ مواقع المربعات الزرقاء المضيئة واضغط عليها بنفس الترتيب';
      case WakeChallengeType.numberOrder:
        return 'اضغط على الأرقام المبعثرة من الأصغر إلى الأكبر في أسرع وقت';
      case WakeChallengeType.colorMatch:
        return 'اختر لون النص الفعلي وليس الكلمة المكتوبة لتنشيط التركيز البصري';
    }
  }

  IconData get icon {
    switch (this) {
      case WakeChallengeType.math:
        return Icons.calculate_rounded;
      case WakeChallengeType.burstTap:
        return Icons.bolt_rounded;
      case WakeChallengeType.typing:
        return Icons.keyboard_alt_rounded;
      case WakeChallengeType.memoryGrid:
        return Icons.grid_view_rounded;
      case WakeChallengeType.numberOrder:
        return Icons.format_list_numbered_rtl_rounded;
      case WakeChallengeType.colorMatch:
        return Icons.palette_rounded;
    }
  }

  bool get isProOnly {
    switch (this) {
      case WakeChallengeType.math:
      case WakeChallengeType.burstTap:
      case WakeChallengeType.typing:
        return false;
      case WakeChallengeType.memoryGrid:
      case WakeChallengeType.numberOrder:
      case WakeChallengeType.colorMatch:
        return true;
    }
  }
}

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  extreme,
}

extension ChallengeDifficultyExt on ChallengeDifficulty {
  String get arabicName {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'سهل';
      case ChallengeDifficulty.medium:
        return 'متوسط';
      case ChallengeDifficulty.hard:
        return 'صعب';
      case ChallengeDifficulty.extreme:
        return 'خارق 🔥';
    }
  }

  String get sampleHint {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'مثال: ١٤ + ٢٥ = ؟';
      case ChallengeDifficulty.medium:
        return 'مثال: (١٢ × ٤) + ١٩ = ؟';
      case ChallengeDifficulty.hard:
        return 'مثال: (٢٧ × ٦) - ٤٨ = ؟';
      case ChallengeDifficulty.extreme:
        return 'مثال: (٣٤ × ١٢) + ٨٥ - ٢٩ = ؟';
    }
  }

  bool get isProOnly => this == ChallengeDifficulty.extreme;
}

class RingtoneItem {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final bool isPro;
  final bool isCustom;
  final String? customFilePath;
  final List<double> melodyFrequencies;
  final int noteDurationMs;

  const RingtoneItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    this.isPro = false,
    this.isCustom = false,
    this.customFilePath,
    required this.melodyFrequencies,
    this.noteDurationMs = 220,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'category': category,
        'isPro': isPro,
        'isCustom': isCustom,
        'customFilePath': customFilePath,
        'melodyFrequencies': melodyFrequencies,
        'noteDurationMs': noteDurationMs,
      };

  factory RingtoneItem.fromJson(Map<String, dynamic> json) {
    return RingtoneItem(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String? ?? 'نغمة مخصصة',
      category: json['category'] as String? ?? 'مخصص',
      isPro: json['isPro'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
      customFilePath: json['customFilePath'] as String?,
      melodyFrequencies: (json['melodyFrequencies'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [523.25, 659.25, 783.99, 1046.50],
      noteDurationMs: json['noteDurationMs'] as int? ?? 220,
    );
  }
}

class AlarmItem {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool isEnabled;
  // Days of week: 0 = السبت, 1 = الأحد, 2 = الإثنين, 3 = الثلاثاء, 4 = الأربعاء, 5 = الخميس, 6 = الجمعة
  final List<int> repeatDays;
  final WakeChallengeType challengeType;
  final ChallengeDifficulty difficulty;
  final int questionCount;
  final String ringtoneId;
  final int snoozeMinutes;
  final bool wakeUpCheck; // التأكد من الاستيقاظ بعد 5 دقائق (Pro)
  final bool gradualVolume; // تدرج الصوت الذكي (Pro)

  const AlarmItem({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    this.isEnabled = true,
    this.repeatDays = const [0, 1, 2, 3, 4, 5, 6],
    this.challengeType = WakeChallengeType.math,
    this.difficulty = ChallengeDifficulty.medium,
    this.questionCount = 3,
    this.ringtoneId = 'samy_dawn',
    this.snoozeMinutes = 5,
    this.wakeUpCheck = false,
    this.gradualVolume = false,
  });

  AlarmItem copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    WakeChallengeType? challengeType,
    ChallengeDifficulty? difficulty,
    int? questionCount,
    String? ringtoneId,
    int? snoozeMinutes,
    bool? wakeUpCheck,
    bool? gradualVolume,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      challengeType: challengeType ?? this.challengeType,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      ringtoneId: ringtoneId ?? this.ringtoneId,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      wakeUpCheck: wakeUpCheck ?? this.wakeUpCheck,
      gradualVolume: gradualVolume ?? this.gradualVolume,
    );
  }

  String get formattedTime12 {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final hStr = h.toString().padLeft(2, '0');
    return '$hStr:$m';
  }

  String get periodArabic => hour >= 12 ? 'مساءً' : 'صباحاً';

  String get repeatSummaryArabic {
    if (repeatDays.isEmpty) return 'مرة واحدة فقط';
    if (repeatDays.length == 7) return 'يومياً';
    const dayNames = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ];
    if (repeatDays.length == 5 &&
        !repeatDays.contains(5) &&
        !repeatDays.contains(6)) {
      return 'أيام العمل والجامعة';
    }
    return repeatDays.map((d) => dayNames[d % 7]).join(' ، ');
  }

  Duration timeUntilNextTrigger(DateTime now) {
    DateTime candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (candidate.isBefore(now) || candidate.isAtSameMomentAs(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate.difference(now);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'isEnabled': isEnabled,
        'repeatDays': repeatDays,
        'challengeType': challengeType.index,
        'difficulty': difficulty.index,
        'questionCount': questionCount,
        'ringtoneId': ringtoneId,
        'snoozeMinutes': snoozeMinutes,
        'wakeUpCheck': wakeUpCheck,
        'gradualVolume': gradualVolume,
      };

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [0, 1, 2, 3, 4, 5, 6],
      challengeType: WakeChallengeType.values[
          (json['challengeType'] as int? ?? 0)
              .clamp(0, WakeChallengeType.values.length - 1)],
      difficulty: ChallengeDifficulty.values[
          (json['difficulty'] as int? ?? 1)
              .clamp(0, ChallengeDifficulty.values.length - 1)],
      questionCount: json['questionCount'] as int? ?? 3,
      ringtoneId: json['ringtoneId'] as String? ?? 'samy_dawn',
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      wakeUpCheck: json['wakeUpCheck'] as bool? ?? false,
      gradualVolume: json['gradualVolume'] as bool? ?? false,
    );
  }
}

enum ReminderCategory {
  work,
  study,
  health,
  fitness,
  personal,
}

extension ReminderCategoryExt on ReminderCategory {
  String get arabicName {
    switch (this) {
      case ReminderCategory.work:
        return 'عمل ومشاريع';
      case ReminderCategory.study:
        return 'دراسة ومذاكرة';
      case ReminderCategory.health:
        return 'صحة وأدوية';
      case ReminderCategory.fitness:
        return 'رياضة وجيم';
      case ReminderCategory.personal:
        return 'شخصي ومواعيد';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderCategory.work:
        return Icons.work_rounded;
      case ReminderCategory.study:
        return Icons.menu_book_rounded;
      case ReminderCategory.health:
        return Icons.medication_rounded;
      case ReminderCategory.fitness:
        return Icons.fitness_center_rounded;
      case ReminderCategory.personal:
        return Icons.star_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReminderCategory.work:
        return const Color(0xFF0066FF);
      case ReminderCategory.study:
        return const Color(0xFF00B4D8);
      case ReminderCategory.health:
        return const Color(0xFF00C875);
      case ReminderCategory.fitness:
        return const Color(0xFFFF8800);
      case ReminderCategory.personal:
        return const Color(0xFF7B2CBF);
    }
  }
}

class ReminderItem {
  final String id;
  final String title;
  final String notes;
  final DateTime scheduledAt;
  final ReminderCategory category;
  final bool isCompleted;
  final bool isHighPriority;
  final String ringtoneId;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.notes,
    required this.scheduledAt,
    this.category = ReminderCategory.personal,
    this.isCompleted = false,
    this.isHighPriority = false,
    this.ringtoneId = 'samy_chime',
  });

  ReminderItem copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? scheduledAt,
    ReminderCategory? category,
    bool? isCompleted,
    bool? isHighPriority,
    String? ringtoneId,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      ringtoneId: ringtoneId ?? this.ringtoneId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'scheduledAt': scheduledAt.toIso8601String(),
        'category': category.index,
        'isCompleted': isCompleted,
        'isHighPriority': isHighPriority,
        'ringtoneId': ringtoneId,
      };

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String? ?? '',
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
          DateTime.now().add(const Duration(hours: 2)),
      category: ReminderCategory.values[(json['category'] as int? ?? 4)
          .clamp(0, ReminderCategory.values.length - 1)],
      isCompleted: json['isCompleted'] as bool? ?? false,
      isHighPriority: json['isHighPriority'] as bool? ?? false,
      ringtoneId: json['ringtoneId'] as String? ?? 'samy_chime',
    );
  }
}
