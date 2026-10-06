import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services/kundli_pdf.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import '../widgets/kundli_chart.dart';
import '../widgets/language_picker.dart';
import '../widgets/ux.dart';
import 'profile_setup.dart';
import 'subscription.dart';
import 'kundli_extra_tabs.dart';

/// Kundli: Basic / Charts / Vargas / KP / Ashtakvarga / Dasha / Predictions / …
class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  static const _tabCount = 15;
  late final TabController _tab;
  bool _busyPdf = false;
  bool _upgrading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureRichChart());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _ensureRichChart() async {
    final app = context.read<AppState>();
    final user = app.user;
    if (user == null || !user.profileComplete) return;
    // Always recompute so Predictions / houses / life chapters stay fresh
    setState(() => _upgrading = true);
    try {
      final json = await app.api.recomputeChart();
      if (json['user'] is Map<String, dynamic>) {
        await app.applyUserJson(json['user'] as Map<String, dynamic>);
      } else {
        await app.refreshMe();
      }
    } catch (_) {
      try {
        await app.refreshMe();
      } catch (_) {}
    }
    if (mounted) setState(() => _upgrading = false);
  }

  Future<void> _downloadPdf() async {
    final user = context.read<AppState>().user;
    final chart = user?.chart;
    if (user == null || chart == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busyPdf = true);
    try {
      await KundliPdf.download(user: user, chart: chart, l: l);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).kundliPdfFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyPdf = false);
    }
  }

  Future<void> _sharePdf() async {
    final user = context.read<AppState>().user;
    final chart = user?.chart;
    if (user == null || chart == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busyPdf = true);
    try {
      await KundliPdf.share(user: user, chart: chart, l: l);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).kundliShareFailed}: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final user = app.user;
    final chart = user?.chart;
    final tabs = [
      l.kundliTabBasic,
      l.kundliTabCharts,
      'Vargas',
      l.kundliTabKp,
      l.kundliTabAshtakvarga,
      l.kundliTabDasha,
      'Predictions',
      'Yog',
      'Bhagya',
      'Strength',
      'Gochar',
      'Match',
      'Panchang',
      'Remedies',
      l.kundliTabReport,
    ];

    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        title: Text(l.kundliTitle, style: GoogleFonts.cinzel(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.goldSoft)),
        actions: [
          IconButton(
            tooltip: l.language,
            onPressed: () => pickAppLanguage(context),
            icon: const Icon(Icons.translate_rounded, color: AppColors.goldSoft),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: _busyPdf || chart == null ? null : _sharePdf,
              icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.success),
              label: Text(l.kundliShare, style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
              style: TextButton.styleFrom(
                side: BorderSide(color: AppColors.line.withValues(alpha: 0.9)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          IconButton(
            tooltip: l.kundliDownloadPdf,
            onPressed: _busyPdf || chart == null ? null : _downloadPdf,
            icon: _busyPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                  )
                : const Icon(Icons.picture_as_pdf_rounded, color: AppColors.orange),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.void_,
            unselectedLabelColor: AppColors.muted,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            labelStyle: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.sora(fontWeight: FontWeight.w500, fontSize: 13),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            tabs: [for (final t in tabs) Tab(text: t, height: 36)],
          ),
        ),
      ),
      body: chart == null || user == null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.auto_awesome_rounded,
                title: l.noKundliYet,
                subtitle: l.kundliFullHint,
                actionLabel: l.addBirthDetails,
                onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
              ),
            )
          : Stack(
              children: [
                TabBarView(
                  controller: _tab,
                  children: [
                    _BasicTab(user: user, chart: chart),
                    _ChartsTab(chart: chart),
                    VargasTab(chart: chart),
                    _KpTab(chart: chart),
                    _AshtakvargaTab(chart: chart),
                    _DashaTab(chart: chart),
                    _PredictionsTab(chart: chart),
                    _YogTab(chart: chart),
                    _BhagyaTab(chart: chart),
                    ShadbalaTab(chart: chart),
                    const GocharTab(),
                    const MatchTab(),
                    PanchangTab(chart: chart),
                    RemediesTab(chart: chart),
                    _ReportTab(user: user, chart: chart, onPdf: _downloadPdf),
                  ],
                ),
                if (_upgrading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2, color: AppColors.orange),
                  ),
              ],
            ),
    );
  }

}

