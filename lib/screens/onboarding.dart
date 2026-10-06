import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/cosmic_ui.dart';

const onboardingSeenKey = 'onboarding_seen_v1';

Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(onboardingSeenKey) != true;
}

Future<void> markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(onboardingSeenKey, true);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _pages = [
    (
      Icons.auto_awesome_rounded,
      'Your personal kundli',
      'Add birth date, time and place once. We compute your Vedic chart for every reading.',
    ),
    (
      Icons.chat_bubble_rounded,
      'Chat with AI Jyotishi',
      'Ask about love, career, marriage or family. Readings stay grounded in your chart.',
    ),
    (
      Icons.workspace_premium_rounded,
      'Wallet & Monthly Pro',
      'Chat €1/min from wallet. Monthly Pro €11 unlocks full Kundli & palm.',
    ),
  ];

  Future<void> _finish() async {
    await markOnboardingSeen();
    widget.onDone();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.gold,
                              boxShadow: [
                                BoxShadow(color: AppColors.orange.withValues(alpha: 0.35), blurRadius: 24),
                              ],
                            ),
                            child: Icon(p.$1, size: 48, color: AppColors.void_),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            p.$2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            p.$3,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sora(fontSize: 15, color: AppColors.muted, height: 1.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.orange : AppColors.line,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(_index < _pages.length - 1 ? 'Next' : 'Get started'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
