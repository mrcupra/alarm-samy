import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/sound_generator_service.dart';
import '../theme/app_theme.dart';

class EpicSplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const EpicSplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<EpicSplashScreen> createState() => _EpicSplashScreenState();
}

class _EpicSplashScreenState extends State<EpicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _loopController;
  late AnimationController _shimmerController;
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  static const List<Map<String, dynamic>> _introSlides = [
    {
      'badge': 'منبه لا يعرف الكسل ⚡',
      'title': 'استيقظ بقوة مع Alarm Samy',
      'desc':
          'وداعاً لإغلاق المنبه والعودة للنوم! تصميم عربي فخم باللون الأزرق الملكي مع رادار حي وحاسبة دورات النوم الذكية.',
      'icon': Icons.bolt_rounded,
    },
    {
      'badge': 'تحديات تنشيط العقل 🧠',
      'title': 'معادلات حسابية وألعاب ذاكرة',
      'desc':
          'لن يتوقف الرنين حتى تحل معادلات حسابية متدرجة، أو تتجاوز تحدي الذاكرة المضيئة وترتيب الأرقام السريع!',
      'icon': Icons.calculate_rounded,
    },
    {
      'badge': 'استوديو النغمات والتذكيرات 👑',
      'title': 'نغمات صاعقة وتذكيرات ذكية',
      'desc':
          'أضف نغماتك الخاصة من جهازك، أو ألّف لحنك الموسيقي، ونظّم مواعيدك وتذكيراتك اليومية في مكان واحد.',
      'icon': Icons.workspace_premium_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Play startup sound chime after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundGeneratorService().playStartupChime();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loopController.dispose();
    _shimmerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );
    final fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF030816),
      body: Stack(
        children: [
          // 1. Animated Cosmic Cyber-Blue Background & Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loopController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CosmicSplashPainter(
                    progress: _loopController.value,
                  ),
                );
              },
            ),
          ),

          // 2. Main Foreground Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 24).clamp(0, double.infinity),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Top Bar: Sound Preview + Skip Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  SoundGeneratorService().playStartupChime();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: SamyColors.primaryBlue
                                      .withValues(alpha: 0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: SamyColors.electricCyan
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  color: SamyColors.electricCyan,
                                  size: 18,
                                ),
                                label: const Text(
                                  'تجربة الصوت 🔊',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onFinish,
                                child: const Text(
                                  'تخطي للدخول ⬅',
                                  style: TextStyle(
                                    color: Color(0xFF9AC0F8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(flex: 1),

                          // 3. Centerpiece: Animated 3D Logo with Orbiting Rings & Floating Badges
                          ScaleTransition(
                            scale: scaleAnim,
                            child: AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_loopController, _shimmerController]),
                              builder: (context, _) {
                                final floatOffset = math.sin(
                                        _shimmerController.value * math.pi) *
                                    8.0;
                                final glowSpread =
                                    6.0 + (_shimmerController.value * 12);

                                return Transform.translate(
                                  offset: Offset(0, -floatOffset),
                                  child: SizedBox(
                                    width: 240,
                                    height: 240,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Rotating Outer Cyber Ring
                                        Transform.rotate(
                                          angle: _loopController.value *
                                              2 *
                                              math.pi,
                                          child: Container(
                                            width: 228,
                                            height: 228,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: SamyColors.electricCyan
                                                    .withValues(alpha: 0.35),
                                                width: 1.8,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Counter-Rotating Dashed/Glowing Ring
                                        Transform.rotate(
                                          angle: -_loopController.value *
                                              2 *
                                              math.pi,
                                          child: CustomPaint(
                                            size: const Size(202, 202),
                                            painter: _OrbitRingPainter(),
                                          ),
                                        ),

                                        // Main 3D App Logo Image with Neon Aura
                                        Container(
                                          width: 152,
                                          height: 152,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(38),
                                            boxShadow: [
                                              BoxShadow(
                                                color: SamyColors.primaryBlue
                                                    .withValues(alpha: 0.65),
                                                blurRadius: 38,
                                                spreadRadius: glowSpread,
                                              ),
                                              BoxShadow(
                                                color: SamyColors.electricCyan
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            border: Border.all(
                                              color: SamyColors.electricCyan
                                                  .withValues(alpha: 0.8),
                                              width: 2.2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(36),
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                decoration: BoxDecoration(
                                                  gradient: SamyColors
                                                      .primaryGradient(true),
                                                ),
                                                child: const Icon(
                                                  Icons.alarm_rounded,
                                                  size: 72,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Floating Mini Feature Pills Around Logo
                                        Positioned(
                                          top: 6,
                                          right: 4,
                                          child: _buildFloatingChip(
                                            icon: Icons.calculate_rounded,
                                            text: 'معادلات ذكية',
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 4,
                                          child: _buildFloatingChip(
                                            icon: Icons.bolt_rounded,
                                            text: 'تحديات الاستيقاظ',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Brand Title & Tagline
                          FadeTransition(
                            opacity: fadeAnim,
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color(0xFF8BE4FF),
                                      Colors.white,
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'ALARM SAMY',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'منبه سامي الذكي • الإصدار الملكي للآيفون 👑',
                                  style: TextStyle(
                                    color: SamyColors.electricCyan,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 1),

                          // 4. Interactive Animated Feature Carousel Card
                          FadeTransition(
                            opacity: fadeAnim,
                            child: SizedBox(
                              height: 168,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _introSlides.length,
                                onPageChanged: (idx) {
                                  setState(() => _currentSlide = idx);
                                },
                                itemBuilder: (context, index) {
                                  final slide = _introSlides[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B1A3A)
                                          .withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                        color: SamyColors.electricCyan
                                            .withValues(alpha: 0.35),
                                        width: 1.4,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: SamyColors
                                                    .primaryGradient(true),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                slide['icon'] as IconData,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: SamyColors.primaryBlue
                                                    .withValues(alpha: 0.25),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                slide['badge'] as String,
                                                style: const TextStyle(
                                                  color:
                                                      SamyColors.electricCyan,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          slide['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: Text(
                                            slide['desc'] as String,
                                            style: const TextStyle(
                                              color: Color(0xFFA8C5F0),
                                              fontSize: 12,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Page Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(_introSlides.length, (i) {
                              final active = _currentSlide == i;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 26 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? SamyColors.electricCyan
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 14),

                          // 5. Glowing CTA Button to Enter App
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentSlide < _introSlides.length - 1) {
                                  _pageController.nextPage(
                                    duration:
                                        const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                  );
                                } else {
                                  SoundGeneratorService().playSuccessChime();
                                  widget.onFinish();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SamyColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: SamyColors.electricCyan
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                elevation: 10,
                                shadowColor: SamyColors.primaryBlue,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentSlide < _introSlides.length - 1
                                        ? 'التالي • اكتشف المميزات'
                                        : 'ابدأ تجربة Alarm Samy الآن 🚀',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_back_rounded,
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1D45).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SamyColors.electricCyan.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: SamyColors.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SamyColors.electricCyan, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = SamyColors.electricCyan.withValues(alpha: 0.65);

    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * (math.pi / 2),
        math.pi / 4,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CosmicSplashPainter extends CustomPainter {
  final double progress;

  _CosmicSplashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Deep radial glow in the center
    final center = Offset(size.width / 2, size.height * 0.35);
    final bgGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          SamyColors.primaryBlue.withValues(alpha: 0.32),
          SamyColors.electricCyan.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.7));
    canvas.drawCircle(center, size.width * 0.7, bgGlow);

    // Floating cyber particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 24; i++) {
      final seed = i * 137.5;
      final x = ((seed * 3.1) % size.width);
      final baseY = ((seed * 7.3) % size.height);
      final y = (baseY - (progress * size.height * (0.4 + (i % 3) * 0.2))) %
          size.height;
      final radius = 1.5 + (i % 3) * 1.2;

      particlePaint.color = (i.isEven
              ? SamyColors.electricCyan
              : SamyColors.primaryBlue)
          .withValues(alpha: 0.25 + 0.35 * math.sin(progress * 2 * math.pi + i));
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicSplashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
