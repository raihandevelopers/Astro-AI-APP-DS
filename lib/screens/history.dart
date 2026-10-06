import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import '../widgets/ux.dart';
import 'chat.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Consultation> _items = [];
  bool _loading = true;
  String? _error;
  late AppState _app;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _app = context.read<AppState>();
    _app.removeListener(_onAppChanged);
    _app.addListener(_onAppChanged);
  }

  void _onAppChanged() {
    if (!mounted) return;
    if (_app.active == null && !_loading) {
      _load();
    }
  }

  @override
  void dispose() {
    _app.removeListener(_onAppChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await context.read<AppState>().api.listConsultations();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is ApiException ? e.message : 'Could not load chats';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text('My Chats', style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.goldSoft)),
            const SizedBox(height: 6),
            Text('All consultations with AI Jyotishi', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 20),
            if (_loading)
              const LoadingBlock(label: 'Loading your chats…')
            else if (_error != null)
              ErrorState(message: _error!, onRetry: _load)
            else if (_items.isEmpty)
              EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No chats yet',
                subtitle: 'Start a consultation from Home to talk with AI Jyotishi about your chart.',
                actionLabel: 'Go to Home',
                onAction: () => context.read<AppState>().goTab(0),
              )
            else
              ..._items.map((c) {
                final cat = localizedCategoryById(AppLocalizations.of(context), c.category);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CosmicCard(
                    onTap: () async {
                      if (c.isActive) {
                        context.read<AppState>().adopt(c);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(consultationId: c.id)),
                        );
                        _load();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HistoryDetailScreen(consultation: c)),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: cat.colors),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(cat.icon, color: AppColors.goldSoft, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(cat.title, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15)),
                                  if (c.isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'LIVE',
                                        style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('d MMM y, h:mm a').format(c.startedAt.toLocal()),
                                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                              ),
                              Text(
                                c.isActive
                                    ? 'Live · Pro'
                                    : '${c.minutesCharged} min · Pro',
                                style: GoogleFonts.sora(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
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

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.consultation});
  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final cat = localizedCategoryById(AppLocalizations.of(context), consultation.category);
    return Scaffold(
      appBar: AppBar(title: Text(cat.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          CosmicCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Duration', '${consultation.minutesCharged} min'),
                _stat('Plan', 'Standard / Wallet'),
              ],
            ),
          ),
          if (consultation.summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionTitle(title: 'Summary'),
            CosmicCard(
              child: Text(consultation.summary, style: GoogleFonts.sora(height: 1.5, fontSize: 14)),
            ),
          ],
          const SizedBox(height: 16),
          SectionTitle(title: 'Transcript'),
          if (consultation.messages.isEmpty)
            const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No messages saved',
              subtitle: 'This session ended before a chat transcript was stored.',
            )
          else
            ...consultation.messages.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CosmicCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.role == 'user' ? 'You' : 'AI Jyotishi',
                        style: GoogleFonts.sora(
                          color: m.role == 'user' ? AppColors.success : AppColors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(m.content, style: GoogleFonts.sora(height: 1.45, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold)),
      ],
    );
  }
}
