import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/alarm_models.dart';
import '../services/app_state.dart';
import '../services/sound_generator_service.dart';
import '../theme/app_theme.dart';

class AlarmRingingScreen extends StatefulWidget {
  final AlarmItem alarm;
  final AppState appState;

  const AlarmRingingScreen({
    super.key,
    required this.alarm,
    required this.appState,
  });

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final math.Random _rng = math.Random();

  int _currentRound = 1;
  late int _totalRounds;
  String? _feedbackMessage;
  bool _isErrorFeedback = false;

  // Math Challenge State
  String _mathExpression = '';
  int _mathCorrectAnswer = 0;
  List<int> _mathChoices = [];

  // Burst Tap Challenge State
  double _energyProgress = 0.0;
  Timer? _energyDecayTimer;

  // Typing Challenge State
  String _targetPhrase = '';
  final TextEditingController _typingController = TextEditingController();

  // Memory Grid State
  List<int> _memoryTargets = [];
  final Set<int> _memorySelected = {};
  bool _isShowingMemoryPattern = false;

  // Number Order State
  List<int> _scrambledNumbers = [];
  List<int> _sortedNumbers = [];
  int _nextOrderIndex = 0;

  // Color Match (Stroop) State
  String _stroopWordText = '';
  Color _stroopInkColor = Colors.blue;
  String _stroopCorrectColorName = '';
  final List<MapEntry<String, Color>> _colorOptions = const [
    MapEntry('أزرق', Color(0xFF0066FF)),
    MapEntry('أخضر', Color(0xFF00C875)),
    MapEntry('أحمر', Color(0xFFFF3B5C)),
    MapEntry('ذهبي', Color(0xFFFFB800)),
  ];

  static const List<String> _morningPhrases = [
    'أنا مستيقظ بكل طاقة ونشاط اليوم',
    'النجاح يبدأ بخطوة قوية كل صباح',
    'يوم جديد مليء بالإنجاز والتفاؤل',
    'لا مكان للكسل طموحي أكبر من النوم',
  ];

  @override
  void initState() {
    super.initState();
    _totalRounds = widget.alarm.questionCount.clamp(1, 5);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _setupCurrentChallengeRound();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _energyDecayTimer?.cancel();
    _typingController.dispose();
    super.dispose();
  }

  void _setupCurrentChallengeRound() {
    _feedbackMessage = null;
    _isErrorFeedback = false;

    switch (widget.alarm.challengeType) {
      case WakeChallengeType.math:
        _generateMathQuestion();
        break;
      case WakeChallengeType.burstTap:
        _setupBurstTap();
        break;
      case WakeChallengeType.typing:
        _targetPhrase =
            _morningPhrases[_rng.nextInt(_morningPhrases.length)];
        _typingController.clear();
        break;
      case WakeChallengeType.memoryGrid:
        _setupMemoryGrid();
        break;
      case WakeChallengeType.numberOrder:
        _setupNumberOrder();
        break;
      case WakeChallengeType.colorMatch:
        _setupColorMatch();
        break;
    }
    setState(() {});
  }

  void _generateMathQuestion() {
    int a, b, c;
    switch (widget.alarm.difficulty) {
      case ChallengeDifficulty.easy:
        a = _rng.nextInt(25) + 8;
        b = _rng.nextInt(25) + 6;
        _mathExpression = '$a + $b';
        _mathCorrectAnswer = a + b;
        break;
      case ChallengeDifficulty.medium:
        a = _rng.nextInt(11) + 4;
        b = _rng.nextInt(9) + 3;
        c = _rng.nextInt(20) + 5;
        _mathExpression = '($a × $b) + $c';
        _mathCorrectAnswer = (a * b) + c;
        break;
      case ChallengeDifficulty.hard:
        a = _rng.nextInt(16) + 11;
        b = _rng.nextInt(8) + 4;
        c = _rng.nextInt(30) + 12;
        _mathExpression = '($a × $b) - $c';
        _mathCorrectAnswer = (a * b) - c;
        break;
      case ChallengeDifficulty.extreme:
        a = _rng.nextInt(22) + 14;
        b = _rng.nextInt(12) + 6;
        c = _rng.nextInt(55) + 25;
        final d = _rng.nextInt(25) + 10;
        _mathExpression = '($a × $b) + $c - $d';
        _mathCorrectAnswer = (a * b) + c - d;
        break;
    }

    final Set<int> choices = {_mathCorrectAnswer};
    while (choices.length < 4) {
      final delta = (_rng.nextInt(9) + 1) * (_rng.nextBool() ? 1 : -1);
      final candidate = _mathCorrectAnswer + delta;
      if (candidate != _mathCorrectAnswer) {
        choices.add(candidate);
      }
    }
    _mathChoices = choices.toList()..shuffle(_rng);
  }

