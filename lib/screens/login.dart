import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/cosmic_ui.dart';
import '../widgets/sky.dart';
import 'legal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  Future<void> _pickLanguage() async {
    final app = context.read<AppState>();
    final l = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final current = app.locale.languageCode;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
            children: [
              ListTile(title: Text(l.chooseLanguage, style: GoogleFonts.sora(fontWeight: FontWeight.w700))),
              for (final lang in appLanguages)
                ListTile(
                  title: Text(lang.nativeName),
                  subtitle: Text(lang.englishName),
                  trailing: current == lang.code
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.orange)
                      : null,
                  onTap: () => Navigator.pop(ctx, lang.code),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) await app.setLanguage(selected);
  }

  Future<void> _submit() async {
    final id = _id.text.trim();
    if (id.isEmpty) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Privacy Policy, Terms, and Community Guidelines'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final app = context.read<AppState>();
    final otp = await app.requestOtp(id);
    if (!mounted) return;
    if (app.error != null && otp == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(app.error!)));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtpScreen(identifier: id, echoedOtp: otp)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AppState>().busy;
    final l = AppLocalizations.of(context);
    final langCode = context.watch<AppState>().locale.languageCode;
    final lang = appLanguages.firstWhere((e) => e.code == langCode, orElse: () => appLanguages.first);
    final linkStyle = GoogleFonts.sora(
      color: AppColors.orange,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.orange,
    );

    return Scaffold(
      body: CosmicBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ObservatorySky(
              height: MediaQuery.sizeOf(context).height * 0.38,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _pickLanguage,
                          icon: const Icon(Icons.translate_rounded, size: 18, color: AppColors.orange),
                          label: Text(
                            lang.nativeName,
                            style: GoogleFonts.sora(color: AppColors.orange, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.gold,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange.withValues(alpha: 0.4),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/logo.jpeg', height: 80, width: 80, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(l.appTitle, style: brandStyle(size: 34)),
                      const SizedBox(height: 6),
                      Text(
                        'India\'s AI Jyotishi',
                        style: GoogleFonts.sora(
                          color: AppColors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    Text(
                      l.loginTitle,
                      style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.loginSubtitle,
                      style: GoogleFonts.sora(color: AppColors.muted, height: 1.4, fontSize: 14),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _id,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        hintText: '9876543210 or you@email.com',
                        prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                            activeColor: AppColors.orange,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted, height: 1.45),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: linkStyle,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                                        ),
                                ),
                                const TextSpan(text: ', '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: linkStyle,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                                        ),
                                ),
                                const TextSpan(text: ', and '),
                                TextSpan(
                                  text: 'Community Guidelines',
                                  style: linkStyle,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const CommunityGuidelinesScreen()),
                                        ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: busy ? null : _submit,
                        child: busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(l.sendOtp),
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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.identifier, this.echoedOtp});
  final String identifier;
  final String? echoedOtp;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();
  final _referral = TextEditingController();
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    if (widget.echoedOtp != null && widget.echoedOtp!.isNotEmpty) {
      _otp.text = widget.echoedOtp!;
    }
  }

  @override
  void dispose() {
    _otp.dispose();
    _referral.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_verifying) return;
    final code = _otp.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _verifying = true);
    final app = context.read<AppState>();
    final ok = await app.verifyOtp(
      widget.identifier,
      code,
      referralCode: _referral.text.trim(),
    );
    if (!mounted) return;
    setState(() => _verifying = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.error ?? 'Could not verify OTP'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    // Clear OTP route so Gate can show home / profile setup
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AppState>().busy || _verifying;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).verifyOtp)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code sent to', style: GoogleFonts.sora(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(widget.identifier, style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 16)),
                if (widget.echoedOtp != null && widget.echoedOtp!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Your OTP: ${widget.echoedOtp}',
                      style: GoogleFonts.sora(color: AppColors.orange, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '• • • • • •', counterText: ''),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referral,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Referral code (optional)',
              hintText: 'Friend’s code',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : _verify,
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppLocalizations.of(context).continueBtn),
            ),
          ),
        ],
      ),
    );
  }
}
