import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import 'referral.dart';
import 'subscription.dart';

/// Wallet: chat €1/min recharges + Monthly Pro €11 for Kundli & Palm.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<LedgerItem> _items = [];
  List<Map<String, dynamic>> _packs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      final tx = await app.api.transactions();
      final packsJson = await app.api.walletPacks();
      final list = ((tx['transactions'] as List?) ?? [])
          .map((e) => LedgerItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final packs = ((packsJson['packs'] as List?) ?? []).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _items = list;
        _packs = packs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is ApiException ? e.message : 'Could not load wallet';
      });
    }
  }

  Future<void> _buyPack(num amount) async {
    final app = context.read<AppState>();
    final ok = await app.rechargeWallet(amount.toInt());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Wallet credited €$amount' : (app.error ?? 'Recharge failed')),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user;
    final subscribed = user?.isSubscribed == true;
    final expires = user?.subscriptionExpiresAt;
    final balance = user?.walletBalance ?? 0;
    final rate = app.ratePerMinute;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await app.refreshMe();
          await _load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text('Wallet', style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
            const SizedBox(height: 6),
            Text(
              subscribed
                  ? 'Pro active — Kundli & palm included. Chat €${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}/min optional.'
                  : 'Chat €${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}/min · Pro €11 unlocks Kundli & palm',
              style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            CosmicCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '€${balance.toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2)}',
                          style: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.account_balance_wallet_rounded, color: AppColors.orange.withValues(alpha: 0.9), size: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CosmicCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              gradient: AppGradients.promo,
              borderColor: AppColors.orange.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text('Monthly Pro', style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscribed
                        ? (expires != null
                            ? 'Active until ${DateFormat('d MMM y').format(expires.toLocal())}'
                            : 'Active')
                        : '€11 / month',
                    style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Full Kundli (Bhagya, Yog, report) · Palm reading',
                    style: GoogleFonts.sora(fontSize: 12, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.void_),
                      child: Text(subscribed ? 'Manage plan' : 'Subscribe · €11'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Recharge for chat', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
            const SizedBox(height: 6),
            Text('€1 / minute while chatting', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Text(_error!, style: GoogleFonts.sora(color: AppColors.danger))
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final p in _packs)
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width - 50) / 2,
                      child: CosmicCard(
                        onTap: app.busy ? null : () => _buyPack((p['amount'] as num?) ?? 0),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['label']?.toString() ?? '€${p['amount']}',
                              style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.orange),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p['hint']?.toString() ?? '',
                              style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            CosmicCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen())),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: AppColors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Refer & Earn · 50% of €11 (€5.50)', style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Activity', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
            const SizedBox(height: 10),
            if (_items.isEmpty && !_loading)
              Text('No transactions yet', style: GoogleFonts.sora(color: AppColors.muted))
            else
              for (final t in _items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CosmicCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.memo.isNotEmpty ? t.memo : t.type, style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(DateFormat('d MMM · HH:mm').format(t.at.toLocal()), style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        Text(
                          '${t.amount >= 0 ? '+' : ''}€${t.amount.abs().toStringAsFixed(2)}',
                          style: GoogleFonts.sora(
                            fontWeight: FontWeight.w700,
                            color: t.amount >= 0 ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
