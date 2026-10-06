import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.editing = false});
  final bool editing;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _place = TextEditingController();
  String _gender = '';
  DateTime? _dob;
  TimeOfDay? _time;
  PlaceHit? _picked;
  List<PlaceHit> _hits = [];
  Timer? _debounce;
  final _api = Api();

  @override
  void initState() {
    super.initState();
    final u = context.read<AppState>().user;
    if (u != null) {
      _name.text = u.name;
      _place.text = u.birthPlace;
      _gender = u.gender;
      if (u.dob.isNotEmpty) _dob = DateTime.tryParse(u.dob);
      if (u.birthTime.isNotEmpty) {
        final p = u.birthTime.split(':');
        if (p.length >= 2) {
          _time = TimeOfDay(hour: int.tryParse(p[0]) ?? 12, minute: int.tryParse(p[1]) ?? 0);
        }
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  void _onPlace(String q) {
    _picked = null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (q.trim().length < 2) {
        setState(() => _hits = []);
        return;
      }
      try {
        final hits = await _api.searchPlaces(q.trim());
        if (mounted) setState(() => _hits = hits);
      } catch (_) {}
    });
  }

  String _dobStr() {
    final d = _dob;
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _timeStr() {
    final t = _time;
    if (t == null) return '';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _dob == null || _time == null || (_picked == null && _place.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, date, time and place are required')),
      );
      return;
    }
    final app = context.read<AppState>();
    final existing = app.user;
    final lat = _picked?.latitude ?? existing?.latitude;
    final lon = _picked?.longitude ?? existing?.longitude;
    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a birth place from the suggestions')),
      );
      return;
    }
    final ok = await app.saveProfile({
      'name': _name.text.trim(),
      'gender': _gender,
      'dob': _dobStr(),
      'birthTime': _timeStr(),
      'birthPlace': _picked?.label ?? _place.text.trim(),
      'latitude': lat,
      'longitude': lon,
    });
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.error ?? 'Failed')));
      return;
    }
    if (widget.editing) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AppState>().busy;
    return Scaffold(
      appBar: AppBar(title: Text(widget.editing ? 'Birth details' : 'Your Kundli')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          CosmicCard(
            borderColor: AppColors.orange.withValues(alpha: 0.3),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Accurate birth time = accurate kundli. Use hospital records if possible.',
                    style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 14),
          Text('Gender', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final g in const ['female', 'male', 'other'])
                ChoiceChip(
                  label: Text(g[0].toUpperCase() + g.substring(1)),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                  selectedColor: AppColors.orange,
                  labelStyle: GoogleFonts.sora(
                    color: _gender == g ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: _gender == g ? AppColors.orange : AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          CosmicCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_rounded, color: AppColors.orange),
                  title: const Text('Date of birth'),
                  subtitle: Text(_dob == null ? 'Tap to choose' : _dobStr()),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                  onTap: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1920),
                      lastDate: now,
                      initialDate: _dob ?? DateTime(1995, 1, 1),
                    );
                    if (d != null) setState(() => _dob = d);
                  },
                ),
                Divider(height: 1, color: AppColors.line.withValues(alpha: 0.5)),
                ListTile(
                  leading: const Icon(Icons.schedule_rounded, color: AppColors.orange),
                  title: const Text('Birth time'),
                  subtitle: Text(_time == null ? 'Tap to choose' : _timeStr()),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _time ?? const TimeOfDay(hour: 6, minute: 0),
                    );
                    if (t != null) setState(() => _time = t);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _place,
            decoration: const InputDecoration(labelText: 'Birth place', hintText: 'City, region'),
            onChanged: _onPlace,
          ),
          ..._hits.map(
            (p) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p.label, style: const TextStyle(fontSize: 14)),
              onTap: () {
                setState(() {
                  _picked = p;
                  _place.text = p.label;
                  _hits = [];
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : _save,
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.editing ? 'Update Kundli' : 'Generate My Kundli'),
            ),
          ),
        ],
      ),
    );
  }
}
