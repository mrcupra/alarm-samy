import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'alarm_ringing_screen.dart';
import 'alarms_tab.dart';
import 'epic_splash_screen.dart';
import 'live_clock_tab.dart';
import 'pro_paywall_screen.dart';
import 'reminders_tab.dart';
import 'ringtones_tab.dart';

class HomeShell extends StatefulWidget {
  final AppState appState;

  const HomeShell({super.key, required this.appState});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _showSplashIntro = true;

  void _goToProTab() {
    setState(() {
      _currentIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show Epic Animated Splash & Intro Screen on launch
    if (_showSplashIntro) {
      return EpicSplashScreen(
        onFinish: () {
          setState(() {
            _showSplashIntro = false;
          });
        },
      );
    }

    // 2. If an alarm is actively ringing, show the full-screen interactive challenge!
    if (widget.appState.activeRingingAlarm != null) {
      return AlarmRingingScreen(
        alarm: widget.appState.activeRingingAlarm!,
        appState: widget.appState,
      );
    }

    final isDark = widget.appState.isDarkMode;
    final isPro = widget.appState.isPro;

    final pages = [
      LiveClockTab(
        appState: widget.appState,
        onOpenPaywall: _goToProTab,
      ),
      AlarmsTab(
        appState: widget.appState,
        onOpenPaywall: _goToProTab,
      ),
      RemindersTab(
        appState: widget.appState,
        onOpenPaywall: _goToProTab,
      ),
      RingtonesTab(
        appState: widget.appState,
        onOpenPaywall: _goToProTab,
      ),
      ProPaywallScreen(appState: widget.appState),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: SamyColors.backgroundGradient(isDark),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Top App Header with 3D Logo
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _showSplashIntro = true);
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                SamyColors.electricCyan.withValues(alpha: 0.7),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: SamyColors.primaryBlue
                                  .withValues(alpha: 0.45),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: SamyColors.primaryGradient(isDark),
                              ),
                              child: const Icon(
                                Icons.alarm_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Alarm Samy',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : SamyColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _goToProTab,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: isPro
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFFFB800),
                                              Color(0xFFFF8800),
                                            ],
                                          )
                                        : SamyColors.primaryGradient(isDark),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isPro ? 'PRO 👑' : 'مجاني',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'منبه سامي الذكي • اضغط على اللوجو لعرض الانترو',
                            overflow: TextOverflow.ellipsis,
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
                    const SizedBox(width: 8),
                    // Theme Switcher Button (Blue/White vs Dark Royal Blue)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: widget.appState.toggleTheme,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SamyColors.darkSurface
                              : SamyColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? SamyColors.darkCardBorder
                                : SamyColors.lightCardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              size: 18,
                              color: isDark
                                  ? SamyColors.electricCyan
                                  : SamyColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDark ? 'دارك أزرق' : 'أبيض وأزرق',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : SamyColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Tab Content with AnimatedSwitcher
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: pages[_currentIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Custom Floating Bottom Navigation Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0A1836).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? SamyColors.electricCyan.withValues(alpha: 0.25)
                  : SamyColors.primaryBlue.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: SamyColors.primaryBlue
                    .withValues(alpha: isDark ? 0.28 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.access_time_filled_rounded,
                label: 'الساعة',
                isDark: isDark,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.alarm_rounded,
                label: 'المنبهات',
                isDark: isDark,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.task_alt_rounded,
                label: 'التذكيرات',
                isDark: isDark,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.library_music_rounded,
                label: 'النغمات',
                isDark: isDark,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.workspace_premium_rounded,
                label: 'نسخة Pro',
                isDark: isDark,
                isGold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
    bool isGold = false,
  }) {
    final selected = _currentIndex == index;
    final activeColor = isGold
        ? SamyColors.proGold
        : (isDark ? SamyColors.electricCyan : SamyColors.primaryBlue);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? activeColor
                  : (isDark
                      ? SamyColors.darkTextSecondary
                      : SamyColors.lightTextSecondary),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
