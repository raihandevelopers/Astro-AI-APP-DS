import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _elapsed = ValueNotifier<Duration>(Duration.zero);
  final Map<int, Uint8List> _imageBytes = {};
  Timer? _tick;
  Timer? _beat;
  bool _endedToast = false;
  bool _closing = false;
  late AppState _app;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _app = context.read<AppState>();
  }

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final c = context.read<AppState>().active;
      if (c == null) return;
      _elapsed.value = DateTime.now().difference(c.startedAt.toLocal());
    });
    _beat = Timer.periodic(const Duration(seconds: 15), (_) {
      final c = context.read<AppState>().active;
      if (c == null || !c.isActive) return;
      context.read<AppState>().heartbeat();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<AppState>().active;
      if (c != null && c.isActive) context.read<AppState>().heartbeat();
      _scrollDown();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _beat?.cancel();
    _elapsed.dispose();
    _input.dispose();
    _scroll.dispose();
    final c = _app.active;
    if (!_closing && c != null && c.isActive && c.id == widget.consultationId) {
      _app.endConsultation(silent: true);
    }
    super.dispose();
  }

  Future<void> _leaveAndEnd() async {
    if (_closing) return;
    _closing = true;
    _tick?.cancel();
    _beat?.cancel();
    final c = _app.active;
    if (c != null && c.isActive && c.id == widget.consultationId) {
      await _app.endConsultation(silent: true);
    }
  }

  String _clock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final ok = await context.read<AppState>().sendMessage(text);
    if (!mounted) return;
    if (!ok) {
      final err = context.read<AppState>().error;
      if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
    _scrollDown();
  }

  void _scrollDown() {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      }
    });
  }

  Uint8List? _bytesForMessage(int index, ChatMessage m) {
    final raw = m.image;
    if (raw == null || raw.isEmpty) return _imageBytes[index];
    return _imageBytes.putIfAbsent(index, () => _decodeChatImage(raw));
  }

  Future<void> _end() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End consultation?'),
        content: const Text('Timer stops and a summary is saved from this chat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('End')),
        ],
      ),
    );
    if (go == true && mounted) {
      await _leaveAndEnd();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.active;
    if (c == null) {
      return PopScope(
        canPop: true,
        child: Scaffold(appBar: AppBar(), body: const Center(child: Text('Consultation closed'))),
      );
    }
    final cat = localizedCategoryById(AppLocalizations.of(context), c.category);
    final ended = !c.isActive;

    if (ended && !_endedToast) {
      _endedToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              c.endReason == 'subscription_required' || c.endReason == 'insufficient_balance'
                  ? 'Session ended'
                  : 'Consultation ended',
            ),
          ),
        );
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        await _leaveAndEnd();
        if (!mounted) return;
        nav.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.night,
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final nav = Navigator.of(context);
              await _leaveAndEnd();
              if (!mounted) return;
              nav.pop();
            },
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.gold,
                  border: Border.all(color: AppColors.goldSoft.withValues(alpha: 0.5)),
                ),
                child: ClipOval(child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'AI Jyotishi · ${cat.title}',
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: ValueListenableBuilder<Duration>(
                              valueListenable: _elapsed,
                              builder: (_, d, _) => Text(
                                '${_clock(d)}  ·  Live',
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: ended ? () => Navigator.pop(context) : _end,
                child: Text(ended ? 'Close' : 'End', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (c.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.success.withValues(alpha: 0.12),
                child: Text(
                  c.isFreeProChat
                      ? 'Pro palm chat · unlimited · no wallet charge'
                      : '€${c.ratePerMinute.toStringAsFixed(0)}/min · wallet billing',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: c.isFreeProChat ? AppColors.orange : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: c.messages.length + (app.busy ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == c.messages.length) {
                    return _typingBubble();
                  }
                  final m = c.messages[i];
                  return _MessageBubble(
                    message: m,
                    imageBytes: _bytesForMessage(i, m),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.line.withValues(alpha: 0.6))),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          enabled: c.isActive && !app.busy,
                          minLines: 1,
                          maxLines: 4,
                          style: GoogleFonts.sora(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).typeMessage,
                            filled: true,
                            fillColor: AppColors.surfaceLift,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: c.isActive && !app.busy ? _send : null,
                          borderRadius: BorderRadius.circular(24),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _avatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.chatAi,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                _dot(1),
                _dot(2),
                const SizedBox(width: 6),
                Text('Reading chart…', style: GoogleFonts.sora(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int i) => Container(
        width: 6,
        height: 6,
        margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.5 + i * 0.15),
          shape: BoxShape.circle,
        ),
      );

  Widget _avatar({double size = 32}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.gold,
      ),
      child: ClipOval(child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover)),
    );
  }
}

Uint8List _decodeChatImage(String raw) {
  var s = raw.trim();
  final comma = s.indexOf(',');
  if (s.startsWith('data:') && comma > 0) {
    s = s.substring(comma + 1);
  }
  return base64Decode(s);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.imageBytes});
  final ChatMessage message;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.gold),
              child: ClipOval(child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: mine ? AppColors.chatUser : AppColors.chatAi,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
                border: Border.all(
                  color: mine
                      ? AppColors.success.withValues(alpha: 0.25)
                      : AppColors.gold.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageBytes != null && imageBytes!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        imageBytes!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => Container(
                          width: 200,
                          height: 120,
                          alignment: Alignment.center,
                          color: AppColors.ink.withValues(alpha: 0.08),
                          child: Text(
                            'Palm photo',
                            style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.content,
                    style: GoogleFonts.sora(
                      height: 1.45,
                      fontSize: 14.5,
                      color: mine ? AppColors.ink : AppColors.goldSoft.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
