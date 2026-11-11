import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/alarm_models.dart';
import '../services/app_state.dart';
import '../services/sound_generator_service.dart';
import '../theme/app_theme.dart';

class RemindersTab extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenPaywall;

  const RemindersTab({
    super.key,
    required this.appState,
    required this.onOpenPaywall,
  });

  @override
  State<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends State<RemindersTab> {
  ReminderCategory? _selectedCategory;

  void _openAddReminderSheet(BuildContext context) {
    if (!widget.appState.isPro && widget.appState.reminders.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SamyColors.primaryBlue,
          action: SnackBarAction(
            label: 'تفعيل Pro 👑',
            textColor: SamyColors.proGold,
            onPressed: widget.onOpenPaywall,
          ),
          content: const Text(
            'النسخة المجانية تتيح حتى ٦ تذكيرات نشطة. فعّل النسخة البرو مجاناً لتذكيرات بلا حدود!',
          ),
        ),
      );
      widget.onOpenPaywall();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(appState: widget.appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;
    final allReminders = widget.appState.reminders;
    final filtered = _selectedCategory == null
        ? allReminders
        : allReminders
            .where((r) => r.category == _selectedCategory)
            .toList();

    final completedCount = allReminders.where((r) => r.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        // Top Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: SamyColors.primaryGradient(isDark),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: SamyColors.primaryBlue.withValues(alpha: 0.28),
                blurRadius: 18,
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
                      'التذكيرات والمهام الذكية 📝',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'أنجزت $completedCount من ${allReminders.length} تذكيرات مجدولة بنغمة تنبيه خاصة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _openAddReminderSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: SamyColors.primaryBlue,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_task_rounded, size: 20),
                label: const Text(
                  'تذكير جديد',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  selected: _selectedCategory == null,
                  selectedColor: SamyColors.primaryBlue,
                  label: Text(
                    'الكل (${allReminders.length})',
                    style: TextStyle(
                      color: _selectedCategory == null ? Colors.white : null,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              ...ReminderCategory.values.map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    selected: selected,
                    selectedColor: cat.color,
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: selected ? Colors.white : cat.color,
                    ),
                    label: Text(
                      cat.arabicName,
                      style: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(36),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 60,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 10),
                Text(
                  'لا توجد تذكيرات في هذا القسم حالياً',
                  style: TextStyle(
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
          ...filtered.map((item) => _buildReminderCard(item, isDark)),
      ],
    );
  }

  Widget _buildReminderCard(ReminderItem item, bool isDark) {
    final dt = item.scheduledAt;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'م' : 'ص'}';
    final ringtone = widget.appState.getRingtoneById(item.ringtoneId);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: item.isHighPriority && !item.isCompleted
              ? SamyColors.warningAmber.withValues(alpha: 0.65)
              : (isDark
                  ? SamyColors.darkCardBorder
                  : SamyColors.lightCardBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => widget.appState.toggleReminderCompleted(item.id),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? SamyColors.successGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item.isCompleted
                      ? SamyColors.successGreen
                      : SamyColors.primaryBlue,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.category.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.category.icon,
                            size: 13,
                            color: item.category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category.arabicName,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: item.category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.isHighPriority) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: SamyColors.warningAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'أولوية قصوى 🔥',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: SamyColors.warningAmber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted
                        ? Colors.grey
                        : (isDark ? Colors.white : SamyColors.lightTextPrimary),
                  ),
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.notes,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? SamyColors.darkTextSecondary
                          : SamyColors.lightTextSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 14,
                          color: SamyColors.electricCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SamyColors.electricCyan,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () =>
                          SoundGeneratorService().playRingtone(ringtone),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            size: 15,
                            color: SamyColors.primaryBlue,
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
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.appState.deleteReminder(item.id),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: SamyColors.dangerRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final AppState appState;

  const _AddReminderSheet({required this.appState});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  ReminderCategory _category = ReminderCategory.work;
  bool _isHighPriority = false;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  final String _ringtoneId = 'samy_chime';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF091530) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                const Text(
                  'إضافة تذكير ذكي جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleCtrl.text.trim().isEmpty) return;
                    final reminder = ReminderItem(
                      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                      title: _titleCtrl.text.trim(),
                      notes: _notesCtrl.text.trim(),
                      scheduledAt: _scheduledAt,
                      category: _category,
                      isHighPriority: _isHighPriority,
                      ringtoneId: _ringtoneId,
                    );
                    widget.appState.addReminder(reminder);
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
                    'حفظ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'عنوان التذكير (مثال: موعد الدواء، اجتماع العمل)',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F2044) : const Color(0xFFF0F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F2044) : const Color(0xFFF0F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'التصنيف:',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderCategory.values.map((cat) {
                final selected = _category == cat;
                return ChoiceChip(
                  selected: selected,
                  selectedColor: cat.color,
                  label: Text(
                    cat.arabicName,
                    style: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onSelected: (_) => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _isHighPriority,
              activeTrackColor: SamyColors.warningAmber,
              title: const Text(
                'تذكير عاجل ذو أولوية قصوى 🔥',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              onChanged: (v) => setState(() => _isHighPriority = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: isDark ? Brightness.dark : Brightness.light,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: _scheduledAt,
                  onDateTimeChanged: (dt) => setState(() => _scheduledAt = dt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
