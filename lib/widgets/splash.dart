import 'package:flutter/material.dart';

import '../theme.dart';

/// Full-logo splash used while the app boots.
class AppSplash extends StatelessWidget {
  const AppSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final logoSize = (w * 0.55).clamp(180.0, 280.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05050A), Color(0xFF1A0F2E), Color(0xFF0D0A14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/logo.jpeg',
                  fit: BoxFit.contain,
                  width: logoSize,
                  height: logoSize,
                ),
              ),
              const SizedBox(height: 28),
              Text('MyFuture', style: brandStyle(size: 34, color: AppColors.goldSoft)),
              const SizedBox(height: 8),
              Text(
                'YOUR FUTURE, OUR AI INSIGHTS',
                style: TextStyle(
                  color: AppColors.goldSoft.withValues(alpha: 0.85),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(flex: 2),
              const CircularProgressIndicator(color: AppColors.orange),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
