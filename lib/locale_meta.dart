import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'models.dart';

const supportedAppLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('de'),
  Locale('es'),
  Locale('fr'),
  Locale('el'),
  Locale('nl'),
];

class AppLanguageOption {
  const AppLanguageOption(this.code, this.englishName, this.nativeName);
  final String code;
  final String englishName;
  final String nativeName;
}

const appLanguages = [
  AppLanguageOption('en', 'English', 'English'),
  AppLanguageOption('hi', 'Hindi', 'हिन्दी'),
  AppLanguageOption('de', 'German', 'Deutsch'),
  AppLanguageOption('es', 'Spanish', 'Español'),
  AppLanguageOption('fr', 'French', 'Français'),
  AppLanguageOption('el', 'Greek', 'Ελληνικά'),
  AppLanguageOption('nl', 'Dutch', 'Nederlands'),
];

String normalizeLanguageCode(String? code) {
  final c = (code ?? 'en').toLowerCase().split('-').first;
  return appLanguages.any((l) => l.code == c) ? c : 'en';
}

List<CategoryInfo> localizedCategories(AppLocalizations l) => [
      CategoryInfo('love', l.catLove, l.catLoveLine, Icons.favorite_rounded, const [Color(0xFF4A1535), Color(0xFF2A1020)]),
      CategoryInfo('marriage', l.catMarriage, l.catMarriageLine, Icons.volunteer_activism_rounded, const [Color(0xFF3D1A4A), Color(0xFF221028)]),
      CategoryInfo('career', l.catCareer, l.catCareerLine, Icons.work_rounded, const [Color(0xFF1A2F4A), Color(0xFF101A28)]),
      CategoryInfo('business', l.catBusiness, l.catBusinessLine, Icons.storefront_rounded, const [Color(0xFF3D2A10), Color(0xFF221A08)]),
      CategoryInfo('finance', l.catFinance, l.catFinanceLine, Icons.savings_rounded, const [Color(0xFF1A3D2A), Color(0xFF0F2218)]),
      CategoryInfo('family', l.catFamily, l.catFamilyLine, Icons.home_rounded, const [Color(0xFF2A2040), Color(0xFF181028)]),
      CategoryInfo('general', l.catGeneral, l.catGeneralLine, Icons.auto_awesome_rounded, const [Color(0xFF2A1540), Color(0xFF150A20)]),
    ];

CategoryInfo localizedCategoryById(AppLocalizations l, String id) {
  final list = localizedCategories(l);
  return list.firstWhere((c) => c.id == id, orElse: () => list.last);
}
