import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyFuture'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'App UI and AI replies use this language'**
  String get languageHint;

  /// No description provided for @seeker.
  ///
  /// In en, this message translates to:
  /// **'Seeker'**
  String get seeker;

  /// No description provided for @birthChartKundli.
  ///
  /// In en, this message translates to:
  /// **'Birth chart & kundli'**
  String get birthChartKundli;

  /// No description provided for @editBirthDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit birth details'**
  String get editBirthDetails;

  /// No description provided for @palmReading.
  ///
  /// In en, this message translates to:
  /// **'Palm reading'**
  String get palmReading;

  /// No description provided for @monthlyPro.
  ///
  /// In en, this message translates to:
  /// **'Monthly Pro'**
  String get monthlyPro;

  /// No description provided for @referEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referEarn;

  /// No description provided for @walletRecharge.
  ///
  /// In en, this message translates to:
  /// **'Wallet & recharge'**
  String get walletRecharge;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @notices.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get notices;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @guidanceOnly.
  ///
  /// In en, this message translates to:
  /// **'Guidance only — not medical, legal, or financial advice.'**
  String get guidanceOnly;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @catLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get catLove;

  /// No description provided for @catLoveLine.
  ///
  /// In en, this message translates to:
  /// **'Romance & 5th house'**
  String get catLoveLine;

  /// No description provided for @catMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get catMarriage;

  /// No description provided for @catMarriageLine.
  ///
  /// In en, this message translates to:
  /// **'Partnership & 7th house'**
  String get catMarriageLine;

  /// No description provided for @catCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get catCareer;

  /// No description provided for @catCareerLine.
  ///
  /// In en, this message translates to:
  /// **'Work & 10th house'**
  String get catCareerLine;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catBusinessLine.
  ///
  /// In en, this message translates to:
  /// **'Enterprise & growth'**
  String get catBusinessLine;

  /// No description provided for @catFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get catFinance;

  /// No description provided for @catFinanceLine.
  ///
  /// In en, this message translates to:
  /// **'Wealth & savings'**
  String get catFinanceLine;

  /// No description provided for @catFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get catFamily;

  /// No description provided for @catFamilyLine.
  ///
  /// In en, this message translates to:
  /// **'Home & relationships'**
  String get catFamilyLine;

  /// No description provided for @catGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// No description provided for @catGeneralLine.
  ///
  /// In en, this message translates to:
  /// **'Life path & chart'**
  String get catGeneralLine;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with mobile or email'**
  String get loginSubtitle;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @quickRecharge.
  ///
  /// In en, this message translates to:
  /// **'Quick recharge'**
  String get quickRecharge;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @payWithRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Pay with Razorpay'**
  String get payWithRazorpay;

  /// No description provided for @ourJyotishis.
  ///
  /// In en, this message translates to:
  /// **'Our Jyotishis'**
  String get ourJyotishis;

  /// No description provided for @startConsultation.
  ///
  /// In en, this message translates to:
  /// **'Start consultation'**
  String get startConsultation;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask about your chart…'**
  String get typeMessage;

  /// No description provided for @endChat.
  ///
  /// In en, this message translates to:
  /// **'End chat'**
  String get endChat;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @labelLagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get labelLagna;

  /// No description provided for @labelMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get labelMoon;

  /// No description provided for @labelNakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get labelNakshatra;

  /// No description provided for @labelSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get labelSun;

  /// No description provided for @labelPlanets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get labelPlanets;

  /// No description provided for @labelHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get labelHouse;

  /// No description provided for @namasteName.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String namasteName(String name);

  /// No description provided for @cosmicGuideAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your cosmic guide awaits'**
  String get cosmicGuideAwaits;

  /// No description provided for @chatNow.
  ///
  /// In en, this message translates to:
  /// **'Chat Now'**
  String get chatNow;

  /// No description provided for @myKundli.
  ///
  /// In en, this message translates to:
  /// **'My Kundli'**
  String get myKundli;

  /// No description provided for @palmShort.
  ///
  /// In en, this message translates to:
  /// **'Palm'**
  String get palmShort;

  /// No description provided for @proShort.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proShort;

  /// No description provided for @rechargeShort.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get rechargeShort;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @proChat.
  ///
  /// In en, this message translates to:
  /// **'Pro chat'**
  String get proChat;

  /// No description provided for @talkTime.
  ///
  /// In en, this message translates to:
  /// **'Talk time'**
  String get talkTime;

  /// No description provided for @minsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minsLeft(int count);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @perChat.
  ///
  /// In en, this message translates to:
  /// **'Per chat'**
  String get perChat;

  /// No description provided for @perMinute.
  ///
  /// In en, this message translates to:
  /// **'Per minute'**
  String get perMinute;

  /// No description provided for @unlimitedPro.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Pro'**
  String get unlimitedPro;

  /// No description provided for @perMinRate.
  ///
  /// In en, this message translates to:
  /// **'₹{rate}/min'**
  String perMinRate(String rate);

  /// No description provided for @yearsExp.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String yearsExp(int years);

  /// No description provided for @popularTopics.
  ///
  /// In en, this message translates to:
  /// **'Popular topics'**
  String get popularTopics;

  /// No description provided for @allConsultations.
  ///
  /// In en, this message translates to:
  /// **'All consultations'**
  String get allConsultations;

  /// No description provided for @firstConsultation.
  ///
  /// In en, this message translates to:
  /// **'First consultation'**
  String get firstConsultation;

  /// No description provided for @promoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about love, career, marriage & more'**
  String get promoSubtitle;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @stepBirthTitle.
  ///
  /// In en, this message translates to:
  /// **'Add birth details'**
  String get stepBirthTitle;

  /// No description provided for @stepBirthBody.
  ///
  /// In en, this message translates to:
  /// **'Accurate kundli from your time & place'**
  String get stepBirthBody;

  /// No description provided for @stepChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a chat'**
  String get stepChatTitle;

  /// No description provided for @stepChatBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic — love, career, marriage'**
  String get stepChatBody;

  /// No description provided for @stepInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Get insights'**
  String get stepInsightTitle;

  /// No description provided for @stepInsightBody.
  ///
  /// In en, this message translates to:
  /// **'AI reads your chart in real time'**
  String get stepInsightBody;

  /// No description provided for @unlockKundli.
  ///
  /// In en, this message translates to:
  /// **'Unlock your Kundli'**
  String get unlockKundli;

  /// No description provided for @unlockKundliHint.
  ///
  /// In en, this message translates to:
  /// **'Add birth details for accurate readings'**
  String get unlockKundliHint;

  /// No description provided for @startChatNow.
  ///
  /// In en, this message translates to:
  /// **'Start Chat Now'**
  String get startChatNow;

  /// No description provided for @noKundliYet.
  ///
  /// In en, this message translates to:
  /// **'No kundli yet'**
  String get noKundliYet;

  /// No description provided for @noKundliHint.
  ///
  /// In en, this message translates to:
  /// **'Add your birth details to compute Lagna, Moon, and planetary positions.'**
  String get noKundliHint;

  /// No description provided for @addBirthDetails.
  ///
  /// In en, this message translates to:
  /// **'Add birth details'**
  String get addBirthDetails;

  /// No description provided for @tabTraditional.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get tabTraditional;

  /// No description provided for @tabLagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get tabLagna;

  /// No description provided for @tabNavamsha.
  ///
  /// In en, this message translates to:
  /// **'Navamsha'**
  String get tabNavamsha;

  /// No description provided for @tabChandra.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get tabChandra;

  /// No description provided for @aiJyotishiCat.
  ///
  /// In en, this message translates to:
  /// **'AI Jyotishi · {category}'**
  String aiJyotishiCat(String category);

  /// No description provided for @endConsultation.
  ///
  /// In en, this message translates to:
  /// **'End consultation?'**
  String get endConsultation;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @consultationEnded.
  ///
  /// In en, this message translates to:
  /// **'Consultation ended'**
  String get consultationEnded;

  /// No description provided for @walletEmptyEnded.
  ///
  /// In en, this message translates to:
  /// **'Wallet empty — chat ended'**
  String get walletEmptyEnded;

  /// No description provided for @consultationClosed.
  ///
  /// In en, this message translates to:
  /// **'Consultation closed'**
  String get consultationClosed;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @noChatsHint.
  ///
  /// In en, this message translates to:
  /// **'Start a consultation from Home to talk with AI Jyotishi about your chart.'**
  String get noChatsHint;

  /// No description provided for @loadingChats.
  ///
  /// In en, this message translates to:
  /// **'Loading your chats…'**
  String get loadingChats;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @pandit1Name.
  ///
  /// In en, this message translates to:
  /// **'Pt. Ramesh Shastri'**
  String get pandit1Name;

  /// No description provided for @pandit1Specialty.
  ///
  /// In en, this message translates to:
  /// **'Vedic · Kundli'**
  String get pandit1Specialty;

  /// No description provided for @pandit2Name.
  ///
  /// In en, this message translates to:
  /// **'Acharya Vivek'**
  String get pandit2Name;

  /// No description provided for @pandit2Specialty.
  ///
  /// In en, this message translates to:
  /// **'Numerology · Chart'**
  String get pandit2Specialty;

  /// No description provided for @pandit3Name.
  ///
  /// In en, this message translates to:
  /// **'Swami Devanand'**
  String get pandit3Name;

  /// No description provided for @pandit3Specialty.
  ///
  /// In en, this message translates to:
  /// **'Lal Kitab · Remedies'**
  String get pandit3Specialty;

  /// No description provided for @pandit4Name.
  ///
  /// In en, this message translates to:
  /// **'Pt. Suresh Joshi'**
  String get pandit4Name;

  /// No description provided for @pandit4Specialty.
  ///
  /// In en, this message translates to:
  /// **'Marriage · Muhurat'**
  String get pandit4Specialty;

  /// No description provided for @pandit5Name.
  ///
  /// In en, this message translates to:
  /// **'Acharya Keshav'**
  String get pandit5Name;

  /// No description provided for @pandit5Specialty.
  ///
  /// In en, this message translates to:
  /// **'Career · Dasha'**
  String get pandit5Specialty;

  /// No description provided for @kundliTitle.
  ///
  /// In en, this message translates to:
  /// **'Kundli'**
  String get kundliTitle;

  /// No description provided for @kundliShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get kundliShare;

  /// No description provided for @kundliTabBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get kundliTabBasic;

  /// No description provided for @kundliTabCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get kundliTabCharts;

  /// No description provided for @kundliTabKp.
  ///
  /// In en, this message translates to:
  /// **'KP'**
  String get kundliTabKp;

  /// No description provided for @kundliTabAshtakvarga.
  ///
  /// In en, this message translates to:
  /// **'Ashtakvarga'**
  String get kundliTabAshtakvarga;

  /// No description provided for @kundliTabDasha.
  ///
  /// In en, this message translates to:
  /// **'Dasha'**
  String get kundliTabDasha;

  /// No description provided for @kundliTabReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get kundliTabReport;

  /// No description provided for @kundliBasicDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get kundliBasicDetails;

  /// No description provided for @kundliBirthChart.
  ///
  /// In en, this message translates to:
  /// **'Birth Chart'**
  String get kundliBirthChart;

  /// No description provided for @kundliPlanetaryPositions.
  ///
  /// In en, this message translates to:
  /// **'Planetary Positions'**
  String get kundliPlanetaryPositions;

  /// No description provided for @kundliManglikAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Manglik Analysis'**
  String get kundliManglikAnalysis;

  /// No description provided for @kundliManglikPending.
  ///
  /// In en, this message translates to:
  /// **'Manglik analysis will appear after chart refresh.'**
  String get kundliManglikPending;

  /// No description provided for @kundliFullHint.
  ///
  /// In en, this message translates to:
  /// **'Add your birth details to generate your full kundli.'**
  String get kundliFullHint;

  /// No description provided for @kundliLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get kundliLabelName;

  /// No description provided for @kundliLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get kundliLabelDate;

  /// No description provided for @kundliLabelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get kundliLabelTime;

  /// No description provided for @kundliLabelPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get kundliLabelPlace;

  /// No description provided for @kundliLabelLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get kundliLabelLatitude;

  /// No description provided for @kundliLabelLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get kundliLabelLongitude;

  /// No description provided for @kundliLabelTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get kundliLabelTimezone;

  /// No description provided for @kundliLabelSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get kundliLabelSunrise;

  /// No description provided for @kundliLabelSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get kundliLabelSunset;

  /// No description provided for @kundliLabelAyanamsha.
  ///
  /// In en, this message translates to:
  /// **'Ayanamsha'**
  String get kundliLabelAyanamsha;

  /// No description provided for @kundliLabelMoonSign.
  ///
  /// In en, this message translates to:
  /// **'Moon Sign'**
  String get kundliLabelMoonSign;

  /// No description provided for @kundliLabelSunSign.
  ///
  /// In en, this message translates to:
  /// **'Sun Sign'**
  String get kundliLabelSunSign;

  /// No description provided for @kundliLabelGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get kundliLabelGender;

  /// No description provided for @kundliLabelDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get kundliLabelDob;

  /// No description provided for @kundliLabelBirthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth time'**
  String get kundliLabelBirthTime;

  /// No description provided for @kundliLabelBirthPlace.
  ///
  /// In en, this message translates to:
  /// **'Birth place'**
  String get kundliLabelBirthPlace;

  /// No description provided for @kundliLabelManglik.
  ///
  /// In en, this message translates to:
  /// **'Manglik'**
  String get kundliLabelManglik;

  /// No description provided for @kundliLabelDasha.
  ///
  /// In en, this message translates to:
  /// **'Dasha'**
  String get kundliLabelDasha;

  /// No description provided for @kundliKpSystem.
  ///
  /// In en, this message translates to:
  /// **'KP System'**
  String get kundliKpSystem;

  /// No description provided for @kundliKpUnavailable.
  ///
  /// In en, this message translates to:
  /// **'KP data unavailable — refreshing chart…'**
  String get kundliKpUnavailable;

  /// No description provided for @kundliSignLord.
  ///
  /// In en, this message translates to:
  /// **'Sign lord'**
  String get kundliSignLord;

  /// No description provided for @kundliStarLord.
  ///
  /// In en, this message translates to:
  /// **'Star lord'**
  String get kundliStarLord;

  /// No description provided for @kundliSubLord.
  ///
  /// In en, this message translates to:
  /// **'Sub lord'**
  String get kundliSubLord;

  /// No description provided for @kundliHouseCusps.
  ///
  /// In en, this message translates to:
  /// **'House Cusps (from your lagna)'**
  String get kundliHouseCusps;

  /// No description provided for @kundliPlanetLords.
  ///
  /// In en, this message translates to:
  /// **'Planet Lords'**
  String get kundliPlanetLords;

  /// No description provided for @kundliSavTitle.
  ///
  /// In en, this message translates to:
  /// **'Sarvashtakavarga (SAV)'**
  String get kundliSavTitle;

  /// No description provided for @kundliSavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Computed from your lagna + 7 planets'**
  String get kundliSavSubtitle;

  /// No description provided for @kundliAshtakUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ashtakvarga unavailable — refreshing chart…'**
  String get kundliAshtakUnavailable;

  /// No description provided for @kundliBhinnaTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhinnashtakavarga by sign'**
  String get kundliBhinnaTitle;

  /// No description provided for @kundliVimshottari.
  ///
  /// In en, this message translates to:
  /// **'Vimshottari Dasha'**
  String get kundliVimshottari;

  /// No description provided for @kundliDashaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dasha unavailable — refresh chart.'**
  String get kundliDashaUnavailable;

  /// No description provided for @kundliMoonIn.
  ///
  /// In en, this message translates to:
  /// **'Moon in {nakshatra}'**
  String kundliMoonIn(String nakshatra);

  /// No description provided for @kundliBalanceOf.
  ///
  /// In en, this message translates to:
  /// **'Balance of {lord}: {years} years'**
  String kundliBalanceOf(String lord, String years);

  /// No description provided for @kundliMahadasha.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha'**
  String get kundliMahadasha;

  /// No description provided for @kundliCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get kundliCurrent;

  /// No description provided for @kundliCurrentAntardasha.
  ///
  /// In en, this message translates to:
  /// **'Current Antardasha'**
  String get kundliCurrentAntardasha;

  /// No description provided for @kundliTo.
  ///
  /// In en, this message translates to:
  /// **'to {date}'**
  String kundliTo(String date);

  /// No description provided for @kundliYearsShort.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String kundliYearsShort(String years);

  /// No description provided for @kundliReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Kundli Report'**
  String get kundliReportTitle;

  /// No description provided for @kundliReportBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on your signup birth details'**
  String get kundliReportBasedOn;

  /// No description provided for @kundliBirthProfile.
  ///
  /// In en, this message translates to:
  /// **'Your birth profile'**
  String get kundliBirthProfile;

  /// No description provided for @kundliAiReading.
  ///
  /// In en, this message translates to:
  /// **'AI reading'**
  String get kundliAiReading;

  /// No description provided for @kundliRefreshAi.
  ///
  /// In en, this message translates to:
  /// **'Refresh AI'**
  String get kundliRefreshAi;

  /// No description provided for @kundliGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get kundliGenerating;

  /// No description provided for @kundliAiWriting.
  ///
  /// In en, this message translates to:
  /// **'AI is writing your kundli report from your birth chart…'**
  String get kundliAiWriting;

  /// No description provided for @kundliAiHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Refresh AI to generate a personal reading from your signup details.'**
  String get kundliAiHint;

  /// No description provided for @kundliDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download Kundli PDF'**
  String get kundliDownloadPdf;

  /// No description provided for @kundliPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF failed'**
  String get kundliPdfFailed;

  /// No description provided for @kundliShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed'**
  String get kundliShareFailed;

  /// No description provided for @kundliSectionPersonality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get kundliSectionPersonality;

  /// No description provided for @kundliSectionCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get kundliSectionCareer;

  /// No description provided for @kundliSectionLove.
  ///
  /// In en, this message translates to:
  /// **'Love & relationships'**
  String get kundliSectionLove;

  /// No description provided for @kundliSectionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & home'**
  String get kundliSectionFamily;

  /// No description provided for @kundliSectionStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get kundliSectionStrengths;

  /// No description provided for @kundliSectionChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get kundliSectionChallenges;

  /// No description provided for @kundliSectionRemedies.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get kundliSectionRemedies;

  /// No description provided for @kundliSectionOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall guidance'**
  String get kundliSectionOverall;

  /// No description provided for @kundliHouseN.
  ///
  /// In en, this message translates to:
  /// **'House {n}'**
  String kundliHouseN(String n);

  /// No description provided for @kundliLabelLagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get kundliLabelLagna;

  /// No description provided for @kundliLabelMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get kundliLabelMoon;

  /// No description provided for @kundliLabelSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get kundliLabelSun;

  /// No description provided for @kundliPlanets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get kundliPlanets;

  /// No description provided for @kundliResult.
  ///
  /// In en, this message translates to:
  /// **'Result: {label}'**
  String kundliResult(String label);

  /// No description provided for @kundliPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'MyFuture Kundli'**
  String get kundliPdfTitle;

  /// No description provided for @kundliPdfShareText.
  ///
  /// In en, this message translates to:
  /// **'MyFuture Kundli — {name}'**
  String kundliPdfShareText(String name);

  /// No description provided for @kundliColPlanet.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get kundliColPlanet;

  /// No description provided for @kundliColSign.
  ///
  /// In en, this message translates to:
  /// **'Sign'**
  String get kundliColSign;

  /// No description provided for @kundliColDegree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get kundliColDegree;

  /// No description provided for @kundliColHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get kundliColHouse;

  /// No description provided for @kundliColNakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get kundliColNakshatra;

  /// No description provided for @kundliColStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get kundliColStart;

  /// No description provided for @kundliColEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get kundliColEnd;

  /// No description provided for @kundliColYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get kundliColYears;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your profile, birth chart, chats, wallet history, and palm readings. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'el',
    'en',
    'es',
    'fr',
    'hi',
    'nl',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
