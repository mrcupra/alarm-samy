import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ProPaywallScreen extends StatefulWidget {
  final AppState appState;

  const ProPaywallScreen({super.key, required this.appState});

  @override
  State<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends State<ProPaywallScreen> {
  int _selectedPlanIndex = 0;

  static const List<Map<String, String>> _plans = [
    {
      'title': 'تجربة مجانية شاملة (٧ أيام)',
      'price': 'مجاناً الآن (٠.٠٠ \$)',
      'subtitle': 'افتح جميع مميزات Pro فوراً بدون أي رسوم اليوم',
      'badge': 'موصى به للتجربة ⭐',
    },
    {
      'title': 'باقة Alarm Samy Pro السنوية',
      'price': '١٤.٩٩ \$ / سنوياً',
      'subtitle': 'توفير ٦٠٪ • أقل من ١.٢٥ \$ شهرياً',
      'badge': 'الأكثر شعبية 🔥',
    },
    {
      'title': 'باقة Alarm Samy Pro الشهرية',
      'price': '٢.٩٩ \$ / شهرياً',
      'subtitle': 'اشتراك شهري مرن يمكنك إلغاؤه في أي وقت',
      'badge': 'مرن',
    },
    {
      'title': 'النسخة الملكية مدى الحياة 👑',
      'price': '٢٩.٩٩ \$ مرة واحدة',
      'subtitle': 'امتلك جميع المميزات والتحديثات المستقبلية للأبد',
      'badge': 'ملكي للأبد 👑',
    },
  ];

  static const List<Map<String, dynamic>> _comparisonRows = [
    {
      'feature': 'عدد المنبهات والتذكيرات',
      'free': 'حتى ٤ منبهات و ٦ تذكيرات',
      'pro': 'غير محدود ♾️',
    },
    {
      'feature': 'تحدي المعادلات الحسابية وشحن الطاقة',
      'free': 'متاح ✅',
      'pro': 'متاح + المستوى الخارق 🔥',
    },
    {
      'feature': 'تحدي الذاكرة المضيئة وترتيب الأرقام',
      'free': '—',
      'pro': 'حصري للبرو 👑',
    },
    {
      'feature': 'تحدي التركيز اللوني المخادع (Stroop)',
      'free': '—',
      'pro': 'حصري للبرو 👑',
    },
    {
      'feature': 'التأكد من الاستيقاظ بعد ٥ دقائق',
      'free': '—',
      'pro': 'حصري للبرو 👑',
    },
    {
      'feature': 'نغمة الصاعقة للنوم الثقيل + تدرج الصوت',
      'free': '—',
      'pro': 'حصري للبرو 👑',
    },
    {
      'feature': 'إضافة نغمات مخصصة وتأليف الألحان',
      'free': 'متاح ✅',
      'pro': 'استوديو كامل مفتوح 🎵',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;
    final isPro = widget.appState.isPro;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        // Hero Banner
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: SamyColors.proGradient(),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: SamyColors.primaryBlue.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SamyColors.proGold.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: SamyColors.proGold,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPro
                          ? 'حالتك الحالية: ${widget.appState.proPlanTitle} 👑'
                          : 'حالتك الحالية: النسخة المجانية (Free Tier)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Alarm Samy PRO 👑',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'وداعاً للنوم الثقيل والتأخر عن المواعيد! افتح أقوى تحديات العقل والذاكرة ونغمات الإنذار القصوى.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isPro) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    widget.appState.switchToFreeTierForTesting();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'تم التبديل إلى النسخة المجانية لتجربة الفروق بين النسختين'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text(
                    'التبديل للنسخة المجانية (للتجربة والمعاينة)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Subscription Plan Cards
        const Text(
          'اختر الباقة المناسبة لك (متاح اشتراك مجاني تجريبي):',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...List.generate(_plans.length, (idx) {
          final plan = _plans[idx];
          final selected = _selectedPlanIndex == idx;

          return GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? SamyColors.primaryBlue.withValues(alpha: 0.16)
                    : (isDark
                        ? SamyColors.darkSurface
                        : SamyColors.lightSurface),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? SamyColors.electricCyan
                      : (isDark
                          ? SamyColors.darkCardBorder
                          : SamyColors.lightCardBorder),
                  width: selected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected ? SamyColors.electricCyan : Colors.grey,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                plan['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    SamyColors.proGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plan['badge']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: SamyColors.proGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          plan['subtitle']!,
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
                  const SizedBox(width: 8),
                  Text(
                    plan['price']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: isDark
                          ? SamyColors.electricCyan
                          : SamyColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            final chosen = _plans[_selectedPlanIndex];
            widget.appState.activateProPlan(chosen['title']!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: SamyColors.successGreen,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'مبروك! تم تفعيل "${chosen['title']}" وفتح جميع مميزات Alarm Samy Pro 👑',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SamyColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.workspace_premium_rounded,
              color: SamyColors.proGold),
          label: Text(
            isPro
                ? 'تحديث الباقة المفعلة الآن 👑'
                : 'تفعيل الاشتراك المختار مجاناً الآن 🚀',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),

        const SizedBox(height: 24),

        // Comparison Table: Free vs Pro
        const Text(
          'مقارنة النسخة المجانية والنسخة الـ Pro:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? SamyColors.darkCardBorder
                  : SamyColors.lightCardBorder,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: SamyColors.primaryBlue.withValues(alpha: 0.15),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'الميزة',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'المجانية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'نسخة PRO 👑',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: SamyColors.proGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._comparisonRows.map((row) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          row['feature'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row['free'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? SamyColors.darkTextSecondary
                                : SamyColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row['pro'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: SamyColors.electricCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
