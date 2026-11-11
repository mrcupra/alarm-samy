import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class LiveClockTab extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenPaywall;

  const LiveClockTab({
    super.key,
    required this.appState,
    required this.onOpenPaywall,
  });

  @override
  State<LiveClockTab> createState() => _LiveClockTabState();
}

class _LiveClockTabState extends State<LiveClockTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _auraController;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  String _arabicWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
      default:
        return 'الأحد';
    }
  }

  String _arabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;
    final now = widget.appState.now;
    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final timeStr =
        '${h12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final secStr = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'مساءً' : 'صباحاً';
    final dateStr =
        '${_arabicWeekday(now.weekday)}، ${now.day} ${_arabicMonth(now.month)} ${now.year}';

    final nextAlarm = widget.appState.nextUpcomingAlarm;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
      children: [
        // Animated Radar Clock Hero Card
        AnimatedBuilder(
          animation: _auraController,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF0A1B3D),
                          Color(0xFF0E2759),
                          Color(0xFF08142C),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFEAF3FF),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                border: Border.all(
                  color: isDark
                      ? SamyColors.electricCyan.withValues(
                          alpha: 0.25 + (_auraController.value * 0.25))
                      : SamyColors.primaryBlue.withValues(alpha: 0.22),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? SamyColors.primaryBlue
                            : const Color(0xFF0055FF))
                        .withValues(alpha: isDark ? 0.28 : 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Streak & Solved Stats Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _buildMiniStatBadge(
                        isDark: isDark,
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFF9F1C),
                        label:
                            'سلسلة الاستيقاظ: ${widget.appState.wakeStreakDays} أيام',
                      ),
                      _buildMiniStatBadge(
                        isDark: isDark,
                        icon: Icons.psychology_alt_rounded,
                        iconColor: SamyColors.electricCyan,
                        label:
                            '${widget.appState.completedChallengesCount} تحدي محلول',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Custom Painted Animated Radar Analog + Digital Clock
                  SizedBox(
                    width: 236,
                    height: 236,
                    child: CustomPaint(
                      painter: _SamyRadarClockPainter(
                        now: now,
                        pulseValue: _auraController.value,
                        isDark: isDark,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  period,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? SamyColors.electricCyan
                                        : SamyColors.primaryBlue,
                                  ),
                                ),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : SamyColors.lightTextPrimary,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ':$secStr',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? SamyColors.electricCyan
                                              : SamyColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dateStr,
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
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Next Upcoming Alarm Banner
                  if (nextAlarm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF07132B)
                            : const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1F4287)
                              : const Color(0xFFBBD6FF),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: SamyColors.primaryGradient(isDark),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.alarm_on_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المنبه القادم: ${nextAlarm.formattedTime12} ${nextAlarm.periodArabic}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : SamyColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  _formatRemainingDuration(
                                      nextAlarm.timeUntilNextTrigger(now)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? SamyColors.electricCyan
                                        : SamyColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                widget.appState.triggerAlarmNow(nextAlarm),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SamyColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text(
                              'تجربة الرنين',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Quick Power Nap Section (قيلولة الطاقة السريعة)
        _buildSectionTitle(
          isDark: isDark,
          icon: Icons.bolt_rounded,
          title: 'قيلولة الطاقة السريعة (ضغطة واحدة)',
          subtitle: 'اضبط منبه قيلولة فوري مع تحدي استيقاظ خفيف',
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [15, 20, 30, 45, 60].map((mins) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    widget.appState.createQuickNapAlarm(mins);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: SamyColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        content: Text(
                          'تم ضبط منبه قيلولة بعد $mins دقيقة بنجاح ⚡',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 112,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? SamyColors.darkSurface
                          : SamyColors.lightSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? SamyColors.darkCardBorder
                            : SamyColors.lightCardBorder,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+$mins د',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? SamyColors.electricCyan
                                  : SamyColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'قيلولة ذكية',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? SamyColors.darkTextSecondary
                                  : SamyColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 22),

        // Smart Sleep Cycles Calculator (حاسبة دورات النوم الذكية)
        _buildSectionTitle(
          isDark: isDark,
          icon: Icons.bedtime_rounded,
          title: 'حاسبة دورات النوم الذكية (لو نمت الآن)',
          subtitle: 'أفضل أوقات الاستيقاظ في نهاية دورة النوم (٩٠ دقيقة) بدون خمول',
        ),
        const SizedBox(height: 10),
        _buildSleepCyclesCard(isDark, now),
      ],
    );
  }

  String _formatRemainingDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    if (hours == 0) {
      return 'يرن بعد $mins دقيقة من الآن';
    }
    return 'يرن بعد $hours ساعة و $mins دقيقة';
  }

  Widget _buildMiniStatBadge({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : SamyColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : SamyColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SamyColors.primaryBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? SamyColors.electricCyan : SamyColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : SamyColors.lightTextPrimary,
                ),
              ),
              Text(
                subtitle,
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
      ],
    );
  }

  Widget _buildSleepCyclesCard(bool isDark, DateTime now) {
    // Add 14 mins average time to fall asleep + 4, 5, 6 cycles of 90 mins
    final cycles = [
      {'cycles': 4, 'mins': 14 + (90 * 4), 'tag': 'نوم كافٍ (٦ ساعات)'},
      {'cycles': 5, 'mins': 14 + (90 * 5), 'tag': 'مثالي جداً ⭐ (٧.٥ ساعة)'},
      {'cycles': 6, 'mins': 14 + (90 * 6), 'tag': 'نوم عميق كامل (٩ ساعات)'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? SamyColors.darkCardBorder : SamyColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: cycles.map((c) {
          final target = now.add(Duration(minutes: c['mins'] as int));
          final h = target.hour % 12 == 0 ? 12 : target.hour % 12;
          final tStr =
              '${h.toString().padLeft(2, '0')}:${target.minute.toString().padLeft(2, '0')} ${target.hour >= 12 ? 'م' : 'ص'}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.nights_stay_rounded,
                      color: SamyColors.electricCyan,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['tag'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: isDark
                                ? Colors.white
                                : SamyColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${c['cycles']} دورات نوم كاملة',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? SamyColors.darkTextSecondary
                                : SamyColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.appState.createQuickNapAlarm(c['mins'] as int);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: SamyColors.primaryBlue,
                        content: Text('تم ضبط منبه دورة النوم على $tStr 🌙'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        SamyColors.primaryBlue.withValues(alpha: 0.14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.add_alarm_rounded,
                    size: 16,
                    color: isDark
                        ? SamyColors.electricCyan
                        : SamyColors.primaryBlue,
                  ),
                  label: Text(
                    tStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? SamyColors.electricCyan
                          : SamyColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SamyRadarClockPainter extends CustomPainter {
  final DateTime now;
  final double pulseValue;
  final bool isDark;

  _SamyRadarClockPainter({
    required this.now,
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer pulsing glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + (pulseValue * 4)
      ..color = (isDark ? SamyColors.electricCyan : SamyColors.primaryBlue)
          .withValues(alpha: 0.18 + (pulseValue * 0.18));
    canvas.drawCircle(center, radius - 4, glowPaint);

    // Track circle
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = isDark
          ? const Color(0xFF173166)
          : SamyColors.primaryBlue.withValues(alpha: 0.14);
    canvas.drawCircle(center, radius - 14, trackPaint);

    // 60 tick marks around the clock
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * (math.pi / 180);
      final isMajor = i % 5 == 0;
      final outerR = radius - 24;
      final innerR = isMajor ? outerR - 10 : outerR - 5;

      final p1 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );

      final tickPaint = Paint()
        ..strokeWidth = isMajor ? 2.4 : 1.2
        ..strokeCap = StrokeCap.round
        ..color = i <= now.second
            ? (isDark ? SamyColors.electricCyan : SamyColors.primaryBlue)
            : (isDark ? Colors.white24 : Colors.black12);

      canvas.drawLine(p1, p2, tickPaint);
    }

    // Sweeping progress arc for current second
    final sweepAngle = (now.second / 60.0) * 2 * math.pi;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [SamyColors.primaryBlue, SamyColors.electricCyan],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 14));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SamyRadarClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isDark != isDark;
  }
}
