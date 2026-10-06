import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _code = TextEditingController();
  String _myCode = '';
  int _count = 0;
  double _bonus = 5.5;
  int _price = 11;
  bool _loading = true;
  String? _applyMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final json = await context.read<AppState>().api.referralInfo();
      if (!mounted) return;
      setState(() {
        _myCode = json['referralCode'] as String? ?? '';
        _count = (json['referredCount'] as num?)?.toInt() ?? 0;
        _bonus = (json['bonusAmount'] as num?)?.toDouble() ?? 299.5;
        _price = (json['subscriptionPrice'] as num?)?.toInt() ?? 599;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copy() async {
    if (_myCode.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _myCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _apply() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    final app = context.read<AppState>();
    try {
      final json = await app.api.applyReferral(code);
      await app.refreshMe();
      if (!mounted) return;
      setState(() {
        _applyMsg = 'Code applied — ${json['referrerName'] ?? 'friend'}';
      });
      _code.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _applyMsg = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final already = user?.referredBy == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                CosmicCard(
                  gradient: AppGradients.promo,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Earn 50% when they subscribe',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        'Friend takes Monthly Pro (€$_price) → you get €${_bonus.toStringAsFixed(2)} in wallet.',
                        style: GoogleFonts.sora(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CosmicCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your code', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _myCode.isEmpty ? '—' : _myCode,
                              style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.goldSoft),
                            ),
                          ),
                          IconButton(onPressed: _copy, icon: const Icon(Icons.copy_rounded, color: AppColors.orange)),
                        ],
                      ),
                      Text('Friends referred: $_count', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!already) ...[
                  Text('Have a code?', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'Enter friend’s code'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _apply, child: const Text('Apply code')),
                  ),
                ] else
                  CosmicCard(
                    child: Text('Referral already applied on this account.',
                        style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13)),
                  ),
                if (_applyMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(_applyMsg!, style: GoogleFonts.sora(fontSize: 13, color: AppColors.orange)),
                ],
              ],
            ),
    );
  }
}