TextStyle get _h2 => GoogleFonts.cinzel(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.goldSoft);

class _ChartsTab extends StatelessWidget {
  const _ChartsTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliBirthChart, style: _h2),
        const SizedBox(height: 12),
        CosmicCard(
          padding: const EdgeInsets.all(12),
          borderColor: AppColors.gold.withValues(alpha: 0.3),
          child: KundliChart(chart: chart),
        ),
        const SizedBox(height: 16),
        Text(l.kundliPlanetaryPositions, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < chart.planets.length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.line.withValues(alpha: 0.6)),
                _PlanetRow(planet: chart.planets[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
class _BasicTab extends StatelessWidget {
  const _BasicTab({required this.user, required this.chart});
  final AppUser user;
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = <(String, String)>[
      (l.kundliLabelName, user.name.isNotEmpty ? user.name : '—'),
      (l.kundliLabelDate, _fmtDob(user.dob)),
      (l.kundliLabelTime, _fmtTime(user.birthTime)),
      (l.kundliLabelPlace, user.birthPlace.isNotEmpty ? user.birthPlace : '—'),
      (l.kundliLabelLatitude, user.latitude != null ? user.latitude!.toStringAsFixed(2) : '—'),
      (l.kundliLabelLongitude, user.longitude != null ? user.longitude!.toStringAsFixed(2) : '—'),
      (
        l.kundliLabelTimezone,
        chart.timezoneOffset.isNotEmpty
            ? 'GMT${chart.timezoneOffset}'
            : (chart.timezone.isNotEmpty ? chart.timezone : '—'),
      ),
      (l.kundliLabelSunrise, chart.sunrise.isNotEmpty ? chart.sunrise : '—'),
      (l.kundliLabelSunset, chart.sunset.isNotEmpty ? chart.sunset : '—'),
      (l.kundliLabelAyanamsha, chart.ayanamsa > 0 ? chart.ayanamsa.toStringAsFixed(5) : '—'),
      (l.kundliLabelLagna, '${chart.risingSign} ${chart.risingDegreeInSign.toStringAsFixed(2)}°'),
      (l.kundliLabelMoonSign, '${chart.moonSign} (${chart.nakshatra})'),
      (l.kundliLabelSunSign, chart.sunSign),
    ];

    final manglik = chart.manglik;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliBasicDetails, style: _h2),
        const SizedBox(height: 10),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                _DetailRow(label: rows[i].$1, value: rows[i].$2, striped: i.isEven),
            ],
          ),
        ),
        if (chart.nakshatraDetail.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Moon nakshatra', style: _h2),
          const SizedBox(height: 8),
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chart.nakshatra, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.goldSoft)),
                const SizedBox(height: 8),
                Text(chart.nakshatraDetail, style: GoogleFonts.sora(fontSize: 13.5, height: 1.55, color: AppColors.ink)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(l.kundliManglikAnalysis, style: _h2),
        const SizedBox(height: 10),
        CosmicCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (manglik?.isManglik == true) ? AppColors.danger : AppColors.success,
                ),
                child: Text(
                  manglik?.label ?? '—',
                  style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manglik?.summary ?? l.kundliManglikPending,
                      style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink.withValues(alpha: 0.9)),
                    ),
                    if (manglik != null)
                      for (final r in manglik.reasons)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.muted)),
                              Expanded(
                                child: Text(r, style: GoogleFonts.sora(fontSize: 12, height: 1.4, color: AppColors.muted)),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (chart.doshas != null) ...[
          const SizedBox(height: 20),
          Text('Dosha check', style: _h2),
          const SizedBox(height: 10),
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              chart.doshas!['summary']?.toString() ?? '',
              style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink),
            ),
          ),
          const SizedBox(height: 10),
          for (final raw in ((chart.doshas!['items'] as List?) ?? [])) ...[
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (raw as Map)['name']?.toString() ?? 'Dosha',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                        ),
                      ),
                      Text(
                        '${raw['level'] ?? ''}',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: raw['level'] == 'clear' ? AppColors.success : AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${raw['detail'] ?? ''}',
                    style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _KpTab extends StatelessWidget {
  const _KpTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kp = chart.kp;
    if (kp == null) {
      return Center(
        child: Text(l.kundliKpUnavailable, style: GoogleFonts.sora(color: AppColors.muted)),
      );
    }
    final cusps = (kp['cusps'] as List?) ?? [];
    final planets = (kp['planets'] as List?) ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliKpSystem, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(label: l.kundliLabelLagna, value: '${kp['lagnaNakshatra'] ?? chart.risingSign} · ${kp['lagnaLongitude'] ?? ''}°', striped: true),
              _DetailRow(label: l.kundliSignLord, value: '${kp['lagnaSignLord'] ?? '—'}'),
              _DetailRow(label: l.kundliStarLord, value: '${kp['lagnaStarLord'] ?? '—'}', striped: true),
              _DetailRow(label: l.kundliSubLord, value: '${kp['lagnaSubLord'] ?? '—'}'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(l.kundliHouseCusps, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < cusps.length; i++)
                _DetailRow(
                  label: 'H${(cusps[i] as Map)['house']}',
                  value:
                      '${(cusps[i] as Map)['sign']} ${(cusps[i] as Map)['degreeInSign']}° · SL ${(cusps[i] as Map)['signLord']} · Star ${(cusps[i] as Map)['starLord']} · Sub ${(cusps[i] as Map)['subLord']}',
                  striped: i.isEven,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l.kundliPlanetLords, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < planets.length; i++)
                _DetailRow(
                  label: '${(planets[i] as Map)['name']}',
                  value:
                      '${(planets[i] as Map)['sign']} ${(planets[i] as Map)['degreeInSign']}° · ${(planets[i] as Map)['nakshatra']} · Star ${(planets[i] as Map)['starLord']} · Sub ${(planets[i] as Map)['subLord']} · H${(planets[i] as Map)['house']}',
                  striped: i.isEven,
                ),
            ],
          ),
        ),
        if (kp['note'] != null) ...[
          const SizedBox(height: 12),
          Text('${kp['note']}', style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted)),
        ],
      ],
    );
  }
}

