import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  MidtransSDK? _midtrans;

  // Inisialisasi SDK Midtrans untuk development
  Future<void> initSDK(BuildContext context) async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: "SB-Mid-client-61XuGAwQ8Bj8LzSS", // Development client key
        merchantBaseUrl: "https://api.sandbox.midtrans.com", // Sandbox URL
        colorTheme: ColorTheme(
          colorPrimary: Theme.of(context).colorScheme.secondary,
          colorPrimaryDark: Theme.of(context).colorScheme.secondary,
          colorSecondary: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
    );
    _midtrans!.setTransactionFinishedCallback((result) {
      print(
          "Transaction Result: ${result.toJson()}"); // Callback setelah transaksi selesai
    });
  }

  // Fungsi untuk memulai pembayaran dengan token
  Future<void> startPayment(String token) async {
    await _midtrans?.startPaymentUiFlow(
      token: token,
    );
  }

  // Fungsi untuk mendapatkan payment link dari backend
  Future<String> getPaymentLink({
    required String orderId,
    required int amount,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Server key sandbox user (Base64: SB-Mid-server-5LgQLUwANsOKdoCSfMAvBmGw:)
          'Authorization':
              'Basic U0ItTWlkLXNlcnZlci01TGdRTFV3QU5zT0tkb0NTZk1BdkJtR3c6',
        },
        body: jsonEncode({
          'transaction_details': {'order_id': orderId, 'gross_amount': amount},
          'customer_details': {
            'first_name': customerName,
            'email': customerEmail,
          },
          'item_details': [
            {
              'id': 'item1',
              'price': amount,
              'quantity': 1,
              'name': 'GuideMe Service'
            }
          ]
        }),
      );

      print("Server response: " + response.body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Snap API memberikan redirect_url
        if (data['redirect_url'] != null) {
          return data['redirect_url'];
        }

        // Fallback: buat URL manual
        final token = data['token'];
        return 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$token';
      } else {
        print("Server response: " + response.body);
        throw Exception("Failed to get payment link: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting payment link: $e");
      throw e;
    }
  }

  // Hapus callback transaksi selesai
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
  }
}