  void _setupBurstTap() {
    _energyProgress = 0.0;
    _energyDecayTimer?.cancel();
    _energyDecayTimer =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      if (_energyProgress > 0 && _energyProgress < 1.0) {
        setState(() {
          _energyProgress = (_energyProgress - 0.012).clamp(0.0, 1.0);
        });
      }
    });
  }

  void _setupMemoryGrid() {
    final int count = widget.alarm.difficulty == ChallengeDifficulty.easy
        ? 3
        : widget.alarm.difficulty == ChallengeDifficulty.medium
            ? 4
            : 5;
    final List<int> indices = List.generate(9, (i) => i)..shuffle(_rng);
    _memoryTargets = indices.take(count).toList();
    _memorySelected.clear();
    _isShowingMemoryPattern = true;

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isShowingMemoryPattern = false;
        });
      }
    });
  }

  void _setupNumberOrder() {
    final Set<int> nums = {};
    while (nums.length < 9) {
      nums.add(_rng.nextInt(89) + 10);
    }
    _scrambledNumbers = nums.toList()..shuffle(_rng);
    _sortedNumbers = List<int>.from(_scrambledNumbers)..sort();
    _nextOrderIndex = 0;
  }

  void _setupColorMatch() {
    final wordIdx = _rng.nextInt(_colorOptions.length);
    int inkIdx = _rng.nextInt(_colorOptions.length);
    if (inkIdx == wordIdx) {
      inkIdx = (inkIdx + 1) % _colorOptions.length;
    }
    _stroopWordText = _colorOptions[wordIdx].key;
    _stroopInkColor = _colorOptions[inkIdx].value;
    _stroopCorrectColorName = _colorOptions[inkIdx].key;
  }

  void _onRoundSuccess() {
    if (_currentRound < _totalRounds) {
      SoundGeneratorService().playSuccessChime();
      setState(() {
        _currentRound++;
        _feedbackMessage = 'إجابة صحيحة! استمر للخطوة التالية 💪';
        _isErrorFeedback = false;
      });
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          _setupCurrentChallengeRound();
        }
      });
    } else {
      widget.appState.completeActiveAlarmChallenge();
    }
  }

  void _onRoundError(String msg) {
    SoundGeneratorService().playErrorBuzz();
    setState(() {
      _feedbackMessage = msg;
      _isErrorFeedback = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.appState.now;
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final periodStr = now.hour >= 12 ? 'مساءً' : 'صباحاً';

    return Scaffold(
      backgroundColor: const Color(0xFF040A18),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF030917),
              Color(0xFF0A1D45),
              Color(0xFF040B1A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: [
                // Top Alarm Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: SamyColors.primaryBlue.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: SamyColors.electricCyan.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: SamyColors.electricCyan,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'منبه سامي يرن الآن • حل التحدي للإيقاف',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Animated Pulsing Clock Header
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.06);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [
                              SamyColors.primaryBlue.withValues(alpha: 0.35),
                              SamyColors.electricCyan.withValues(alpha: 0.12),
                            ],
                          ),
                          border: Border.all(
                            color: SamyColors.electricCyan.withValues(
                                alpha: 0.35 + (_pulseController.value * 0.45)),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SamyColors.primaryBlue.withValues(
                                  alpha: 0.3 + (_pulseController.value * 0.25)),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontSize: 54,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  periodStr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: SamyColors.electricCyan,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.alarm.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD0E4FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Challenge Progress Bar
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2046).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF234B99),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.alarm.challengeType.icon,
                                color: SamyColors.electricCyan,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.alarm.challengeType.arabicTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  SamyColors.primaryBlue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'التحدي $_currentRound من $_totalRounds',
                              style: const TextStyle(
                                color: SamyColors.electricCyan,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _currentRound / _totalRounds,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF07132B),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            SamyColors.electricCyan,
                          ),
                        ),
                      ),
                      if (_feedbackMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (_isErrorFeedback
                                    ? SamyColors.dangerRed
                                    : SamyColors.successGreen)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isErrorFeedback
                                  ? SamyColors.dangerRed
                                  : SamyColors.successGreen,
                            ),
                          ),
                          child: Text(
                            _feedbackMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isErrorFeedback
                                  ? const Color(0xFFFF8FA3)
                                  : const Color(0xFF6BFFB8),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _buildActiveChallengeBody(),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Snooze Button
                TextButton.icon(
                  onPressed: () => widget.appState.snoozeActiveAlarm(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(
                    Icons.snooze_rounded,
                    color: Color(0xFF9AB8E8),
                  ),
                  label: Text(
                    'غفوة مؤقتة (${widget.alarm.snoozeMinutes} دقائق)',
                    style: const TextStyle(
                      color: Color(0xFF9AB8E8),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChallengeBody() {
    switch (widget.alarm.challengeType) {
      case WakeChallengeType.math:
        return _buildMathChallenge();
      case WakeChallengeType.burstTap:
        return _buildBurstTapChallenge();
      case WakeChallengeType.typing:
        return _buildTypingChallenge();
      case WakeChallengeType.memoryGrid:
        return _buildMemoryGridChallenge();
      case WakeChallengeType.numberOrder:
        return _buildNumberOrderChallenge();
      case WakeChallengeType.colorMatch:
        return _buildColorMatchChallenge();
    }
  }

  Widget _buildMathChallenge() {
    return Column(
      children: [
        const Text(
          'اختر الناتج الصحيح للمعادلة التالية:',
          style: TextStyle(
            color: Color(0xFFA8C5F0),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF07132B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: SamyColors.primaryBlue.withValues(alpha: 0.6),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$_mathExpression = ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mathChoices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final val = _mathChoices[index];
            return ElevatedButton(
              onPressed: () {
                if (val == _mathCorrectAnswer) {
                  _onRoundSuccess();
                } else {
                  _onRoundError('إجابة خاطئة! ركز وحاول مرة أخرى 🧠');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17336E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: SamyColors.electricCyan.withValues(alpha: 0.45),
                  ),
                ),
              ),
              child: Text(
                '$val',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBurstTapChallenge() {
    final pct = (_energyProgress * 100).round();
    return Column(
      children: [
        const Text(
          'اضغط بسرعة متتالية لشحن طاقة الاستيقاظ حتى 100% قبل أن ينخفض العداد!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA8C5F0), fontSize: 14),
        ),
        const SizedBox(height: 18),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: _energyProgress,
                strokeWidth: 12,
                backgroundColor: const Color(0xFF07132B),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(SamyColors.electricCyan),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _energyProgress = (_energyProgress + 0.085).clamp(0.0, 1.0);
                });
                if (_energyProgress >= 1.0) {
                  _energyDecayTimer?.cancel();
                  _onRoundSuccess();
                }
              },
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SamyColors.primaryGradient(true),
                  boxShadow: [
                    BoxShadow(
                      color: SamyColors.electricCyan.withValues(alpha: 0.45),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 38),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'اضغط بقوة!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypingChallenge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'اكتب العبارة الصباحية التالية لإيقاف المنبه:',
          style: TextStyle(color: Color(0xFFA8C5F0), fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF07132B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SamyColors.electricCyan),
          ),
          child: Text(
            _targetPhrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _typingController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'اكتب العبارة هنا...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF07132B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF234B99)),
            ),
          ),
          onChanged: (val) {
            if (val.trim() == _targetPhrase.trim()) {
              _onRoundSuccess();
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            if (_typingController.text.trim() == _targetPhrase.trim()) {
              _onRoundSuccess();
            } else {
              _onRoundError('العبارة غير مطابقة تماماً، تأكد من الحروف!');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SamyColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text(
            'تحقق من الكتابة',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryGridChallenge() {
    return Column(
      children: [
        Text(
          _isShowingMemoryPattern
              ? 'احفظ مواقع المربعات الزرقاء المضيئة الآن! 👀'
              : 'اضغط على المربعات التي أضاءت (${_memorySelected.length}/${_memoryTargets.length})',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFA8C5F0),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 240,
          height: 240,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final isTarget = _memoryTargets.contains(index);
              final isSelected = _memorySelected.contains(index);
              final bool lit =
                  (_isShowingMemoryPattern && isTarget) || isSelected;

              return GestureDetector(
                onTap: _isShowingMemoryPattern
                    ? null
                    : () {
                        if (isTarget) {
                          setState(() {
                            _memorySelected.add(index);
                          });
                          if (_memorySelected.length == _memoryTargets.length) {
                            _onRoundSuccess();
                          }
                        } else {
                          _onRoundError('مربع خاطئ! ركز في النمط الجديد 🔄');
                          _setupMemoryGrid();
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: lit
                        ? SamyColors.electricCyan
                        : const Color(0xFF081530),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: lit
                          ? Colors.white
                          : SamyColors.primaryBlue.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: lit
                        ? [
                            BoxShadow(
                              color: SamyColors.electricCyan
                                  .withValues(alpha: 0.6),
                              blurRadius: 14,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      lit ? Icons.star_rounded : Icons.circle_outlined,
                      color: lit ? const Color(0xFF041028) : Colors.white24,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberOrderChallenge() {
    return Column(
      children: [
        const Text(
          'اضغط على الأرقام ترتيباً من الأصغر إلى الأكبر:',
          style: TextStyle(color: Color(0xFFA8C5F0), fontSize: 14),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 250,
          height: 250,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _scrambledNumbers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final numVal = _scrambledNumbers[index];
              final expectedIndex = _sortedNumbers.indexOf(numVal);
              final isAlreadyTapped = expectedIndex < _nextOrderIndex;

              return ElevatedButton(
                onPressed: isAlreadyTapped
                    ? null
                    : () {
                        if (numVal == _sortedNumbers[_nextOrderIndex]) {
                          setState(() {
                            _nextOrderIndex++;
                          });
                          if (_nextOrderIndex >= _sortedNumbers.length) {
                            _onRoundSuccess();
                          }
                        } else {
                          _onRoundError(
                              'ترتيب غير صحيح! ابحث عن أصغر رقم متبقٍ');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyTapped
                      ? SamyColors.successGreen.withValues(alpha: 0.25)
                      : const Color(0xFF162F66),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isAlreadyTapped
                          ? SamyColors.successGreen
                          : SamyColors.electricCyan.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Text(
                  '$numVal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isAlreadyTapped
                        ? SamyColors.successGreen
                        : Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorMatchChallenge() {
    return Column(
      children: [
        const Text(
          'اختر لون الحبر الفعلي للكلمة (وليس النص المكتوب!):',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA8C5F0), fontSize: 14),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF07132B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            _stroopWordText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: _stroopInkColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _colorOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final entry = _colorOptions[index];
            return ElevatedButton(
              onPressed: () {
                if (entry.key == _stroopCorrectColorName) {
                  _onRoundSuccess();
                } else {
                  _onRoundError('خدعة بصرية! اختر لون الخط نفسه وليس الكلمة!');
                  _setupColorMatch();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162F66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
