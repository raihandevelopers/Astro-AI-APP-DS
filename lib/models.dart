import 'package:flutter/material.dart';

class PlaceHit {
  PlaceHit({required this.label, required this.latitude, required this.longitude});
  final String label;
  final double latitude;
  final double longitude;

  factory PlaceHit.fromJson(Map<String, dynamic> j) => PlaceHit(
        label: j['label'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );
}

class Planet {
  Planet({
    required this.name,
    required this.sign,
    required this.house,
    required this.degreeInSign,
    required this.nakshatra,
    this.longitude = 0,
    this.nakshatraLord = '',
    this.pada = 0,
    this.signLord = '',
  });
  final String name;
  final String sign;
  final int house;
  final double degreeInSign;
  final String nakshatra;
  final double longitude;
  final String nakshatraLord;
  final int pada;
  final String signLord;

  factory Planet.fromJson(Map<String, dynamic> j) => Planet(
        name: j['name'] as String? ?? '',
        sign: j['sign'] as String? ?? '',
        house: (j['house'] as num?)?.toInt() ?? 0,
        degreeInSign: (j['degreeInSign'] as num?)?.toDouble() ?? 0,
        nakshatra: j['nakshatra'] as String? ?? '',
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
        nakshatraLord: j['nakshatraLord'] as String? ?? '',
        pada: (j['pada'] as num?)?.toInt() ?? 0,
        signLord: j['signLord'] as String? ?? '',
      );
}

class ManglikInfo {
  ManglikInfo({
    required this.isManglik,
    required this.label,
    required this.summary,
    required this.reasons,
    this.marsHouse = 0,
    this.marsSign = '',
  });
  final bool isManglik;
  final String label;
  final String summary;
  final List<String> reasons;
  final int marsHouse;
  final String marsSign;

  factory ManglikInfo.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return ManglikInfo(isManglik: false, label: '—', summary: '', reasons: const []);
    }
    return ManglikInfo(
      isManglik: j['isManglik'] == true,
      label: j['label'] as String? ?? '—',
      summary: j['summary'] as String? ?? '',
      reasons: ((j['reasons'] as List?) ?? []).map((e) => '$e').toList(),
      marsHouse: (j['marsHouse'] as num?)?.toInt() ?? 0,
      marsSign: j['marsSign'] as String? ?? '',
    );
  }
}

class DashaPeriod {
  DashaPeriod({required this.planet, required this.start, required this.end, this.years = 0, this.current = false});
  final String planet;
  final String start;
  final String end;
  final double years;
  final bool current;

  factory DashaPeriod.fromJson(Map<String, dynamic> j) => DashaPeriod(
        planet: j['planet'] as String? ?? '',
        start: j['start'] as String? ?? '',
        end: j['end'] as String? ?? '',
        years: (j['years'] as num?)?.toDouble() ?? 0,
        current: j['current'] == true,
      );
}

class DashaInfo {
  DashaInfo({
    required this.moonNakshatra,
    required this.balanceLord,
    required this.balanceYears,
    required this.mahadashas,
    required this.antardashas,
    this.currentMahadasha = '',
    this.currentAntardashas = const [],
    this.pratyantardashas = const [],
    this.currentDetail = '',
  });
  final String moonNakshatra;
  final String balanceLord;
  final double balanceYears;
  final List<DashaPeriod> mahadashas;
  final List<DashaPeriod> antardashas;
  final String currentMahadasha;
  final List<DashaPeriod> currentAntardashas;
  final List<DashaPeriod> pratyantardashas;
  final String currentDetail;

  factory DashaInfo.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return DashaInfo(moonNakshatra: '', balanceLord: '', balanceYears: 0, mahadashas: const [], antardashas: const []);
    }
    List<DashaPeriod> parseAds(dynamic raw) => ((raw as List?) ?? []).map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          m['planet'] = m['planet'] ?? '${m['mahadasha']}-${m['antardasha']}';
          return DashaPeriod.fromJson(m);
        }).toList();
    return DashaInfo(
      moonNakshatra: j['moonNakshatra'] as String? ?? '',
      balanceLord: j['balanceLord'] as String? ?? '',
      balanceYears: (j['balanceYears'] as num?)?.toDouble() ?? 0,
      mahadashas: ((j['mahadashas'] as List?) ?? []).map((e) => DashaPeriod.fromJson(e as Map<String, dynamic>)).toList(),
      antardashas: parseAds(j['antardashas']),
      currentMahadasha: j['currentMahadasha'] as String? ?? '',
      currentAntardashas: parseAds(j['currentAntardashas']),
      pratyantardashas: parseAds(j['pratyantardashas']),
      currentDetail: j['currentDetail'] as String? ?? '',
    );
  }
}

