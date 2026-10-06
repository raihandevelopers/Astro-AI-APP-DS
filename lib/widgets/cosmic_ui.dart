import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../astro_names.dart';
import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../models.dart';
import '../theme.dart';

class CosmicBackground extends StatelessWidget {
  const CosmicBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.void_, AppColors.night, Color(0xFF120A1E)],
        ),
      ),
      child: child,
    );
  }
}

class ProChip extends StatelessWidget {
  const ProChip({super.key, required this.subscribed, this.onTap});
  final bool subscribed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subscribed ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                  size: 18,
                  color: AppColors.void_,
                ),
                const SizedBox(width: 6),
                Text(
                  subscribed ? 'Pro' : 'Get Pro',
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.void_,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.goldSoft,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class CosmicCard extends StatelessWidget {
  const CosmicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceLift, AppColors.surface],
            ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.line.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: card),
    );
  }
}

class AiAstrologerCard extends StatelessWidget {
  const AiAstrologerCard({
    super.key,
    required this.onChat,
    this.subscribed = false,
  });

  final VoidCallback onChat;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CosmicCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D1F0A), Color(0xFF1C1830), Color(0xFF14121F)],
        ),
        borderColor: AppColors.orange.withValues(alpha: 0.45),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.gold,
                border: Border.all(color: AppColors.goldSoft, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/logo.jpeg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Jyotishi',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldSoft,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: GoogleFonts.sora(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.orange),
                      Text(
                        ' 4.9  ·  Vedic  ·  Instant',
                        style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscribed ? 'Pro on · Palm included · Chat €1/min optional' : 'Chat €1/min · Palm needs Pro',
                    style: GoogleFonts.sora(fontSize: 12, color: AppColors.ink.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onChat,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartSummaryStrip extends StatelessWidget {
  const ChartSummaryStrip({
    super.key,
    required this.lagna,
    required this.moon,
    required this.nakshatra,
  });

  final String lagna;
  final String moon;
  final String nakshatra;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CosmicCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderColor: AppColors.gold.withValues(alpha: 0.25),
        child: Row(
          children: [
            _pill(l.labelLagna, localizedSign(context, lagna)),
            _divider(),
            _pill(l.labelMoon, localizedSign(context, moon)),
            _divider(),
            _pill(l.labelNakshatra, localizedNakshatra(context, nakshatra), expand: true),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.line,
      );

  Widget _pill(String label, String value, {bool expand = false}) {
    return Expanded(
      flex: expand ? 2 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: kundliPlanetStyle(size: 10, color: AppColors.muted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: kundliSignStyle(size: 13, color: AppColors.goldSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderColor: colors.first.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(14),
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: AppColors.goldSoft, size: 22),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          softWrap: true,
                          style: GoogleFonts.sora(fontSize: 11, color: AppColors.muted.withValues(alpha: 0.95), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: CosmicCard(
        onTap: onTap,
        gradient: AppGradients.promo,
        borderColor: AppColors.orange.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.firstConsultation,
                    style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.promoSubtitle,
                    style: GoogleFonts.sora(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    super.key,
    required this.name,
    required this.subscribed,
    required this.onPro,
    required this.onNotices,
  });

  final String name;
  final bool subscribed;
  final VoidCallback onPro;
  final VoidCallback onNotices;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.gold,
              boxShadow: [
                BoxShadow(color: AppColors.orange.withValues(alpha: 0.35), blurRadius: 16),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.jpeg', width: 48, height: 48, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l.namasteName(name),
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                Text(
                  l.cosmicGuideAwaits,
                  style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotices,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLift.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.goldSoft, size: 22),
          ),
          const SizedBox(width: 6),
          ProChip(subscribed: subscribed, onTap: onPro),
        ],
      ),
    );
  }
}

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({
    super.key,
    required this.onChat,
    required this.onKundli,
    required this.onPalm,
    required this.onWallet,
    required this.onLanguage,
  });

  final VoidCallback onChat;
  final VoidCallback onKundli;
  final VoidCallback onPalm;
  final VoidCallback onWallet;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = [
      _QuickAction(l.chatNow, Icons.chat_rounded, AppColors.orange, onChat),
      _QuickAction(l.myKundli, Icons.auto_awesome_rounded, AppColors.gold, onKundli),
      _QuickAction(l.palmShort, Icons.back_hand_rounded, AppColors.purple, onPalm),
      _QuickAction(l.navWallet, Icons.account_balance_wallet_rounded, AppColors.neon, onWallet),
      _QuickAction(l.language, Icons.translate_rounded, AppColors.neonDeep, onLanguage),
    ];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = actions[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: a.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceLift,
                      AppColors.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.color.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, color: a.color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.label,
                      style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction {
  _QuickAction(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class HomeStatsBar extends StatelessWidget {
  const HomeStatsBar({
    super.key,
    this.subscribed = false,
  });

  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _stat(
              Icons.chat_rounded,
              '€1',
              '/min chat',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _stat(
              Icons.back_hand_rounded,
              subscribed ? 'On' : '€11',
              l.palmReading,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _stat(
              Icons.workspace_premium_rounded,
              subscribed ? 'Active' : '€11',
              subscribed ? 'Monthly Pro' : '/month',
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return CosmicCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      borderColor: AppColors.orange.withValues(alpha: 0.2),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.orange),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.goldSoft)),
          Text(label, style: GoogleFonts.sora(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class PanditInfo {
  const PanditInfo(this.image, this.rating, this.years);
  final String image;
  final double rating;
  final int years;
}

const kPandits = [
  PanditInfo('assets/pandit1.png', 4.9, 25),
  PanditInfo('assets/pandit2.png', 4.8, 12),
  PanditInfo('assets/pandit3.png', 4.9, 35),
  PanditInfo('assets/pandit4.png', 4.7, 20),
  PanditInfo('assets/pandit5.png', 4.8, 18),
];

(String name, String specialty) _panditCopy(AppLocalizations l, int i) {
  switch (i) {
    case 0:
      return (l.pandit1Name, l.pandit1Specialty);
    case 1:
      return (l.pandit2Name, l.pandit2Specialty);
    case 2:
      return (l.pandit3Name, l.pandit3Specialty);
    case 3:
      return (l.pandit4Name, l.pandit4Specialty);
    default:
      return (l.pandit5Name, l.pandit5Specialty);
  }
}

class PanditListSection extends StatelessWidget {
  const PanditListSection({
    super.key,
    required this.onChat,
    this.subscribed = false,
  });

  final VoidCallback onChat;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kPandits.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _PanditCard(
          index: i,
          pandit: kPandits[i],
          subscribed: subscribed,
          onChat: onChat,
        ),
      ),
    );
  }
}

class _PanditCard extends StatelessWidget {
  const _PanditCard({
    required this.index,
    required this.pandit,
    required this.onChat,
    this.subscribed = false,
  });

  final int index;
  final PanditInfo pandit;
  final VoidCallback onChat;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final copy = _panditCopy(l, index);
    final name = copy.$1;
    final specialty = copy.$2;
    return SizedBox(
      width: 160,
      child: CosmicCard(
        onTap: onChat,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1540), Color(0xFF14121F)],
        ),
        borderColor: AppColors.orange.withValues(alpha: 0.35),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldSoft, width: 2),
                boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.3), blurRadius: 12)],
              ),
              child: ClipOval(
                child: Image.asset(pandit.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                maxLines: 1,
                softWrap: false,
                style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              specialty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sora(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.orange),
                const SizedBox(width: 2),
                Text('${pandit.rating}', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l.yearsExp(pandit.years), style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
                ),
              ],
            ),
            const Spacer(),
            Text(
              subscribed ? 'Pro' : '€1/min',
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: subscribed ? AppColors.success : AppColors.orange,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: FilledButton(
                onPressed: onChat,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  textStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                child: Text(l.chatNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularCategoryScroll extends StatelessWidget {
  const PopularCategoryScroll({super.key, required this.onTap});
  final void Function(CategoryInfo) onTap;

  @override
  Widget build(BuildContext context) {
    final popular = localizedCategories(AppLocalizations.of(context)).take(5).toList();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: popular.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = popular[i];
          return ActionChip(
            onPressed: () => onTap(c),
            avatar: Icon(c.icon, size: 16, color: AppColors.orange),
            label: Text(c.title),
            labelStyle: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
            backgroundColor: AppColors.surfaceLift,
            side: BorderSide(color: AppColors.orange.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.person_add_alt_1_rounded, l.stepBirthTitle, l.stepBirthBody),
      (Icons.chat_bubble_rounded, l.stepChatTitle, l.stepChatBody),
      (Icons.auto_awesome_rounded, l.stepInsightTitle, l.stepInsightBody),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: CosmicCard(
        padding: const EdgeInsets.all(18),
        borderColor: AppColors.gold.withValues(alpha: 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.howItWorks,
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${i + 1}', style: GoogleFonts.sora(fontWeight: FontWeight.w800, color: AppColors.void_, fontSize: 14)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].$2, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(steps[i].$3, style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted, height: 1.35)),
                      ],
                    ),
                  ),
                  Icon(steps[i].$1, color: AppColors.orange.withValues(alpha: 0.7), size: 20),
                ],
              ),
              if (i < steps.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _trust(Icons.verified_user_rounded, 'Private'),
          _trust(Icons.psychology_rounded, 'Vedic'),
          _trust(Icons.bolt_rounded, 'Instant'),
        ],
      ),
    );
  }

  Widget _trust(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.orange),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
      ],
    );
  }
}
