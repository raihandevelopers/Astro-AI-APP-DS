import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutResult {
  RazorpayCheckoutResult({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
  final String orderId;
  final String paymentId;
  final String signature;
}

/// Opens Razorpay checkout and returns verified payment fields from the SDK.
Future<RazorpayCheckoutResult> openRazorpayCheckout({
  required String keyId,
  required String orderId,
  required int amountPaise,
  required String name,
  required String description,
  String? contact,
  String? email,
}) {
  final completer = Completer<RazorpayCheckoutResult>();
  final razorpay = Razorpay();

  void clear() {
    razorpay.clear();
  }

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) {
    if (completer.isCompleted) return;
    completer.complete(
      RazorpayCheckoutResult(
        orderId: res.orderId ?? orderId,
        paymentId: res.paymentId ?? '',
        signature: res.signature ?? '',
      ),
    );
    clear();
  });

  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
    if (completer.isCompleted) return;
    completer.completeError(
      Exception(res.message?.isNotEmpty == true ? res.message! : 'Payment failed or cancelled'),
    );
    clear();
  });

  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse res) {
    debugPrint('External wallet: ${res.walletName}');
  });

  razorpay.open({
    'key': keyId,
    'amount': amountPaise,
    'currency': 'INR',
    'name': name,
    'description': description,
    'order_id': orderId,
    'prefill': {
      if (contact != null && contact.isNotEmpty) 'contact': contact,
      if (email != null && email.isNotEmpty) 'email': email,
    },
    'theme': {'color': '#FF7A1A'},
  });

  return completer.future;
}