class Chart {
  Chart({
    required this.sunSign,
    required this.moonSign,
    required this.risingSign,
    required this.nakshatra,
    required this.planets,
    this.risingDegreeInSign = 0,
    this.ayanamsa = 0,
    this.timezone = '',
    this.timezoneOffset = '',
    this.sunrise = '',
    this.sunset = '',
    this.manglik,
    this.dasha,
    this.ashtakvarga,
    this.kp,
    this.yogas,
    this.bhagya,
    this.houses,
    this.grahaPhal,
    this.doshas,
    this.lifeAreas = const [],
    this.nakshatraDetail = '',
    this.vargas,
    this.shadbala,
    this.birthPanchang,
    this.muhurat,
    this.remedies,
    this.report,
    this.aiReport,
  });
  final String sunSign;
  final String moonSign;
  final String risingSign;
  final String nakshatra;
  final List<Planet> planets;
  final double risingDegreeInSign;
  final double ayanamsa;
  final String timezone;
  final String timezoneOffset;
  final String sunrise;
  final String sunset;
  final ManglikInfo? manglik;
  final DashaInfo? dasha;
  final Map<String, dynamic>? ashtakvarga;
  final Map<String, dynamic>? kp;
  final Map<String, dynamic>? yogas;
  final Map<String, dynamic>? bhagya;
  final Map<String, dynamic>? houses;
  final Map<String, dynamic>? grahaPhal;
  final Map<String, dynamic>? doshas;
  final List<Map<String, dynamic>> lifeAreas;
  final String nakshatraDetail;
  final List<Map<String, dynamic>>? vargas;
  final Map<String, dynamic>? shadbala;
  final Map<String, dynamic>? birthPanchang;
  final Map<String, dynamic>? muhurat;
  final Map<String, dynamic>? remedies;
  final Map<String, dynamic>? report;
  final Map<String, dynamic>? aiReport;

