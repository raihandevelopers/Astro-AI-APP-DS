import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import 'subscription.dart';

TextStyle get _h2 => GoogleFonts.cinzel(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.goldSoft);

String _ui(BuildContext context, String en) {
  final lang = context.read<AppState>().locale.languageCode;
  const hi = {
    'Divisional charts': 'वर्ग कुंडली',
    'D2–D60 vargas unlock with Monthly Pro.': 'D2–D60 वर्ग मासिक Pro से खुलते हैं।',
    'Refresh Kundli to load vargas.': 'वर्ग लोड करने के लिए कुंडली रीफ़्रेश करें।',
    'Vargas (divisional)': 'वर्ग (विभाजन कुंडली)',
    'Lagna in varga:': 'वर्ग में लग्न:',
    'Planetary strength': 'ग्रह बल',
    'Shadbala-inspired scores unlock with Monthly Pro.': 'षड्बल स्कोर मासिक Pro से खुलते हैं।',
    'Strength': 'बल',
    'Subscribe · €11': 'सब्सक्राइब · €11',
    'Gochar (transits)': 'गोचर',
    'Panchang': 'पंचांग',
    'Muhurat': 'मुहूर्त',
    'Match': 'कुंडली मिलान',
    'Remedies': 'उपाय',
    'Doshas': 'दोष',
  };
  const de = {
    'Divisional charts': 'Divisionshoroskope',
    'Vargas (divisional)': 'Vargas (Divisionen)',
    'Lagna in varga:': 'Lagna im Varga:',
    'Strength': 'Stärke',
    'Planetary strength': 'Planetenstärke',
  };
  const es = {
    'Divisional charts': 'Cartas divisionales',
    'Vargas (divisional)': 'Vargas (divisional)',
    'Lagna in varga:': 'Lagna en varga:',
    'Strength': 'Fuerza',
  };
  const fr = {
    'Divisional charts': 'Thèmes divisionnels',
    'Vargas (divisional)': 'Vargas (divisionnel)',
    'Lagna in varga:': 'Lagna dans le varga :',
    'Strength': 'Force',
  };
  const el = {
    'Divisional charts': 'Διαιρετικοί χάρτες',
    'Vargas (divisional)': 'Vargas',
    'Lagna in varga:': 'Lagna στο varga:',
    'Strength': 'Δύναμη',
  };
  const nl = {
    'Divisional charts': 'Divisiehoroscopen',
    'Vargas (divisional)': 'Vargas (divisie)',
    'Lagna in varga:': 'Lagna in varga:',
    'Strength': 'Kracht',
  };
  final map = switch (lang) {
    'hi' => hi,
    'de' => de,
    'es' => es,
    'fr' => fr,
    'el' => el,
    'nl' => nl,
    _ => const <String, String>{},
  };
  return map[en] ?? en;
}

Widget kundliProLock(BuildContext context, {required String title, required String subtitle}) {
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
            child: Text(_ui(context, 'Subscribe · €11')),
          ),
        ],
      ),
    ),
  );
}

class VargasTab extends StatefulWidget {
  const VargasTab({super.key, required this.chart});
  final Chart chart;

  @override
  State<VargasTab> createState() => _VargasTabState();
}

