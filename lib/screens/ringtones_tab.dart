import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/alarm_models.dart';
import '../services/app_state.dart';
import '../services/sound_generator_service.dart';
import '../theme/app_theme.dart';

class RingtonesTab extends StatefulWidget {
  final AppState appState;
  final VoidCallback onOpenPaywall;

  const RingtonesTab({
    super.key,
    required this.appState,
    required this.onOpenPaywall,
  });

  @override
  State<RingtonesTab> createState() => _RingtonesTabState();
}

class _RingtonesTabState extends State<RingtonesTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    SoundGeneratorService().stopRingtone();
    super.dispose();
  }

  Future<void> _pickAudioFileFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final cleanName = file.name.replaceAll(RegExp(r'\.[^\.]+$'), '');
        final newTone = RingtoneItem(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: '$cleanName 🎵',
          subtitle: 'ملف صوتي مضاف من جهازك (${file.name})',
          category: 'مضاف من الجهاز',
          isPro: false,
          isCustom: true,
          customFilePath: file.path,
          melodyFrequencies: const [
            523.25,
            659.25,
            783.99,
            1046.50,
            783.99,
            1046.50
          ],
        );
        await widget.appState.addCustomRingtone(newTone);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: SamyColors.successGreen,
              content: Text('تمت إضافة النغمة "${newTone.name}" بنجاح!'),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        _openCustomMelodyStudio();
      }
    }
  }

  void _openCustomMelodyStudio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MelodyComposerSheet(appState: widget.appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDarkMode;
    final isPro = widget.appState.isPro;
    final ringtones = widget.appState.allRingtones;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      children: [
        // Studio Hero Card with Animated Equalizer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: SamyColors.primaryGradient(isDark),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: SamyColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استوديو نغمات سامي 🎧',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'استمع لنغمات الاستيقاظ الحصرية أو أضف نغمتك المفضلة من الآيفون أو صمّم لحنك الخاص!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Animated Sound Wave Bars
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, _) {
                      return Row(
                        children: List.generate(5, (i) {
                          final active = _playingId != null;
                          final h = active
                              ? 14.0 +
                                  24.0 *
                                      (0.5 +
                                          0.5 *
                                              math.sin((_waveController.value *
                                                      math.pi *
                                                      2) +
                                                  i))
                              : 12.0 + (i % 2) * 8.0;
                          return Container(
                            width: 5,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickAudioFileFromDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: SamyColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 19),
                      label: const Text(
                        'إضافة نغمة من الجهاز',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openCustomMelodyStudio,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.piano_rounded, size: 19),
                      label: const Text(
                        'تأليف نغمة خاصة',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Ringtones List
        ...ringtones.map((tone) {
          final isPlayingThis = _playingId == tone.id;
          final locked = tone.isPro && !isPro;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPlayingThis
                    ? SamyColors.electricCyan
                    : (isDark
                        ? SamyColors.darkCardBorder
                        : SamyColors.lightCardBorder),
                width: isPlayingThis ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    if (isPlayingThis) {
                      await SoundGeneratorService().stopRingtone();
                      setState(() => _playingId = null);
                    } else {
                      setState(() => _playingId = tone.id);
                      await SoundGeneratorService().playRingtone(tone);
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted && _playingId == tone.id) {
                          setState(() => _playingId = null);
                        }
                      });
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: SamyColors.primaryGradient(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isPlayingThis
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tone.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : SamyColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tone.isPro
                                  ? SamyColors.proGold.withValues(alpha: 0.2)
                                  : SamyColors.primaryBlue
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tone.isPro ? 'PRO 👑' : tone.category,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: tone.isPro
                                    ? SamyColors.proGold
                                    : SamyColors.electricCyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tone.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? SamyColors.darkTextSecondary
                              : SamyColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tone.isCustom)
                  IconButton(
                    onPressed: () =>
                        widget.appState.deleteCustomRingtone(tone.id),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: SamyColors.dangerRed,
                    ),
                  )
                else if (locked)
                  TextButton.icon(
                    onPressed: widget.onOpenPaywall,
                    icon: const Icon(
                      Icons.lock_open_rounded,
                      color: SamyColors.proGold,
                      size: 16,
                    ),
                    label: const Text(
                      'فتح',
                      style: TextStyle(
                        color: SamyColors.proGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _MelodyComposerSheet extends StatefulWidget {
  final AppState appState;

  const _MelodyComposerSheet({required this.appState});

  @override
  State<_MelodyComposerSheet> createState() => _MelodyComposerSheetState();
}

class _MelodyComposerSheetState extends State<_MelodyComposerSheet> {
  final TextEditingController _nameCtrl =
      TextEditingController(text: 'نغمة سامي الخاصة 🎶');
  final List<double> _selectedNotes = [523.25, 659.25, 783.99, 1046.50];
  int _tempoMs = 190;

  static const List<Map<String, dynamic>> _musicalNotes = [
    {'label': 'دو (C5)', 'freq': 523.25},
    {'label': 'ري (D5)', 'freq': 587.33},
    {'label': 'مي (E5)', 'freq': 659.25},
    {'label': 'فا (F5)', 'freq': 698.46},
    {'label': 'صول (G5)', 'freq': 783.99},
    {'label': 'لا (A5)', 'freq': 880.00},
    {'label': 'سي (B5)', 'freq': 987.77},
    {'label': 'دو عالي (C6)', 'freq': 1046.50},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  RingtoneItem _buildTempTone() {
    return RingtoneItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim().isEmpty
          ? 'نغمة مخصصة 🎵'
          : _nameCtrl.text.trim(),
      subtitle:
          'نغمة مؤلفة مكونة من ${_selectedNotes.length} نوتات موسيقية',
      category: 'مخصص 🎹',
      isCustom: true,
      melodyFrequencies:
          _selectedNotes.isEmpty ? [523.25, 783.99] : List.from(_selectedNotes),
      noteDurationMs: _tempoMs,
    );
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
                  'تأليف نغمة منبه مخصصة 🎹',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newTone = _buildTempTone();
                    widget.appState.addCustomRingtone(newTone);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SamyColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('حفظ النغمة'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'اسم النغمة الجديدة',
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F2044) : const Color(0xFFF0F6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'اضغط على النوتات الموسيقية لإضافتها إلى لحن المنبه:',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _musicalNotes.map((n) {
                return ActionChip(
                  backgroundColor:
                      SamyColors.primaryBlue.withValues(alpha: 0.16),
                  avatar: const Icon(
                    Icons.music_note_rounded,
                    size: 16,
                    color: SamyColors.electricCyan,
                  ),
                  label: Text(
                    n['label'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedNotes.add(n['freq'] as double);
                    });
                    SoundGeneratorService().playRingtone(
                      RingtoneItem(
                        id: 'preview_note',
                        name: '',
                        subtitle: '',
                        category: '',
                        melodyFrequencies: [n['freq'] as double],
                        noteDurationMs: 160,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النوتات المختارة (${_selectedNotes.length}):',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedNotes.clear()),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('مسح اللحن'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('سرعة الإيقاع:'),
                Expanded(
                  child: Slider(
                    value: _tempoMs.toDouble(),
                    min: 110,
                    max: 320,
                    activeColor: SamyColors.primaryBlue,
                    onChanged: (v) => setState(() => _tempoMs = v.round()),
                  ),
                ),
                Text('$_tempoMs ms'),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () =>
                  SoundGeneratorService().playRingtone(_buildTempTone()),
              style: ElevatedButton.styleFrom(
                backgroundColor: SamyColors.electricCyan,
                foregroundColor: const Color(0xFF041028),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text(
                'معاينة اللحن بالكامل الآن 🔊',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
