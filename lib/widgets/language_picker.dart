import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../locale_meta.dart';
import '../state.dart';
import '../theme.dart';

Future<void> pickAppLanguage(BuildContext context) async {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.chooseLanguage, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(l.languageHint, style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            for (final lang in appLanguages)
              ListTile(
                title: Text(lang.nativeName, style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
                subtitle: Text(lang.englishName, style: GoogleFonts.sora(fontSize: 12, color: AppColors.muted)),
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
  if (selected == null || !context.mounted) return;
  await app.setLanguage(selected);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).languageUpdated), behavior: SnackBarBehavior.floating),
  );
}