  factory Chart.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return Chart(sunSign: '', moonSign: '', risingSign: '', nakshatra: '', planets: []);
    }
    return Chart(
      sunSign: j['sunSign'] as String? ?? '',
      moonSign: j['moonSign'] as String? ?? '',
      risingSign: j['risingSign'] as String? ?? '',
      nakshatra: j['nakshatra'] as String? ?? '',
      risingDegreeInSign: (j['risingDegreeInSign'] as num?)?.toDouble() ?? 0,
      ayanamsa: (j['ayanamsa'] as num?)?.toDouble() ?? 0,
      timezone: j['timezone'] as String? ?? '',
      timezoneOffset: j['timezoneOffset'] as String? ?? '',
      sunrise: j['sunrise'] as String? ?? '',
      sunset: j['sunset'] as String? ?? '',
      planets: ((j['planets'] as List?) ?? []).map((e) => Planet.fromJson(e as Map<String, dynamic>)).toList(),
      manglik: j['manglik'] is Map<String, dynamic> ? ManglikInfo.fromJson(j['manglik'] as Map<String, dynamic>) : null,
      dasha: j['dasha'] is Map<String, dynamic> ? DashaInfo.fromJson(j['dasha'] as Map<String, dynamic>) : null,
      ashtakvarga: j['ashtakvarga'] is Map<String, dynamic> ? j['ashtakvarga'] as Map<String, dynamic> : null,
      kp: j['kp'] is Map<String, dynamic> ? j['kp'] as Map<String, dynamic> : null,
      yogas: j['yogas'] is Map<String, dynamic> ? j['yogas'] as Map<String, dynamic> : null,
      bhagya: j['bhagya'] is Map<String, dynamic> ? j['bhagya'] as Map<String, dynamic> : null,
      houses: j['houses'] is Map<String, dynamic> ? j['houses'] as Map<String, dynamic> : null,
      grahaPhal: j['grahaPhal'] is Map<String, dynamic> ? j['grahaPhal'] as Map<String, dynamic> : null,
      doshas: j['doshas'] is Map<String, dynamic> ? j['doshas'] as Map<String, dynamic> : null,
      lifeAreas: ((j['lifeAreas'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      nakshatraDetail: j['nakshatraDetail'] as String? ?? '',
      vargas: ((j['vargas'] as List?) ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
      shadbala: j['shadbala'] is Map<String, dynamic> ? j['shadbala'] as Map<String, dynamic> : null,
      birthPanchang: j['birthPanchang'] is Map<String, dynamic> ? j['birthPanchang'] as Map<String, dynamic> : null,
      muhurat: j['muhurat'] is Map<String, dynamic> ? j['muhurat'] as Map<String, dynamic> : null,
      remedies: j['remedies'] is Map<String, dynamic> ? j['remedies'] as Map<String, dynamic> : null,
      report: j['report'] is Map<String, dynamic> ? j['report'] as Map<String, dynamic> : null,
      aiReport: j['aiReport'] is Map<String, dynamic> ? j['aiReport'] as Map<String, dynamic> : null,
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dob,
    required this.birthTime,
    required this.birthPlace,
    required this.walletBalance,
    required this.profileComplete,
    this.latitude,
    this.longitude,
    this.chart,
    this.subscriptionPlan = '',
    this.subscriptionExpiresAt,
    this.subscriptionActive = false,
    this.referralCode = '',
    this.referredBy = false,
    this.preferredLanguage = 'en',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final String dob;
  final String birthTime;
  final String birthPlace;
  final double walletBalance;
  final bool profileComplete;
  final double? latitude;
  final double? longitude;
  final Chart? chart;
  final String subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final bool subscriptionActive;
  final String referralCode;
  final bool referredBy;
  final String preferredLanguage;

  bool get isSubscribed => subscriptionActive;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'].toString(),
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        dob: j['dob'] as String? ?? '',
        birthTime: j['birthTime'] as String? ?? '',
        birthPlace: j['birthPlace'] as String? ?? '',
        walletBalance: (j['walletBalance'] as num?)?.toDouble() ?? 0,
        profileComplete: j['profileComplete'] == true,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        chart: j['chart'] != null ? Chart.fromJson(j['chart'] as Map<String, dynamic>) : null,
        subscriptionPlan: j['subscriptionPlan'] as String? ?? '',
        subscriptionExpiresAt: DateTime.tryParse(j['subscriptionExpiresAt'] as String? ?? ''),
        subscriptionActive: j['subscriptionActive'] == true,
        referralCode: j['referralCode'] as String? ?? '',
        referredBy: j['referredBy'] == true,
        preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
      );

  AppUser copyWith({
    double? walletBalance,
    bool? subscriptionActive,
    DateTime? subscriptionExpiresAt,
    String? subscriptionPlan,
    String? referralCode,
    bool? referredBy,
    String? preferredLanguage,
  }) =>
      AppUser(
        id: id,
        name: name,
        phone: phone,
        email: email,
        gender: gender,
        dob: dob,
        birthTime: birthTime,
        birthPlace: birthPlace,
        walletBalance: walletBalance ?? this.walletBalance,
        profileComplete: profileComplete,
        latitude: latitude,
        longitude: longitude,
        chart: chart,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
        subscriptionActive: subscriptionActive ?? this.subscriptionActive,
        referralCode: referralCode ?? this.referralCode,
        referredBy: referredBy ?? this.referredBy,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      );
}

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    required this.at,
    this.image,
    this.mimeType,
    this.kind,
  });
  final String role;
  final String content;
  final DateTime at;
  final String? image;
  final String? mimeType;
  final String? kind;

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        role: j['role'] as String? ?? 'assistant',
        content: j['content'] as String? ?? '',
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        image: (j['image'] as String?)?.isNotEmpty == true ? j['image'] as String : null,
        mimeType: j['mimeType'] as String?,
        kind: j['kind'] as String?,
      );
}

class Consultation {
  Consultation({
    required this.id,
    required this.category,
    required this.status,
    required this.ratePerMinute,
    required this.startedAt,
    required this.minutesCharged,
    required this.amountCharged,
    required this.messages,
    required this.summary,
    this.endedAt,
    this.endReason,
    this.includedWithPro = false,
  });

  final String id;
  final String category;
  final String status;
  final double ratePerMinute;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int minutesCharged;
  final double amountCharged;
  final List<ChatMessage> messages;
  final String summary;
  final String? endReason;
  final bool includedWithPro;

  bool get isActive => status == 'active';
  bool get isFreeProChat => includedWithPro || ratePerMinute <= 0;