class _AshtakvargaTab extends StatelessWidget {
  const _AshtakvargaTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final av = chart.ashtakvarga;
    if (av == null) {
      return Center(
        child: Text(l.kundliAshtakUnavailable, style: GoogleFonts.sora(color: AppColors.muted)),
      );
    }
    final table = (av['table'] as List?) ?? [];
    final savByHouse = (av['savByHouse'] as List?) ?? table;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliSavTitle, style: _h2),
        const SizedBox(height: 6),
        Text(
          l.kundliSavSubtitle,
          style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < savByHouse.length; i++)
                _DetailRow(
                  label: l.kundliHouseN('${(savByHouse[i] as Map)['house'] ?? (table[i] as Map)['houseFromLagna']}'),
                  value: '${(savByHouse[i] as Map)['sign']} · SAV ${(savByHouse[i] as Map)['sav']}',
                  striped: i.isEven,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l.kundliBhinnaTitle, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < table.length; i++)
                _DetailRow(
                  label: '${(table[i] as Map)['sign']}',
                  value:
                      'Su ${(table[i] as Map)['Sun']} Mo ${(table[i] as Map)['Moon']} Ma ${(table[i] as Map)['Mars']} Me ${(table[i] as Map)['Mercury']} Ju ${(table[i] as Map)['Jupiter']} Ve ${(table[i] as Map)['Venus']} Sa ${(table[i] as Map)['Saturn']} · Σ ${(table[i] as Map)['sav']}',
                  striped: i.isEven,
                ),
            ],
          ),
        ),
        if (av['note'] != null) ...[
          const SizedBox(height: 12),
          Text('${av['note']}', style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted)),
        ],
      ],
    );
  }
}

