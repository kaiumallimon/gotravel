import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gotravel/data/services/payment_gateway/bkash_create_payment.dart';
import 'package:gotravel/data/services/payment_gateway/bkash_execute_payment.dart';
import 'package:gotravel/data/services/payment_gateway/bkash_grant_token.dart';
import 'package:gotravel/data/services/payment_gateway/error_codes.dart';
import 'package:http/http.dart' as http;


class BkashRepository {
  // Grant token
  final username = dotenv.env["BKASH_USERNAME"] ?? "sandbox_test";
  final password = dotenv.env["BKASH_PASSWORD"] ?? "11111111";
  final appKey = dotenv.env["BKASH_APP_KEY"] ?? "";
  final appSecret = dotenv.env["BKASH_APP_SECRET"] ?? "";
  Future<GrantTokenResponse> grantToken() async {
    print("grant token credentials: $username, $password, $appKey, $appSecret");
    final response = await http.post(
      Uri.parse(
        "https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout/token/grant",
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "username": username,
        "password": password,
      },
      body: utf8.encode(
        jsonEncode({"app_key": appKey, "app_secret": appSecret}),
      ),
    );

    if (response.statusCode == 200) {
      log("grant token: ${response.body}");
      return GrantTokenResponse.fromJson(response.body);
    } else {
      print("grant token: ${response.body}");
      return GrantTokenResponse(
        statusCode: response.statusCode.toString(),
        statusMessage:
            bkashErrorCodes[response.statusCode] ?? "Something went wrong",
        idToken: "idToken",
        tokenType: "tokenType",
        expiresIn: 123,
        refreshToken: "refreshToken",
      );
    }
  }

  // Create payment
  Future<CreatePaymentResponse> createPayment({
    required String idToken,
    required String amount,
    required String invoiceNumber,
  }) async {
    final response = await http.post(
      Uri.parse(
        "https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout/create",
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": idToken,
        "X-App-Key": appKey,
      },
      body: utf8.encode(
        jsonEncode({
          "mode": "0011",
          "payerReference": "nothing",
          "callbackURL": "https://callback-bkash.netlify.app/",
          "amount": amount,
          "currency": "BDT",
          "intent": "sale",
          "merchantInvoiceNumber": invoiceNumber,
        }),
      ),
    );

    if (response.statusCode == 200) {
      print("create payment: ${response.body}");
      return CreatePaymentResponse.fromJson(response.body);
    } else {
      return CreatePaymentResponse(
        paymentID: "paymentID",
        paymentCreateTime: "paymentCreateTime",
        transactionStatus: "transactionStatus",
        amount: "amount",
        currency: "currency",
        intent: "intent",
        merchantInvoiceNumber: "merchantInvoiceNumber",
        bkashURL: "bkashURL",
        callbackURL: "callbackURL",
        successCallbackURL: "successCallbackURL",
        failureCallbackURL: "failureCallbackURL",
        cancelledCallbackURL: "cancelledCallbackURL",
        statusCode: response.statusCode.toString(),
        statusMessage:
            bkashErrorCodes[response.statusCode] ?? "Something went wrong",
      );
    }
  }

  // Execute payment
  Future<ExecutePaymentResponse> executePaymentresponse({
    required String idToken,
    required String paymentID,
  }) async {
    final response = await http.post(
      Uri.parse(
        'https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout/execute',
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": idToken,
        "X-App-Key": appKey,
      },
      body: utf8.encode(jsonEncode({'paymentID': paymentID})),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('bKash execute response data: $data');
      
      return ExecutePaymentResponse(
        paymentID: data['paymentID']?.toString() ?? '',
        customerMsisdn: data['customerMsisdn']?.toString() ?? '',
        payerReference: data['payerReference']?.toString() ?? '',
        paymentExecuteTime: data['paymentExecuteTime']?.toString() ?? '',
        trxID: data['trxID']?.toString() ?? '',
        transactionStatus: data['transactionStatus']?.toString() ?? '',
        amount: data['amount']?.toString() ?? '',
        currency: data['currency']?.toString() ?? '',
        intent: data['intent']?.toString() ?? '',
        merchantInvoiceNumber: data['merchantInvoiceNumber']?.toString() ?? '',
        statusCode: data['statusCode']?.toString() ?? '0000',
        statusMessage: data['statusMessage']?.toString() ?? '',
      );
    } else {
      return ExecutePaymentResponse(
        paymentID: "paymentID",
        customerMsisdn: "customerMsisdn",
        payerReference: "payerReference",
        paymentExecuteTime: "paymentExecuteTime",
        trxID: "trxID",
        transactionStatus: "transactionStatus",
        amount: "amount",
        currency: "currency",
        intent: "intent",
        merchantInvoiceNumber: "merchantInvoiceNumber",
        statusCode: response.statusCode.toString(),
        statusMessage:
            bkashErrorCodes[response.statusCode] ?? "Something went wrong",
      );
    }
  }
}
