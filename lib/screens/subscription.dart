import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionPlan? _plan;
  int? _priceInr;
  int _eurInrRate = 100;
  String? _billingNote;
  bool _loading = true;
  bool _razorpayEnabled = true;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final json = await context.read<AppState>().api.subscriptionPlans();
      final plans = ((json['plans'] as List?) ?? [])
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList();
      final first = plans.isNotEmpty ? (json['plans'] as List).first as Map<String, dynamic> : null;
      if (mounted) {
        setState(() {
          _plan = plans.isNotEmpty ? plans.first : null;
          _priceInr = (first?['priceInr'] as num?)?.toInt();
          _eurInrRate = (first?['eurInrRate'] as num?)?.toInt() ?? (json['eurInrRate'] as num?)?.toInt() ?? 100;
          _billingNote = json['billingNote'] as String?;
          _razorpayEnabled = json['razorpayEnabled'] != false;
          _demoMode = json['demo'] == true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _subscribe() async {
    final app = context.read<AppState>();
    final ok = await app.subscribeMonthly();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Monthly Pro activated!' : (app.error ?? 'Could not subscribe')),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user;
    final plan = _plan;
    final active = user?.isSubscribed == true;
    final expires = user?.subscriptionExpiresAt;
    final price = plan?.price ?? 11;
    final inr = _priceInr ?? (price * _eurInrRate);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Pro')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                if (active && expires != null)
                  CosmicCard(
                    gradient: AppGradients.promo,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active until ${DateFormat('d MMM y').format(expires.toLocal())}',
                                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white)),
                              Text('Kundli + Palm unlocked',
                                  style: GoogleFonts.sora(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (active) const SizedBox(height: 16),
                CosmicCard(
                  borderColor: AppColors.orange.withValues(alpha: 0.45),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan?.name ?? 'Monthly Pro', style: brandStyle(size: 24)),
                      const SizedBox(height: 6),
                      Text('€$price/month',
                          style: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.orange)),
                      const SizedBox(height: 4),
                      Text(
                        'Pay via Razorpay · ≈ ₹$inr (UPI / cards)',
                        style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      ...(plan?.perks ?? const [
                        'Full Kundli (Bhagya, Yog & detailed report)',
                        'Palm reading included',
                        'Priority guidance',
                        'Invite friends · earn 50%',
                      ]).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(p, style: GoogleFonts.sora(fontSize: 14))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Other chats stay €1/min from wallet. Palm chat is unlimited with Pro.',
                        style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: app.busy || active ? null : _subscribe,
                          icon: const Icon(Icons.payment_rounded, size: 18),
                          label: Text(active ? 'Already subscribed' : 'Pay €$price (≈ ₹$inr)'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _billingNote ??
                            (_demoMode
                                ? 'Demo mode · no real charge'
                                : _razorpayEnabled
                                    ? 'Razorpay collects INR while the plan is priced in euros.'
                                    : 'Payments not configured on server yet'),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