class _DashaTab extends StatelessWidget {
  const _DashaTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dasha = chart.dasha;
    if (dasha == null) {
      return Center(
        child: Text(
          l.kundliDashaUnavailable,
          style: GoogleFonts.sora(color: AppColors.muted),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliVimshottari, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.kundliMoonIn(dasha.moonNakshatra),
                  style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  l.kundliBalanceOf(dasha.balanceLord, dasha.balanceYears.toStringAsFixed(3)),
                  style: GoogleFonts.sora(fontSize: 13, height: 1.4, color: AppColors.ink.withValues(alpha: 0.9)),
                ),
                if (dasha.currentDetail.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    dasha.currentDetail,
                    style: GoogleFonts.sora(fontSize: 13, height: 1.5, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l.kundliMahadasha, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < dasha.mahadashas.length; i++)
                Container(
                  width: double.infinity,
                  color: dasha.mahadashas[i].current
                      ? AppColors.orange.withValues(alpha: 0.18)
                      : (i.isEven ? AppColors.surfaceLift : AppColors.surface),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dasha.mahadashas[i].planet,
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.ink,
                              ),
                            ),
                            if (dasha.mahadashas[i].current)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  l.kundliCurrent,
                                  style: GoogleFonts.sora(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtDashaDate(dasha.mahadashas[i].start),
                              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                            ),
                            Text(
                              l.kundliTo(_fmtDashaDate(dasha.mahadashas[i].end)),
                              style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                            ),
                            if (dasha.mahadashas[i].years > 0)
                              Text(
                                l.kundliYearsShort(dasha.mahadashas[i].years.toStringAsFixed(2)),
                                style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (dasha.currentAntardashas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Current MD · Antardasha', style: _h2),
          const SizedBox(height: 6),
          Text(
            dasha.currentMahadasha.isNotEmpty
                ? '${dasha.currentMahadasha} mahadasha — full antardasha cycle'
                : 'Antardasha of the running mahadasha',
            style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < dasha.currentAntardashas.length; i++)
                  Container(
                    width: double.infinity,
                    color: dasha.currentAntardashas[i].current
                        ? AppColors.orange.withValues(alpha: 0.18)
                        : (i.isEven ? AppColors.surfaceLift : AppColors.surface),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dasha.currentAntardashas[i].planet,
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              if (dasha.currentAntardashas[i].current)
                                Text(
                                  l.kundliCurrent,
                                  style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.orange),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtDashaDate(dasha.currentAntardashas[i].start),
                              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                            ),
                            Text(
                              l.kundliTo(_fmtDashaDate(dasha.currentAntardashas[i].end)),
                              style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (dasha.pratyantardashas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Pratyantardasha', style: _h2),
          const SizedBox(height: 6),
          Text('Finer timing under the current antardasha', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 8),
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < dasha.pratyantardashas.length; i++)
                  Container(
                    width: double.infinity,
                    color: dasha.pratyantardashas[i].current
                        ? AppColors.orange.withValues(alpha: 0.18)
                        : (i.isEven ? AppColors.surfaceLift : AppColors.surface),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dasha.pratyantardashas[i].planet,
                            style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                        ),
                        Text(
                          '${_fmtDashaDate(dasha.pratyantardashas[i].start)} → ${_fmtDashaDate(dasha.pratyantardashas[i].end)}',
                          style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (dasha.antardashas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l.kundliCurrentAntardasha, style: _h2),
          const SizedBox(height: 8),
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < dasha.antardashas.length; i++)
                  Container(
                    width: double.infinity,
                    color: i.isEven ? AppColors.surfaceLift : AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dasha.antardashas[i].planet,
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fmtDashaDate(dasha.antardashas[i].start),
                              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                            ),
                            Text(
                              l.kundliTo(_fmtDashaDate(dasha.antardashas[i].end)),
                              style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String _fmtDashaDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('d MMM y').format(d);
}

Widget _standardLock(BuildContext context, {required String title, required String subtitle}) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: CosmicCard(
      borderColor: AppColors.orange.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.orange, size: 36),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted, height: 1.45)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: const Text('Subscribe · €11'),
          ),
        ],
      ),
    ),
  );
}

