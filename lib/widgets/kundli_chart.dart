import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models.dart';
import '../theme.dart';

/// North-Indian diamond kundli matching Astro AI / AstroTalk layout.
class KundliChart extends StatefulWidget {
  const KundliChart({super.key, required this.chart, this.compact = false});

  final Chart chart;
  final bool compact;

  @override
  State<KundliChart> createState() => _KundliChartState();
}

class _KundliChartState extends State<KundliChart> {
  int _tab = 1; // 0=traditional, 1=lagna, 2=navamsha, 3=chandra

  static const _tabs = ['पारम्परिक', 'लग्न', 'नवमांश', 'चन्द्र'];

  Map<int, List<Planet>> _planetsByHouse() {
    final map = <int, List<Planet>>{};
    for (final p in widget.chart.planets) {
      map.putIfAbsent(p.house, () => []).add(p);
    }
    return map;
  }

  int _signNumForHouse(int house) {
    return signNumber(kSignOrder[(signIndex(widget.chart.risingSign) + house - 1) % 12]);
  }

  /// Centroid + sign-number anchor per house (North Indian fixed layout).
  static const _layout = {
    1: _HouseLayout(Offset(0.50, 0.11), Offset(0.42, 0.16), Alignment.topCenter),
    2: _HouseLayout(Offset(0.79, 0.16), Offset(0.70, 0.22), Alignment.topRight),
    3: _HouseLayout(Offset(0.89, 0.36), Offset(0.80, 0.30), Alignment.centerRight),
    4: _HouseLayout(Offset(0.89, 0.64), Offset(0.80, 0.58), Alignment.centerRight),
    5: _HouseLayout(Offset(0.79, 0.84), Offset(0.70, 0.74), Alignment.bottomRight),
    6: _HouseLayout(Offset(0.50, 0.89), Offset(0.42, 0.78), Alignment.bottomCenter),
    7: _HouseLayout(Offset(0.21, 0.84), Offset(0.30, 0.74), Alignment.bottomLeft),
    8: _HouseLayout(Offset(0.11, 0.64), Offset(0.20, 0.58), Alignment.centerLeft),
    9: _HouseLayout(Offset(0.11, 0.36), Offset(0.20, 0.30), Alignment.centerLeft),
    10: _HouseLayout(Offset(0.21, 0.16), Offset(0.30, 0.22), Alignment.topLeft),
    11: _HouseLayout(Offset(0.33, 0.22), Offset(0.28, 0.28), Alignment.topLeft),
    12: _HouseLayout(Offset(0.67, 0.22), Offset(0.60, 0.28), Alignment.topRight),
  };

  /// Build Navamsha (D9) data from the rashi chart.
  Map<int, List<Planet>> _navamshaByHouse() {
    final chart = widget.chart;
    final lagnaNavSign = navamshaSign(chart.risingSign, chart.risingDegreeInSign);
    final map = <int, List<Planet>>{};
    for (final p in chart.planets) {
      final pNavSign = navamshaSign(p.sign, p.degreeInSign);
      final house = navamshaHouse(lagnaNavSign, pNavSign);
      map.putIfAbsent(house, () => []).add(p);
    }
    return map;
  }

  int _navSignNumForHouse(int house) {
    final lagnaNavSign = navamshaSign(widget.chart.risingSign, widget.chart.risingDegreeInSign);
    final idx = (signIndex(lagnaNavSign) + house - 1) % 12;
    return idx + 1;
  }

  @override
  Widget build(BuildContext context) {
    final isNavamsha = _tab == 2;
    final highlightMoon = _tab == 3;

    final Map<int, List<Planet>> byHouse;
    if (isNavamsha) {
      byHouse = _navamshaByHouse();
    } else {
      byHouse = _planetsByHouse();
    }

    return _wrap(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return Stack(
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: const _KundliGridPainter(),
                ),
                for (final entry in _layout.entries)
                  _HouseOverlay(
                    house: entry.key,
                    layout: entry.value,
                    size: size,
                    signNum: isNavamsha
                        ? _navSignNumForHouse(entry.key)
                        : _signNumForHouse(entry.key),
                    planets: byHouse[entry.key] ?? [],
                    lagnaDegree: (!isNavamsha && entry.key == 1)
                        ? widget.chart.risingDegreeInSign
                        : null,
                    highlightMoon: highlightMoon,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _wrap({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.compact ? 12 : 16),
        border: Border.all(color: const Color(0xFFE8C86A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.compact) _tabBar(),
          Padding(
            padding: EdgeInsets.fromLTRB(widget.compact ? 8 : 12, widget.compact ? 8 : 12, widget.compact ? 8 : 12, widget.compact ? 8 : 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _tab == i;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _tab = i),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _tabs[i],
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Container(
                    height: 2.5,
                    color: selected ? const Color(0xFF111827) : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HouseLayout {
  const _HouseLayout(this.content, this.signAnchor, this.align);
  final Offset content;
  final Offset signAnchor;
  final Alignment align;
}

class _HouseOverlay extends StatelessWidget {
  const _HouseOverlay({
    required this.house,
    required this.layout,
    required this.size,
    required this.signNum,
    required this.planets,
    this.lagnaDegree,
    this.highlightMoon = false,
  });

  final int house;
  final _HouseLayout layout;
  final double size;
  final int signNum;
  final List<Planet> planets;
  final double? lagnaDegree;
  final bool highlightMoon;

  @override
  Widget build(BuildContext context) {
    final signX = layout.signAnchor.dx * size;
    final signY = layout.signAnchor.dy * size;
    final cx = layout.content.dx * size;
    final cy = layout.content.dy * size;

    return Stack(
      children: [
        Positioned(
          left: signX - 8,
          top: signY - 6,
          child: Text(
            '$signNum',
            style: kundliChartStyle(size: 11, color: const Color(0xFF6B7280), weight: FontWeight.w500),
          ),
        ),
        Positioned(
          left: cx - 42,
          top: cy - 4,
          width: 84,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (house == 1 && lagnaDegree != null)
                _PlanetLine(
                  label: 'ल',
                  degree: formatKundliDegree(lagnaDegree!),
                  color: kPlanetColors['Lagna']!,
                  bold: true,
                ),
              ...planets.map((p) {
                final isMoon = p.name == 'Moon';
                final color = kPlanetColors[p.name] ?? const Color(0xFF374151);
                return _PlanetLine(
                  label: kPlanetShort[p.name] ?? p.name.substring(0, 1),
                  degree: formatKundliDegree(p.degreeInSign),
                  color: color,
                  bold: highlightMoon && isMoon,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanetLine extends StatelessWidget {
  const _PlanetLine({
    required this.label,
    required this.degree,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String degree;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: kundliChartStyle(
            size: bold ? 13.5 : 12.5,
            color: color,
            weight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
          children: [
            TextSpan(text: label),
            TextSpan(
              text: degree,
              style: kundliChartStyle(
                size: bold ? 12 : 11,
                color: const Color(0xFF374151),
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KundliGridPainter extends CustomPainter {
  const _KundliGridPainter();

  static const _line = Color(0xFFE8B84B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = _line
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    canvas.drawLine(Offset.zero, Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);

    final cx = w / 2;
    final cy = h / 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, h), paint);
    canvas.drawLine(Offset(0, cy), Offset(w, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
