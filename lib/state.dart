import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'locale_meta.dart';
import 'models.dart';
import 'payments/razorpay_checkout.dart';

class AppState extends ChangeNotifier {
  final api = Api();
  bool booting = true;
  bool busy = false;
  String? error;
  AppUser? user;
  double ratePerMinute = 1;
  String disclaimer =
      'Guidance and interpretation only. Not a guarantee of future events.';
  Consultation? active;
  int shellTab = 0;
  Locale locale = const Locale('en');

  void goTab(int i) {
    shellTab = i;
    notifyListeners();
  }

  Future<void> boot() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = normalizeLanguageCode(prefs.getString('locale'));
    locale = Locale(saved);
    final t = prefs.getString('token');
    if (t != null) {
      api.token = t;
      try {
        await refreshMe();
      } catch (_) {
        await logout();
      }
    }
    booting = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final normalized = normalizeLanguageCode(code);
    locale = Locale(normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', normalized);
    notifyListeners();
    if (user != null) {
      try {
        final json = await api.saveProfile({'preferredLanguage': normalized});
        user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> refreshMe() async {
    final json = await api.me();
    user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
    final settings = json['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      ratePerMinute = (settings['ratePerMinute'] as num?)?.toDouble() ?? ratePerMinute;
      disclaimer = settings['disclaimer'] as String? ?? disclaimer;
    }
    // Prefer locally chosen language; push it to the server so AI replies match the app UI.
    final local = locale.languageCode;
    final fromUser = normalizeLanguageCode(user?.preferredLanguage);
    if (fromUser != local) {
      try {
        final synced = await api.saveProfile({'preferredLanguage': local});
        user = AppUser.fromJson(synced['user'] as Map<String, dynamic>);
      } catch (_) {
        // Keep local locale even if sync fails.
      }
    }
    notifyListeners();
  }

  Future<void> applyUserJson(Map<String, dynamic> json) async {
    user = AppUser.fromJson(json);
    notifyListeners();
  }

  Future<String?> requestOtp(String identifier) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.requestOtp(identifier);
      return json['otp'] as String?;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String identifier, String otp, {String? referralCode}) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.verifyOtp(identifier, otp, referralCode: referralCode);
      final token = json['token'] as String;
      api.token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
      try {
        final synced = await api.saveProfile({'preferredLanguage': locale.languageCode});
        user = AppUser.fromJson(synced['user'] as Map<String, dynamic>);
      } catch (_) {}
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(Map<String, dynamic> body) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.saveProfile(body);
      user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _applySession(Map<String, dynamic> json) {
    if (json['consultation'] != null) {
      final next = Consultation.fromJson(json['consultation'] as Map<String, dynamic>);
      if (active != null && active!.id == next.id) {
        active = _mergePreservingImages(active!, next);
      } else {
        active = next;
      }
    }
    final bal = (json['walletBalance'] as num?)?.toDouble();
    if (bal != null && user != null) {
      user = user!.copyWith(walletBalance: bal);
    }
  }

  /// Heartbeat omits bulky palm base64 — keep previously loaded images so bubbles don't blink/blank.
  Consultation _mergePreservingImages(Consultation prev, Consultation next) {
    final merged = <ChatMessage>[];
    for (var i = 0; i < next.messages.length; i++) {
      final m = next.messages[i];
      if (m.image != null && m.image!.isNotEmpty) {
        merged.add(m);
        continue;
      }
      ChatMessage? match;
      if (i < prev.messages.length) {
        final p = prev.messages[i];
        if (p.role == m.role && (p.image?.isNotEmpty ?? false)) match = p;
      }
      if (match == null) {
        for (final p in prev.messages) {
          if (p.role == m.role &&
              p.content == m.content &&
              (p.image?.isNotEmpty ?? false)) {
            match = p;
            break;
          }
        }
      }
      if (match != null) {
        merged.add(ChatMessage(
          role: m.role,
          content: m.content,
          at: m.at,
          image: match.image,
          mimeType: match.mimeType ?? m.mimeType,
          kind: m.kind ?? match.kind,
        ));
      } else {
        merged.add(m);
      }
    }
    return Consultation(
      id: next.id,
      category: next.category,
      status: next.status,
      ratePerMinute: next.ratePerMinute,
      startedAt: next.startedAt,
      endedAt: next.endedAt,
      minutesCharged: next.minutesCharged,
      amountCharged: next.amountCharged,
      messages: merged,
      summary: next.summary,
      endReason: next.endReason,
      includedWithPro: next.includedWithPro,
    );
  }

  Future<Consultation?> startConsultation(String category, {bool palmChat = false}) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.startConsultation(
        category,
        language: locale.languageCode,
        palmChat: palmChat,
      );
      _applySession(json);
      return active;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> heartbeat() async {
    if (active == null || !active!.isActive) return;
    try {
      final json = await api.heartbeat(active!.id);
      _applySession(json);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> sendMessage(String content) async {
    if (active == null) return false;
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.sendMessage(active!.id, content, language: locale.languageCode);
      _applySession(json);
      if (json['user'] is Map<String, dynamic>) {
        user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      error = e.toString();
      if (e is ApiException) {
        try {
          final json = await api.getConsultation(active!.id);
          _applySession(json);
        } catch (_) {}
      }
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> endConsultation({bool silent = false}) async {
    if (active == null) return;
    if (!active!.isActive) {
      active = null;
      notifyListeners();
      return;
    }
    if (!silent) {
      busy = true;
      notifyListeners();
    }
    try {
      final json = await api.endConsultation(active!.id);
      _applySession(json);
      // Leave chat = session closed — no LIVE resume / billing
      active = null;
    } catch (e) {
      error = e.toString();
      // Still clear local session so heartbeat / LIVE stops
      active = null;
    } finally {
      if (!silent) busy = false;
      notifyListeners();
    }
  }

  Future<bool> rechargeWallet(int amount) => recharge(amount);

  Future<bool> recharge(int amount) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final order = await api.createWalletOrder(amount);
      final keyId = order['keyId'] as String? ?? '';
      final orderId = order['orderId'] as String? ?? '';
      final amountPaise = (order['amount'] as num?)?.toInt() ?? (amount * 10000);
      final credit = (order['creditAmount'] as num?)?.toInt() ?? amount;
      final isDemo = order['demo'] == true;
      if (orderId.isEmpty || (!isDemo && keyId.isEmpty)) {
        throw ApiException('Could not start payment');
      }

      late final String payOrderId;
      late final String paymentId;
      late final String signature;

      if (isDemo) {
        payOrderId = orderId;
        paymentId = 'pay_demo_${DateTime.now().millisecondsSinceEpoch}';
        signature = 'demo_sig';
      } else {
        busy = false;
        notifyListeners();

        final paid = await openRazorpayCheckout(
          keyId: keyId,
          orderId: orderId,
          amountPaise: amountPaise,
          name: 'MyFuture',
          description: 'Wallet recharge €$credit',
          contact: user?.phone,
          email: user?.email,
        );

        busy = true;
        notifyListeners();

        payOrderId = paid.orderId;
        paymentId = paid.paymentId;
        signature = paid.signature;
      }

      final json = await api.verifyWalletPayment(
        orderId: payOrderId,
        paymentId: paymentId,
        signature: signature,
      );
      user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> subscribeMonthly() async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final order = await api.createSubscriptionOrder();
      final keyId = order['keyId'] as String? ?? '';
      final orderId = order['orderId'] as String? ?? '';
      final amountPaise = (order['amount'] as num?)?.toInt() ?? 110000;
      final planAmount = (order['planAmount'] as num?)?.toInt() ?? 11;
      final planInr = (order['planAmountInr'] as num?)?.toInt() ?? (planAmount * 100);
      final isDemo = order['demo'] == true;
      if (orderId.isEmpty || (!isDemo && keyId.isEmpty)) {
        throw ApiException('Could not start payment');
      }

      late final String payOrderId;
      late final String paymentId;
      late final String signature;

      if (isDemo) {
        payOrderId = orderId;
        paymentId = 'pay_demo_${DateTime.now().millisecondsSinceEpoch}';
        signature = 'demo_sig';
      } else {
        busy = false;
        notifyListeners();

        final paid = await openRazorpayCheckout(
          keyId: keyId,
          orderId: orderId,
          amountPaise: amountPaise,
          name: 'MyFuture',
          description: 'Monthly Pro · €$planAmount (≈ ₹$planInr)',
          contact: user?.phone,
          email: user?.email,
        );

        busy = true;
        notifyListeners();

        payOrderId = paid.orderId;
        paymentId = paid.paymentId;
        signature = paid.signature;
      }

      final json = await api.verifySubscriptionPayment(
        orderId: payOrderId,
        paymentId: paymentId,
        signature: signature,
      );
      user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> sendPalmInChat(List<int> bytes, {String mimeType = 'image/jpeg', String? reading}) async {
    if (active == null) return false;
    error = null;
    busy = true;
    notifyListeners();
    try {
      final json = await api.sendPalmInChat(active!.id, bytes, mimeType: mimeType, reading: reading);
      _applySession(json);
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<PalmReadingResult?> analyzePalm(List<int> bytes, {String mimeType = 'image/jpeg', bool fromChat = false}) async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      final result = await api.analyzePalm(bytes, mimeType: mimeType, fromChat: fromChat);
      if (result.walletBalance != null && user != null) {
        user = user!.copyWith(walletBalance: result.walletBalance);
      }
      return result;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void adopt(Consultation c) {
    active = c;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    api.token = null;
    user = null;
    active = null;
    shellTab = 0;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    error = null;
    busy = true;
    notifyListeners();
    try {
      await api.deleteAccount();
      await logout();
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