class _PredictionsTab extends StatelessWidget {
  const _PredictionsTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return _standardLock(
        context,
        title: 'Predictions',
        subtitle: 'Detailed Bhav Phal (12 houses) + Graha Phal unlock with Monthly Pro.',
      );
    }
    final houses = ((chart.houses?['houses'] as List?) ?? []).cast<dynamic>();
    final grahas = ((chart.grahaPhal?['planets'] as List?) ?? []).cast<dynamic>();
    final life = chart.lifeAreas;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text('Life areas', style: _h2),
        const SizedBox(height: 6),
        Text(
          'Detailed life chapters from your kundli.',
          style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        if (life.isEmpty)
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Life chapters are refreshing from your birth details…',
                  style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    // Trigger parent refresh by popping and relying on screen rebuild —
                    // call via context.findAncestorState
                    final state = context.findAncestorStateOfType<_KundliScreenState>();
                    state?._ensureRichChart();
                  },
                  child: const Text('Refresh predictions'),
                ),
              ],
            ),
          )
        else
          for (final area in life) ...[
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area['title']?.toString() ?? 'Chapter',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.goldSoft),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    area['body']?.toString() ?? '',
                    style: GoogleFonts.sora(fontSize: 13.5, height: 1.55, color: AppColors.ink.withValues(alpha: 0.92)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 16),
        Text('Bhav Phal (Houses)', style: _h2),
        const SizedBox(height: 6),
        Text(
          chart.houses?['summary']?.toString() ?? 'House-wise results from your lagna.',
          style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        if (houses.isEmpty)
          Text('Open Kundli again after profile save to load house predictions.', style: GoogleFonts.sora(color: AppColors.muted))
        else
          for (final raw in houses) ...[
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'House ${(raw as Map)['house']} · ${raw['sign']}',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                        ),
                      ),
                      Text(
                        '${raw['tone'] ?? ''}',
                        style: GoogleFonts.sora(fontSize: 11, color: AppColors.orange, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${raw['meaning'] ?? ''}',
                    style: GoogleFonts.sora(fontSize: 12, color: AppColors.goldSoft, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${raw['prediction'] ?? ''}',
                    style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink.withValues(alpha: 0.9)),
                  ),
                  if (((raw['planets'] as List?) ?? []).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Planets: ${((raw['planets'] as List?) ?? []).join(', ')}',
                      style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 16),
        Text('Graha Phal (Planets)', style: _h2),
        const SizedBox(height: 6),
        Text(
          chart.grahaPhal?['summary']?.toString() ?? 'Planet-wise results.',
          style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        for (final raw in grahas) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(raw as Map)['name']} · ${raw['sign']} · H${raw['house']}',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                ),
                if ((raw['nature'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text('${raw['nature']}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.goldSoft)),
                ],
                const SizedBox(height: 6),
                Text(
                  '${raw['prediction'] ?? ''}',
                  style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _YogTab extends StatelessWidget {
  const _YogTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return _standardLock(
        context,
        title: 'Yog analysis',
        subtitle: 'Classical yogas (Raja, Gaja Kesari, Dhana & more) unlock with Monthly Pro.',
      );
    }
    final yogas = chart.yogas;
    final list = (yogas?['yogas'] as List?) ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text('Yog', style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: const EdgeInsets.all(14),
          child: Text(
            yogas?['summary']?.toString() ?? 'Refreshing chart for yogas…',
            style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Text('No major yogas flagged — open Report for deeper AI reading.', style: GoogleFonts.sora(color: AppColors.muted))
        else
          for (final raw in list) ...[
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (raw as Map)['name']?.toString() ?? 'Yoga',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                        ),
                      ),
                      Text(
                        '${raw['strength'] ?? ''}',
                        style: GoogleFonts.sora(fontSize: 11, color: AppColors.orange, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${raw['detail'] ?? ''}',
                    style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _BhagyaTab extends StatelessWidget {
  const _BhagyaTab({required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return _standardLock(
        context,
        title: 'Bhagya (fortune)',
        subtitle: '9th-house fortune score, lord placement, and luck guidance with Monthly Pro.',
      );
    }
    final b = chart.bhagya;
    final points = (b?['points'] as List?) ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text('Bhagya', style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b?['label']?.toString() ?? 'Fortune',
                style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
              ),
              const SizedBox(height: 6),
              Text(
                'Score ${b?['score'] ?? '—'} / 100',
                style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                b?['summary']?.toString() ?? 'Refreshing bhagya…',
                style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(label: '9th sign', value: '${b?['ninthSign'] ?? '—'}', striped: true),
              _DetailRow(label: '9th lord', value: '${b?['ninthLord'] ?? '—'}'),
              _DetailRow(
                label: 'Lord house',
                value: b?['ninthLordHouse'] != null
                    ? 'H${b!['ninthLordHouse']} · ${b['ninthLordSign'] ?? ''}'
                    : '—',
                striped: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < points.length; i++) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (points[i] as Map)['title']?.toString() ?? 'Point',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(points[i] as Map)['text'] ?? ''}',
                  style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReportTab extends StatefulWidget {
  const _ReportTab({required this.user, required this.chart, required this.onPdf});
  final AppUser user;
  final Chart chart;
  final VoidCallback onPdf;

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  bool _loadingAi = false;
  String? _aiError;
  Map<String, dynamic>? _aiReport;
  String? _boundLang;

  @override
  void initState() {
    super.initState();
    _aiReport = widget.chart.aiReport;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sub = context.read<AppState>().user?.isSubscribed == true;
      if (sub && (_aiReport == null || (_aiReport!['sections'] is! Map))) {
        _loadAiReport();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.watch<AppState>().locale.languageCode;
    final reportLang = (_aiReport?['language'] as String?) ?? '';
    if (_boundLang != lang) {
      final prev = _boundLang;
      _boundLang = lang;
      if (prev != null && !_loadingAi && (reportLang.isEmpty || reportLang != lang)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadAiReport(force: true);
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant _ReportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chart.aiReport != null) {
      _aiReport = widget.chart.aiReport;
    }
  }

  Future<void> _loadAiReport({bool force = false}) async {
    if (_loadingAi) return;
    if (!force && _aiReport != null && _aiReport!['sections'] is Map) return;
    setState(() {
      _loadingAi = true;
      _aiError = null;
    });
    try {
      final app = context.read<AppState>();
      final json = await app.api.generateAiKundliReport();
      if (json['user'] is Map<String, dynamic>) {
        await app.refreshMe();
      }
      if (!mounted) return;
      setState(() {
        _aiReport = json['aiReport'] as Map<String, dynamic>? ??
            (json['chart'] is Map ? (json['chart'] as Map)['aiReport'] as Map<String, dynamic>? : null);
        _loadingAi = false;
        _boundLang = app.locale.languageCode;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAi = false;
        _aiError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return _standardLock(
        context,
        title: 'Detailed Kundli report',
        subtitle: 'AI reading with Bhagya, Yog & life guidance unlocks with Monthly Pro (€11).',
      );
    }
    final user = widget.user;
    final chart = widget.chart;
    final facts = (chart.report?['facts'] as Map?)?.cast<String, dynamic>();
    final sections = (_aiReport?['sections'] as Map?)?.cast<String, dynamic>();

    final profileRows = <(String, String)>[
      (l.kundliLabelName, user.name.isNotEmpty ? user.name : (facts?['name']?.toString() ?? '—')),
      (l.kundliLabelGender, user.gender.isNotEmpty ? user.gender : '—'),
      (l.kundliLabelDob, _fmtDob(user.dob)),
      (l.kundliLabelBirthTime, _fmtTime(user.birthTime)),
      (l.kundliLabelBirthPlace, user.birthPlace.isNotEmpty ? user.birthPlace : '—'),
      (l.kundliLabelLatitude, user.latitude != null ? user.latitude!.toStringAsFixed(2) : '—'),
      (l.kundliLabelLongitude, user.longitude != null ? user.longitude!.toStringAsFixed(2) : '—'),
      (l.kundliLabelLagna, '${chart.risingSign} ${chart.risingDegreeInSign.toStringAsFixed(2)}°'),
      (l.kundliLabelMoon, '${chart.moonSign} (${chart.nakshatra})'),
      (l.kundliLabelSun, chart.sunSign),
      (l.kundliLabelManglik, chart.manglik?.label ?? '—'),
      (
        l.kundliLabelDasha,
        chart.dasha != null
            ? '${chart.dasha!.balanceLord} · ${l.kundliYearsShort(chart.dasha!.balanceYears.toStringAsFixed(2))}'
            : '—',
      ),
      (l.kundliLabelAyanamsha, chart.ayanamsa > 0 ? chart.ayanamsa.toStringAsFixed(5) : '—'),
      (l.kundliLabelSunrise, chart.sunrise.isNotEmpty ? chart.sunrise : '—'),
      (l.kundliLabelSunset, chart.sunset.isNotEmpty ? chart.sunset : '—'),
    ];

    final sectionOrder = [
      ('personality', l.kundliSectionPersonality),
      ('physical', 'Physical'),
      ('career', l.kundliSectionCareer),
      ('finance', 'Finance'),
      ('marriage', 'Marriage'),
      ('love', l.kundliSectionLove),
      ('education', 'Education'),
      ('health', 'Health'),
      ('family', l.kundliSectionFamily),
      ('travel', 'Travel & Fortune'),
      ('dashaForecast', 'Dasha forecast'),
      ('bhagya', 'Bhagya'),
      ('yog', 'Yog'),
      ('strengths', l.kundliSectionStrengths),
      ('challenges', l.kundliSectionChallenges),
      ('remedies', l.kundliSectionRemedies),
      ('overall', l.kundliSectionOverall),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(l.kundliReportTitle, style: _h2),
        const SizedBox(height: 6),
        Text(
          l.kundliReportBasedOn,
          style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Text(l.kundliBirthProfile, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < profileRows.length; i++)
                _DetailRow(label: profileRows[i].$1, value: profileRows[i].$2, striped: i.isEven),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text(l.kundliAiReading, style: _h2)),
            TextButton.icon(
              onPressed: _loadingAi ? null : () => _loadAiReport(force: true),
              icon: _loadingAi
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 16, color: AppColors.orange),
              label: Text(
                _loadingAi ? l.kundliGenerating : l.kundliRefreshAi,
                style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.ink),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_aiError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(_aiError!, style: GoogleFonts.sora(fontSize: 12, color: AppColors.danger)),
          ),
        if (_loadingAi && sections == null)
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.orange),
                  const SizedBox(height: 12),
                  Text(
                    l.kundliAiWriting,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(fontSize: 13, color: AppColors.ink.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          )
        else if (sections != null)
          ...[
            for (final entry in sectionOrder)
              if ((sections[entry.$1] ?? '').toString().trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                CosmicCard(
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$2,
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${sections[entry.$1]}',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            height: 1.55,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          ]
        else if (chart.lifeAreas.isNotEmpty)
          ...[
            for (final area in chart.lifeAreas) ...[
              const SizedBox(height: 10),
              CosmicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area['title']?.toString() ?? 'Chapter',
                      style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      area['body']?.toString() ?? '',
                      style: GoogleFonts.sora(fontSize: 13, height: 1.55, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ]
        else
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.kundliAiHint,
                style: GoogleFonts.sora(fontSize: 13, color: AppColors.ink.withValues(alpha: 0.9)),
              ),
            ),
          ),
        if (sections != null && chart.lifeAreas.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Life chapters (chart)', style: _h2),
          for (final area in chart.lifeAreas) ...[
            const SizedBox(height: 10),
            CosmicCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area['title']?.toString() ?? 'Chapter',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.goldSoft),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    area['body']?.toString() ?? '',
                    style: GoogleFonts.sora(fontSize: 13, height: 1.55, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.onPdf,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.void_,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: Text(l.kundliDownloadPdf, style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.striped = false});
  final String label;
  final String value;
  final bool striped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: striped ? AppColors.surfaceLift : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
          ),
        ],
      ),
    );
  }
}

class _PlanetRow extends StatelessWidget {
  const _PlanetRow({required this.planet});
  final Planet planet;

  @override
  Widget build(BuildContext context) {
    final color = kPlanetColors[planet.name] ?? const Color(0xFFFF9800);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(
              kPlanetShort[planet.name] ?? planet.name.substring(0, 1),
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planet.name, style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
                Text(
                  '${planet.sign} · ${planet.degreeInSign.toStringAsFixed(2)}° · ${AppLocalizations.of(context).kundliHouseN('${planet.house}')} · ${planet.nakshatra}'
                  '${planet.nakshatraLord.isNotEmpty ? ' (${planet.nakshatraLord})' : ''}',
                  style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtDob(String dob) {
  final d = DateTime.tryParse(dob);
  if (d == null) return dob.isEmpty ? '—' : dob;
  return DateFormat('d MMMM y').format(d);
}

String _fmtTime(String t) {
  final parts = t.split(':');
  if (parts.length < 2) return t.isEmpty ? '—' : t;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return DateFormat('hh:mm a').format(DateTime(2000, 1, 1, h, m));
}

/// Backward-compatible alias used by older navigation.
class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) => const KundliScreen();
}
