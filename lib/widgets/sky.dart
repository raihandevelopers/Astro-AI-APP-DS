import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

class ObservatorySky extends StatefulWidget {
  const ObservatorySky({super.key, required this.height, this.child});
  final double height;
  final Widget? child;

  @override
  State<ObservatorySky> createState() => _ObservatorySkyState();
}

class _ObservatorySkyState extends State<ObservatorySky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          return CustomPaint(
            painter: _SkyPainter(twinkle: _pulse.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.twinkle});
  final double twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF05050A),
          Color(0xFF1A0F2E),
          Color(0xFF0B1220),
          Color(0xFF0B0B14),
        ],
        stops: [0, 0.35, 0.7, 1],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    // Soft purple / neon glow behind logo zone
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.85,
        colors: [
          AppColors.purple.withValues(alpha: 0.35),
          AppColors.neon.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glow);

    final rnd = Random(7);
    for (var i = 0; i < 42; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.72;
      final r = 0.5 + rnd.nextDouble() * 1.8;
      final isBlue = i % 5 == 0;
      final paint = Paint()
        ..color = (isBlue ? AppColors.neon : AppColors.gold).withValues(
          alpha: 0.2 + twinkle * (isBlue ? 0.55 : 0.45),
        );
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // Zodiac-ring hint (gold arc)
    final ring = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18 + twinkle * 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.38),
        width: size.width * 0.55,
        height: size.height * 0.55,
      ),
      ring,
    );

    final dome = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.purpleDeep.withValues(alpha: 0.0),
          AppColors.purpleDeep.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55));
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.42, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, dome);
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => oldDelegate.twinkle != twinkle;
}
