import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import '../widgets/ux.dart';
import 'chat.dart';
import 'profile_setup.dart';
import 'subscription.dart';
import 'wallet.dart';

class PalmReadingScreen extends StatefulWidget {
  const PalmReadingScreen({super.key});

  @override
  State<PalmReadingScreen> createState() => _PalmReadingScreenState();
}

class _PalmReadingScreenState extends State<PalmReadingScreen> {
  final _picker = ImagePicker();
  XFile? _photo;
  PalmReadingResult? _result;
  bool _analyzing = false;
  bool _startingChat = false;
  bool _syncingPro = true;

  String? get _readingText => _result?.reading;

  @override
  void initState() {
    super.initState();
    // Sync Pro status so subscribers never see a false paywall
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<AppState>().refreshMe();
      } catch (_) {}
      if (mounted) setState(() => _syncingPro = false);
    });
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1400, imageQuality: 88);
    if (file != null) {
      setState(() {
        _photo = file;
        _result = null;
      });
    }
  }

  Future<void> _analyze() async {
    if (_photo == null) return;
    final app = context.read<AppState>();
    // Re-check Pro before analyze
    try {
      await app.refreshMe();
    } catch (_) {}
    if (!mounted) return;
    if (app.user?.isSubscribed != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monthly Pro unlocks palm reading'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
      return;
    }

    setState(() => _analyzing = true);
    final bytes = await _photo!.readAsBytes();
    final mime = _photo!.mimeType ?? 'image/jpeg';
    final result = await app.analyzePalm(bytes, mimeType: mime);
    if (!mounted) return;
    setState(() {
      _analyzing = false;
      _result = result;
    });
    if (result == null) {
      final err = app.error ?? '';
      final needsPro = err.toLowerCase().contains('monthly pro') || err.toLowerCase().contains('subscribe');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.isEmpty ? 'Could not read palm' : err), behavior: SnackBarBehavior.floating),
      );
      if (needsPro) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
      }
    }
  }

  Future<void> _openChat() async {
    final app = context.read<AppState>();
    final user = app.user;
    if (user == null) return;
    if (!user.profileComplete) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
      return;
    }
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload a palm photo first, then open chat'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Pro palm chat is unlimited — no wallet check
    if (!user.isSubscribed && user.walletBalance < app.ratePerMinute) {
      final go = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Recharge or get Pro',
                style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
              ),
              const SizedBox(height: 10),
              Text(
                'Palm chat is unlimited with Monthly Pro. Or recharge wallet for €${app.ratePerMinute.toStringAsFixed(0)}/min chat.',
                style: GoogleFonts.sora(color: AppColors.muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open Wallet')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx, false);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                },
                child: const Text('Get Monthly Pro'),
              ),
            ],
          ),
        ),
      );
      if (go == true && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
      }
      return;
    }

    setState(() => _startingChat = true);
    final bytes = await _photo!.readAsBytes();
    final mime = _photo!.mimeType ?? 'image/jpeg';
    final c = await app.startConsultation('general', palmChat: true);
    if (!mounted) return;
    if (c == null) {
      setState(() => _startingChat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.error ?? 'Could not start chat'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final ok = await app.sendPalmInChat(bytes, mimeType: mime, reading: _readingText);
    if (!mounted) return;
    setState(() => _startingChat = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.error ?? 'Could not send palm photo to chat'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(consultationId: c.id)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final subscribed = user?.isSubscribed == true;
    final sections = _result?.sections ?? const <PalmSection>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palm Reading'),
        actions: [
          if (subscribed)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pro',
                    style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.orange),
                  ),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: _startingChat ? null : _openChat,
            icon: _startingChat
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Chat'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Palm reading', style: brandStyle(size: 22)),
          const SizedBox(height: 6),
          if (_syncingPro)
            Text('Checking Pro…', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13))
          else
            Text(
              subscribed
                  ? 'Pro: analyze free · Palm chat unlimited (no wallet charge)'
                  : 'Analyze needs Pro (€11) · Palm chat €1/min — or unlimited with Pro',
              style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13, height: 1.4),
            ),
          const SizedBox(height: 20),
          CosmicCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_photo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_photo!.path), height: 220, width: double.infinity, fit: BoxFit.cover),
                  )
                else
                  Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLift,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.back_hand_rounded, size: 48, color: AppColors.orange.withValues(alpha: 0.7)),
                        const SizedBox(height: 8),
                        Text('Clear photo of open palm', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Fingers spread · good light · full palm',
                            style: GoogleFonts.sora(color: AppColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _analyzing ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _analyzing ? null : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !subscribed
                        ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()))
                        : (_photo == null || _analyzing ? null : _analyze),
                    child: Text(
                      !subscribed
                          ? 'Unlock analyze with Pro · €11'
                          : (_analyzing ? 'Detecting lines & mounts…' : 'Analyze palm · free with Pro'),
                    ),
                  ),
                ),
                if (subscribed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Full palm report — no wallet charge',
                    style: GoogleFonts.sora(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: (_startingChat || _photo == null) ? null : _openChat,
                    icon: _startingChat
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.chat_rounded, size: 18),
                    label: Text(
                      _startingChat
                          ? 'Sending palm to chat…'
                          : (_photo == null ? 'Add photo to chat about palm' : 'Chat about your palm'),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subscribed
                      ? 'Unlimited with Pro — ask anything about your palm photo'
                      : 'Sends your palm photo to chat (€1/min, or unlimited with Pro)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted, height: 1.35),
                ),
              ],
            ),
          ),
          if (_analyzing) ...[
            const SizedBox(height: 24),
            const LoadingBlock(label: 'Reading life, heart, head, fate lines & mounts…'),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            SectionTitle(title: 'Full palm report'),
            const SizedBox(height: 4),
            Text(
              '${sections.isEmpty ? 'Detailed' : '${sections.length} sections'} · included with Pro',
              style: GoogleFonts.sora(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            CosmicCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_result!.clarity.isNotEmpty) _chip('Clarity · ${_result!.clarity}'),
                      if (_result!.handType.isNotEmpty) _chip('Hand · ${_result!.handType}'),
                      if (_result!.handSide.isNotEmpty && _result!.handSide != 'unknown')
                        _chip('Side · ${_result!.handSide}'),
                      _chip('Pro · free'),
                    ],
                  ),
                  if (_result!.summary.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _result!.summary,
                      style: GoogleFonts.sora(fontSize: 14, height: 1.55, color: AppColors.ink),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (sections.isEmpty)
              CosmicCard(
                padding: const EdgeInsets.all(18),
                child: Text(_result!.reading, style: GoogleFonts.sora(fontSize: 14, height: 1.6, color: AppColors.ink)),
              )
            else
              for (final s in sections) ...[
                CosmicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
                            ),
                          ),
                          if (s.rating.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.rating,
                                style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.orange),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.body,
                        style: GoogleFonts.sora(
                          fontSize: 13.5,
                          height: 1.65,
                          color: AppColors.ink.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: (_startingChat || _photo == null) ? null : _openChat,
              icon: const Icon(Icons.chat_bubble_rounded),
              label: Text(_startingChat ? 'Sending palm…' : 'Ask more about this palm in chat'),
            ),
          ],
          if (!subscribed && !_syncingPro) ...[
            const SizedBox(height: 20),
            CosmicCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              borderColor: AppColors.orange.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Monthly Pro €11 unlocks full palm analyze + Kundli',
                      style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLift,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(label, style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.goldSoft)),
    );
  }
}
