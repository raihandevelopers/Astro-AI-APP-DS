import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.isNetwork = false});
  final String message;
  final bool isNetwork;
  @override
  String toString() => message;
}

class Api {
  Api();
  static const _timeout = Duration(seconds: 20);
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('${apiBaseUrl()}$path').replace(queryParameters: q);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = _u(path, query);
    late http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers).timeout(_timeout);
          break;
        case 'PUT':
          res = await http
              .put(uri, headers: _headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        default:
          res = await http
              .post(uri, headers: _headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
      }
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.', isNetwork: true);
    } on SocketException {
      throw ApiException('No internet connection. Check your network and retry.', isNetwork: true);
    } on http.ClientException {
      throw ApiException('Cannot reach MyFuture. Check your internet connection.', isNetwork: true);
    } on ApiException {
      rethrow;
    } on Exception {
      throw ApiException('Cannot reach MyFuture server. Check your internet connection.', isNetwork: true);
    }
    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    if (res.statusCode >= 500) {
      final msg = json['error'] as String?;
      throw ApiException(
        (msg != null && msg.isNotEmpty) ? msg : 'Server is busy right now. Please try again in a moment.',
        isNetwork: true,
      );
    }
    if (res.statusCode >= 400) {
      throw ApiException(json['error'] as String? ?? 'Something went wrong');
    }
    return json;
  }

  Future<Map<String, dynamic>> requestOtp(String identifier) =>
      _send('POST', '/auth/request-otp', body: {'identifier': identifier});

  Future<Map<String, dynamic>> verifyOtp(String identifier, String otp, {String? referralCode}) =>
      _send('POST', '/auth/verify-otp', body: {
        'identifier': identifier,
        'otp': otp,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      });

  Future<Map<String, dynamic>> me() => _send('GET', '/users/me');

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> body) =>
      _send('PUT', '/users/profile', body: body);

  Future<Map<String, dynamic>> recomputeChart() =>
      _send('POST', '/users/chart/recompute');

  Future<Map<String, dynamic>> generateAiKundliReport() =>
      _send('POST', '/users/chart/ai-report');

  Future<Map<String, dynamic>> getChart() => _send('GET', '/users/chart');

  Future<List<PlaceHit>> searchPlaces(String q) async {
    final json = await _send('GET', '/places/search', query: {'q': q});
    return ((json['places'] as List?) ?? [])
        .map((e) => PlaceHit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> startConsultation(
    String category, {
    String? language,
    bool palmChat = false,
  }) =>
      _send('POST', '/consultations/start', body: {
        'category': category,
        if (language != null) 'language': language,
        if (palmChat) 'palmChat': true,
      });

  Future<Map<String, dynamic>> getConsultation(String id) =>
      _send('GET', '/consultations/$id');

  Future<Map<String, dynamic>> heartbeat(String id) =>
      _send('POST', '/consultations/$id/heartbeat');

  Future<Map<String, dynamic>> sendMessage(String id, String content, {String? language}) =>
      _send('POST', '/consultations/$id/message', body: {
        'content': content,
        if (language != null) 'language': language,
      });

  Future<Map<String, dynamic>> sendPalmInChat(
    String consultationId,
    List<int> bytes, {
    String mimeType = 'image/jpeg',
    String? reading,
  }) async {
    final uri = _u('/consultations/$consultationId/palm');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({
            'image': base64Encode(bytes),
            'mimeType': mimeType,
            if (reading != null && reading.trim().isNotEmpty) 'reading': reading.trim(),
          }),
        )
        .timeout(const Duration(seconds: 90));
    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    if (res.statusCode >= 400) {
      throw ApiException(json['error'] as String? ?? 'Could not analyze palm');
    }
    return json;
  }

  Future<Map<String, dynamic>> endConsultation(String id) =>
      _send('POST', '/consultations/$id/end');

  Future<List<Consultation>> listConsultations() async {
    final json = await _send('GET', '/consultations');
    return ((json['consultations'] as List?) ?? [])
        .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> recharge(int amount) =>
      _send('POST', '/wallet/recharge', body: {'amount': amount});

  Future<Map<String, dynamic>> walletPacks() => _send('GET', '/wallet/packs');

  Future<Map<String, dynamic>> transactions() => _send('GET', '/wallet/transactions');

  Future<Map<String, dynamic>> sendTicket(String subject, String message) =>
      _send('POST', '/support/tickets', body: {'subject': subject, 'message': message});

  Future<List<Map<String, dynamic>>> notifications() async {
    final json = await _send('GET', '/support/notifications');
    return ((json['notifications'] as List?) ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> subscriptionPlans() => _send('GET', '/subscriptions/plans');

  Future<Map<String, dynamic>> createSubscriptionOrder() =>
      _send('POST', '/subscriptions/create-order', body: {'plan': 'monthly'});

  Future<Map<String, dynamic>> verifySubscriptionPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) =>
      _send('POST', '/subscriptions/verify', body: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      });

  Future<Map<String, dynamic>> createWalletOrder(int amount) =>
      _send('POST', '/wallet/create-order', body: {'amount': amount});

  Future<Map<String, dynamic>> verifyWalletPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) =>
      _send('POST', '/wallet/verify', body: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      });

  Future<Map<String, dynamic>> subscribeMonthly() =>
      _send('POST', '/subscriptions/subscribe', body: {'plan': 'monthly'});

  Future<Map<String, dynamic>> referralInfo() => _send('GET', '/referrals/me');

  Future<Map<String, dynamic>> applyReferral(String code) =>
      _send('POST', '/referrals/apply', body: {'code': code});

  Future<PalmReadingResult> analyzePalm(List<int> bytes, {String mimeType = 'image/jpeg', bool fromChat = false}) async {
    final uri = _u('/palm/analyze');
    final res = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode({
            'image': base64Encode(bytes),
            'mimeType': mimeType,
            if (fromChat) 'source': 'chat',
          }),
        )
        .timeout(const Duration(seconds: 90));
    Map<String, dynamic> json = {};
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    if (res.statusCode >= 400) {
      throw ApiException(json['error'] as String? ?? 'Could not analyze palm');
    }
    return PalmReadingResult.fromJson(json);
  }

  Future<Map<String, dynamic>> kundliGochar() => _send('GET', '/kundli/gochar');

  Future<Map<String, dynamic>> kundliPanchang() => _send('GET', '/kundli/panchang');

  Future<Map<String, dynamic>> kundliMuhurat() => _send('GET', '/kundli/muhurat');

  Future<Map<String, dynamic>> kundliMatch(Map<String, dynamic> partner) =>
      _send('POST', '/kundli/match', body: partner);
}
