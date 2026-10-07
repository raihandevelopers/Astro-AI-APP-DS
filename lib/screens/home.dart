import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import '../widgets/language_picker.dart';
import '../widgets/sky.dart';
import '../widgets/ux.dart';
import 'chat.dart';
import 'history.dart';
import 'kundli.dart';
import 'legal.dart';
import 'onboarding.dart';
import 'palm_reading.dart';
import 'profile_setup.dart';
import 'referral.dart';
import 'subscription.dart';
import 'wallet.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOnboard());
  }

  Future<void> _maybeOnboard() async {
    if (!await shouldShowOnboarding() || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OnboardingScreen(
          onDone: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<AppState>().shellTab;
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (nav.canPop()) {
          nav.pop();
          return;
        }
        final app = context.read<AppState>();
        if (app.shellTab != 0) {
          app.goTab(0);
        }
        // Already on Home — stay in app (do not exit).
      },
      child: CosmicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: tab,
            children: const [HomeScreen(), HistoryScreen(), WalletScreen(), YouScreen()],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.line.withValues(alpha: 0.6))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              selectedIndex: tab,
              onDestinationSelected: (i) => context.read<AppState>().goTab(i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: l.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: const Icon(Icons.chat_bubble_rounded),
                  label: l.navHistory,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
                  label: l.navWallet,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: l.navYou,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openCategory(BuildContext context, CategoryInfo cat) async {
    final app = context.read<AppState>();
    final user = app.user;
    if (user == null) return;
    if (!user.profileComplete) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
      return;
    }
    if (user.walletBalance < app.ratePerMinute) {
      final goWallet = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Recharge to chat',
                    style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
                const SizedBox(height: 10),
                Text(
                  'Chat is €${app.ratePerMinute.toStringAsFixed(0)}/min from your wallet. Recharge to continue.',
                  style: GoogleFonts.sora(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Open Wallet'),
                ),
              ],
            ),
          );
        },
      );
      if (goWallet == true && context.mounted) {
        // Switch to wallet tab if possible via home; else push wallet
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
      }
      return;
    }

    final go = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: cat.colors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cat.icon, color: AppColors.goldSoft, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.title,
                          style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                        ),
                        Text(cat.line, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CosmicCard(
                padding: const EdgeInsets.all(14),
                child: _infoRow(
                  Icons.account_balance_wallet_rounded,
                  'Chat €${app.ratePerMinute.toStringAsFixed(0)}/min from wallet',
                ),
              ),
              const SizedBox(height: 12),
              Text(app.disclaimer, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Start Chat Now'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (go != true || !context.mounted) return;
    final c = await app.startConsultation(cat.id);
    if (!context.mounted) return;
    if (c == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.error ?? 'Could not start')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(consultationId: c.id)));
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.orange),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.sora(fontSize: 13, color: AppColors.ink)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final cats = localizedCategories(l);
    final user = app.user;
    final name = (user?.name.isNotEmpty == true) ? user!.name.split(' ').first : l.seeker;
    final chart = user?.chart;
    final subscribed = user?.isSubscribed == true;

    void openGeneral() => _openCategory(context, cats.last);
    void openKundli() {
      if (chart != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
      }
    }

    void openPalm() {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PalmReadingScreen()));
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: ObservatorySky(
            height: 210,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HomeHeroHeader(
                      name: name,
                      subscribed: subscribed,
                      onPro: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                      onNotices: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticesScreen())),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'MyFuture',
                        style: brandStyle(size: 30, color: AppColors.goldSoft),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Personal Vedic astrology insights',
                        style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: QuickActionRow(
              onChat: openGeneral,
              onKundli: openKundli,
              onPalm: openPalm,
              onWallet: () => context.read<AppState>().goTab(2),
              onLanguage: () => pickAppLanguage(context),
            ),
          ),
        ),
        if (chart != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: ChartSummaryStrip(
                lagna: chart.risingSign,
                moon: chart.moonSign,
                nakshatra: chart.nakshatra,
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: CosmicCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.orange.withValues(alpha: 0.15),
                    AppColors.surface,
                  ],
                ),
                borderColor: AppColors.orange.withValues(alpha: 0.45),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.orange, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unlock your Kundli', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('Add birth details for accurate readings', style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.orange),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: HomeStatsBar(subscribed: subscribed),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: SectionTitle(title: l.ourJyotishis),
          ),
        ),
        SliverToBoxAdapter(
          child: PanditListSection(
            subscribed: subscribed,
            onChat: openGeneral,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: SectionTitle(title: l.popularTopics),
          ),
        ),
        SliverToBoxAdapter(
          child: PopularCategoryScroll(onTap: (c) => _openCategory(context, c)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: PromoBanner(onTap: () => _openCategory(context, cats.first)),
          ),
        ),
        SliverToBoxAdapter(child: SectionTitle(title: l.allConsultations)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final c = cats[i];
                return CategoryTile(
                  title: c.title,
                  subtitle: c.line,
                  icon: c.icon,
                  colors: c.colors,
                  onTap: () => _openCategory(context, c),
                );
              },
              childCount: cats.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: HowItWorksSection()),
        const SliverToBoxAdapter(child: TrustStrip()),
      ],
    );
  }
}

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final u = app.user;
    final lang = appLanguages.firstWhere(
      (e) => e.code == app.locale.languageCode,
      orElse: () => appLanguages.first,
    );
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          CosmicCard(
            gradient: AppGradients.promo,
            borderColor: AppColors.orange.withValues(alpha: 0.4),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: ClipOval(child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u?.name.isNotEmpty == true ? u!.name : l.seeker,
                        style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u?.phone.isNotEmpty == true ? u!.phone : (u?.email ?? ''),
                        style: GoogleFonts.sora(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (u?.chart != null) ...[
            const SizedBox(height: 16),
            ChartSummaryStrip(
              lagna: u!.chart!.risingSign,
              moon: u.chart!.moonSign,
              nakshatra: u.chart!.nakshatra,
            ),
          ],
          const SizedBox(height: 20),
          SectionTitle(title: l.account),
          _menuCard(context, [
            _MenuItem('${l.language} · ${lang.nativeName}', Icons.translate_rounded, () => pickAppLanguage(context)),
            _MenuItem(l.birthChartKundli, Icons.auto_awesome_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartScreen()));
            }),
            _MenuItem(l.editBirthDetails, Icons.edit_calendar_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen(editing: true)));
            }),
            _MenuItem(l.palmReading, Icons.back_hand_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PalmReadingScreen()));
            }),
            _MenuItem(l.monthlyPro, Icons.workspace_premium_rounded, () {
              context.read<AppState>().goTab(2);
            }),
            _MenuItem(l.referEarn, Icons.card_giftcard_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen()));
            }),
            _MenuItem(l.chatHistory, Icons.history_rounded, () {
              context.read<AppState>().goTab(1);
            }),
            _MenuItem(l.helpSupport, Icons.headset_mic_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
            }),
            _MenuItem(l.notices, Icons.notifications_active_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticesScreen()));
            }),
            _MenuItem(l.privacyPolicy, Icons.privacy_tip_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            }),
            _MenuItem(l.termsOfService, Icons.description_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
            }),
            _MenuItem('Community Guidelines', Icons.groups_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityGuidelinesScreen()));
            }),
          ]),
          const SizedBox(height: 16),
          Text(app.disclaimer, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.45)),
          const SizedBox(height: 8),
          Text(
            l.guidanceOnly,
            style: GoogleFonts.sora(color: AppColors.muted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => app.logout(),
            child: Text(l.signOut),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: app.busy ? null : () => _confirmDeleteAccount(context, app, l),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB91C1C)),
            child: Text(l.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context, AppState app, AppLocalizations l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAccountTitle),
        content: Text(l.deleteAccountBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB91C1C)),
            child: Text(l.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final deleted = await app.deleteAccount();
    if (!context.mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.accountDeleted)));
    } else if (app.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.error!)));
    }
  }

  Widget _menuCard(BuildContext context, List<_MenuItem> items) {
    return CosmicCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: AppColors.orange, size: 22),
              title: Text(items[i].title, style: GoogleFonts.sora(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
              onTap: items[i].onTap,
            ),
            if (i < items.length - 1) Divider(height: 1, color: AppColors.line.withValues(alpha: 0.6)),
          ],
        ],
      ),
    );
  }
}

class _MenuItem {
  _MenuItem(this.title, this.icon, this.onTap);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;
  bool _busy = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject and message')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppState>().api.sendTicket(_subject.text.trim(), _message.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (_sent)
            CosmicCard(
              borderColor: AppColors.success.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ticket received. Our team will review it from the support queue.',
                      style: GoogleFonts.sora(height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            CosmicCard(
              child: Text(
                'Billing, subscription, chart errors, or consultation problems — write to us and we will help.',
                style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13, height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send ticket'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final items = await context.read<AppState>().api.notifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notices')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            if (_loading)
              const LoadingBlock(label: 'Loading notices…')
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (_items.isEmpty)
              const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notices yet',
                subtitle: 'Announcements and account updates will show up here.',
              )
            else
              ..._items.map((n) {
                final at = DateTime.tryParse(n['createdAt'] as String? ?? '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CosmicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['title'] as String? ?? '', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(n['body'] as String? ?? '', style: GoogleFonts.sora(color: AppColors.muted, height: 1.4)),
                        if (at != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${at.day}/${at.month}/${at.year}',
                              style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