  factory Consultation.fromJson(Map<String, dynamic> j) => Consultation(
        id: j['id'].toString(),
        category: j['category'] as String? ?? 'general',
        status: j['status'] as String? ?? 'ended',
        ratePerMinute: (j['ratePerMinute'] as num?)?.toDouble() ?? 10,
        startedAt: DateTime.tryParse(j['startedAt'] as String? ?? '') ?? DateTime.now(),
        endedAt: DateTime.tryParse(j['endedAt'] as String? ?? ''),
        minutesCharged: (j['minutesCharged'] as num?)?.toInt() ?? 0,
        amountCharged: (j['amountCharged'] as num?)?.toDouble() ?? 0,
        messages: ((j['messages'] as List?) ?? [])
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: j['summary'] as String? ?? '',
        endReason: j['endReason'] as String?,
        includedWithPro: j['includedWithPro'] == true,
      );
}

class LedgerItem {
  LedgerItem({
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.memo,
    required this.at,
  });
  final String type;
  final double amount;
  final double balanceAfter;
  final String memo;
  final DateTime at;

  factory LedgerItem.fromJson(Map<String, dynamic> j) => LedgerItem(
        type: j['type'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        balanceAfter: (j['balanceAfter'] as num?)?.toDouble() ?? 0,
        memo: j['memo'] as String? ?? '',
        at: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class SubscriptionPlan {
  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.perks,
  });

  final String id;
  final String name;
  final int price;
  final int durationDays;
  final List<String> perks;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> j) => SubscriptionPlan(
        id: j['id'] as String? ?? 'monthly',
        name: j['name'] as String? ?? 'Monthly Pro',
        price: (j['price'] as num?)?.toInt() ?? 11,
        durationDays: (j['durationDays'] as num?)?.toInt() ?? 30,
        perks: ((j['perks'] as List?) ?? []).map((e) => e.toString()).toList(),
      );
}

class PalmReadingResult {
  PalmReadingResult({
    required this.reading,
    required this.cost,
    this.walletBalance,
    this.summary = '',
    this.clarity = '',
    this.handType = '',
    this.handSide = '',
    this.sections = const [],
  });
  final String reading;
  final int cost;
  final double? walletBalance;
  final String summary;
  final String clarity;
  final String handType;
  final String handSide;
  final List<PalmSection> sections;

  factory PalmReadingResult.fromJson(Map<String, dynamic> j) => PalmReadingResult(
        reading: j['reading'] as String? ?? '',
        cost: (j['cost'] as num?)?.toInt() ?? 0,
        walletBalance: (j['walletBalance'] as num?)?.toDouble(),
        summary: j['summary'] as String? ?? '',
        clarity: j['clarity'] as String? ?? '',
        handType: j['handType'] as String? ?? '',
        handSide: j['handSide'] as String? ?? '',
        sections: ((j['sections'] as List?) ?? [])
            .map((e) => PalmSection.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PalmSection {
  PalmSection({required this.id, required this.title, required this.rating, required this.body});
  final String id;
  final String title;
  final String rating;
  final String body;

  factory PalmSection.fromJson(Map<String, dynamic> j) => PalmSection(
        id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        rating: j['rating'] as String? ?? '',
        body: j['body'] as String? ?? '',
      );
}

class CategoryInfo {
  const CategoryInfo(this.id, this.title, this.line, this.icon, this.colors);
  final String id;
  final String title;
  final String line;
  final IconData icon;
  final List<Color> colors;
}

const categories = [
  CategoryInfo('love', 'Love', 'Romance & 5th house', Icons.favorite_rounded, [Color(0xFF4A1535), Color(0xFF2A1020)]),
  CategoryInfo('marriage', 'Marriage', 'Partnership & 7th house', Icons.volunteer_activism_rounded, [Color(0xFF3D1A4A), Color(0xFF221028)]),
  CategoryInfo('career', 'Career', 'Work & 10th house', Icons.work_rounded, [Color(0xFF1A2F4A), Color(0xFF101A28)]),
  CategoryInfo('business', 'Business', 'Enterprise & growth', Icons.storefront_rounded, [Color(0xFF3D2A10), Color(0xFF221A08)]),
  CategoryInfo('finance', 'Finance', 'Wealth & savings', Icons.savings_rounded, [Color(0xFF1A3D2A), Color(0xFF0F2218)]),
  CategoryInfo('family', 'Family', 'Home & relationships', Icons.home_rounded, [Color(0xFF2A2040), Color(0xFF181028)]),
  CategoryInfo('general', 'General', 'Life path & chart', Icons.auto_awesome_rounded, [Color(0xFF2A1540), Color(0xFF150A20)]),
];

CategoryInfo categoryById(String id) =>
    categories.firstWhere((c) => c.id == id, orElse: () => categories.last);