class _VargasTabState extends State<VargasTab> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return kundliProLock(
        context,
        title: _ui(context, 'Divisional charts'),
        subtitle: _ui(context, 'D2–D60 vargas unlock with Monthly Pro.'),
      );
    }
    final list = widget.chart.vargas ?? [];
    if (list.isEmpty) {
      return Center(child: Text(_ui(context, 'Refresh Kundli to load vargas.'), style: GoogleFonts.sora(color: AppColors.muted)));
    }
    final i = _idx.clamp(0, list.length - 1);
    final v = list[i];
    final planets = ((v['planets'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(_ui(context, 'Vargas (divisional)'), style: _h2),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, j) {
              final selected = j == i;
              return ChoiceChip(
                label: Text('${list[j]['id']}'),
                selected: selected,
                onSelected: (_) => setState(() => _idx = j),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        CosmicCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${v['name']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
              const SizedBox(height: 6),
              Text('${_ui(context, 'Lagna in varga:')} ${v['lagnaSign']}', style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var p = 0; p < planets.length; p++)
                Container(
                  width: double.infinity,
                  color: p.isEven ? AppColors.surfaceLift : AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    '${(planets[p] as Map)['name']} · ${(planets[p] as Map)['sign']} · H${(planets[p] as Map)['house']} · ${(planets[p] as Map)['lord']}',
                    style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShadbalaTab extends StatelessWidget {
  const ShadbalaTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return kundliProLock(
        context,
        title: _ui(context, 'Planetary strength'),
        subtitle: _ui(context, 'Shadbala-inspired scores unlock with Monthly Pro.'),
      );
    }
    final sb = chart.shadbala;
    final planets = ((sb?['planets'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(_ui(context, 'Strength'), style: _h2),
        const SizedBox(height: 6),
        Text(sb?['summary']?.toString() ?? '', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        for (final raw in planets) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('${(raw as Map)['name']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                    ),
                    Text('${raw['score']} · ${raw['label']}', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orange)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: ((raw['score'] as num?)?.toDouble() ?? 0) / 100,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.orange,
                  backgroundColor: AppColors.line,
                ),
                const SizedBox(height: 8),
                Text('${raw['note'] ?? ''}', style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class GocharTab extends StatefulWidget {
  const GocharTab({super.key});

  @override
  State<GocharTab> createState() => _GocharTabState();
}

class _GocharTabState extends State<GocharTab> {
  Map<String, dynamic>? _gochar;
  String? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final json = await context.read<AppState>().api.kundliGochar();
      if (!mounted) return;
      setState(() {
        _gochar = json['gochar'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return kundliProLock(context, title: 'Gochar (transits)', subtitle: 'Live planetary transits unlock with Monthly Pro.');
    }
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    if (_err != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: GoogleFonts.sora(color: AppColors.danger)),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final planets = ((_gochar?['planets'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Row(
          children: [
            Expanded(child: Text('Gochar', style: _h2)),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: AppColors.goldSoft)),
          ],
        ),
        Text(_gochar?['summary']?.toString() ?? '', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        for (final raw in planets) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(raw as Map)['name']} → ${raw['sign']} ${raw['degreeInSign']}° · H${raw['house']}',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text('Natal: ${raw['natalSign']} H${raw['natalHouse']}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 6),
                Text('${raw['note'] ?? ''}', style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class PanchangTab extends StatelessWidget {
  const PanchangTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final p = chart.birthPanchang;
    final today = context.watch<AppState>();
    return _PanchangBody(birth: p, api: today.api);
  }
}

class _PanchangBody extends StatefulWidget {
  const _PanchangBody({required this.birth, required this.api});
  final Map<String, dynamic>? birth;
  final dynamic api;

  @override
  State<_PanchangBody> createState() => _PanchangBodyState();
}

class _PanchangBodyState extends State<_PanchangBody> {
  Map<String, dynamic>? _today;
  Map<String, dynamic>? _muhurat;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final json = await widget.api.kundliPanchang();
      if (!mounted) return;
      setState(() {
        _today = json['panchang'] as Map<String, dynamic>?;
        _muhurat = json['muhurat'] as Map<String, dynamic>?;
      });
    } catch (_) {}
  }

  Widget _block(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();
    final rows = <(String, String)>[
      ('Vara', '${data['vara'] ?? '—'}'),
      ('Tithi', '${data['tithi'] ?? '—'}'),
      ('Nakshatra', '${data['nakshatra'] ?? '—'}'),
      ('Yoga', '${data['yoga'] ?? '—'}'),
      ('Karana', '${data['karana'] ?? '—'}'),
      ('Sun', '${data['sunSign'] ?? '—'}'),
      ('Moon', '${data['moonSign'] ?? '—'}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _h2),
        const SizedBox(height: 8),
        CosmicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  width: double.infinity,
                  color: i.isEven ? AppColors.surfaceLift : AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 100, child: Text(rows[i].$1, style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted))),
                      Expanded(child: Text(rows[i].$2, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (data['summary'] != null) ...[
          const SizedBox(height: 8),
          Text('${data['summary']}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final windows = ((_muhurat?['windows'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        _block('Birth panchang', widget.birth),
        const SizedBox(height: 20),
        _block('Today', _today),
        const SizedBox(height: 20),
        Text('Muhurat snapshot', style: _h2),
        const SizedBox(height: 8),
        Text(_muhurat?['summary']?.toString() ?? 'Loading…', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 10),
        for (final w in windows) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${(w as Map)['purpose']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink))),
                    Text(w['suitable'] == true ? 'OK' : 'Wait', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: w['suitable'] == true ? AppColors.success : AppColors.orange)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${w['note'] ?? ''}', style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class RemediesTab extends StatelessWidget {
  const RemediesTab({super.key, required this.chart});
  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return kundliProLock(context, title: 'Remedies', subtitle: 'Chart-based remedies unlock with Monthly Pro.');
    }
    final r = chart.remedies;
    final items = ((r?['items'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text('Remedies', style: _h2),
        const SizedBox(height: 6),
        Text(r?['summary']?.toString() ?? '', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        for (final raw in items) ...[
          CosmicCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${(raw as Map)['title']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.goldSoft)),
                const SizedBox(height: 8),
                Text('${raw['body'] ?? ''}', style: GoogleFonts.sora(fontSize: 13.5, height: 1.55, color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class MatchTab extends StatefulWidget {
  const MatchTab({super.key});

  @override
  State<MatchTab> createState() => _MatchTabState();
}

class _MatchTabState extends State<MatchTab> {
  final _name = TextEditingController();
  final _dob = TextEditingController(text: '1997-03-20');
  final _time = TextEditingController(text: '14:15');
  final _place = TextEditingController(text: 'Mumbai');
  final _lat = TextEditingController(text: '19.076');
  final _lng = TextEditingController(text: '72.877');
  String _gender = 'female';
  bool _busy = false;
  Map<String, dynamic>? _match;
  String? _err;

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _time.dispose();
    _place.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final json = await context.read<AppState>().api.kundliMatch({
        'name': _name.text.trim().isEmpty ? 'Partner' : _name.text.trim(),
        'dob': _dob.text.trim(),
        'birthTime': _time.text.trim(),
        'birthPlace': _place.text.trim(),
        'latitude': double.tryParse(_lat.text.trim()),
        'longitude': double.tryParse(_lng.text.trim()),
        'gender': _gender,
      });
      if (!mounted) return;
      setState(() {
        _match = json['match'] as Map<String, dynamic>?;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString().replaceFirst('Exception: ', '');
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<AppState>().user?.isSubscribed == true;
    if (!subscribed) {
      return kundliProLock(context, title: 'Gun Milan', subtitle: 'Ashtakoot match-making unlocks with Monthly Pro.');
    }
    final kootas = ((_match?['kootas'] as List?) ?? []);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text('Gun Milan', style: _h2),
        const SizedBox(height: 6),
        Text('Enter partner birth details for Ashtakoot matching with your kundli.', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 12),
        CosmicCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Partner name')),
              TextField(controller: _dob, decoration: const InputDecoration(labelText: 'DOB (YYYY-MM-DD)')),
              TextField(controller: _time, decoration: const InputDecoration(labelText: 'Birth time (HH:mm)')),
              TextField(controller: _place, decoration: const InputDecoration(labelText: 'Birth place')),
              Row(
                children: [
                  Expanded(child: TextField(controller: _lat, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _lng, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                items: const [
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'female'),
                decoration: const InputDecoration(labelText: 'Partner gender'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _run,
                  child: Text(_busy ? 'Matching…' : 'Match kundlis'),
                ),
              ),
            ],
          ),
        ),
        if (_err != null) ...[
          const SizedBox(height: 12),
          Text(_err!, style: GoogleFonts.sora(color: AppColors.danger)),
        ],
        if (_match != null) ...[
          const SizedBox(height: 16),
          CosmicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_match!['verdict']}', style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
                const SizedBox(height: 6),
                Text('${_match!['total']} / ${_match!['max']} gunas · ${_match!['percent']}%', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.orange)),
                const SizedBox(height: 8),
                Text('${_match!['summary']}', style: GoogleFonts.sora(fontSize: 13, height: 1.45, color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final k in kootas) ...[
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(k as Map)['name']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        Text('${k['detail'] ?? ''}', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text('${k['points']}/${k['max']}', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppColors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}
