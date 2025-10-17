import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class BkashPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String paymentID;
  final String idToken;
  final String bookingId;

  const BkashPaymentPage({
    super.key,
    required this.paymentUrl,
    required this.paymentID,
    required this.idToken,
    required this.bookingId,
  });

  @override
  State<BkashPaymentPage> createState() => _BkashPaymentPageState();
}

class _BkashPaymentPageState extends State<BkashPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    // Check if callback URL is reached
    if (url.contains('paymentcallback.netlify.app')) {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];
      
      if (status == 'success') {
        // Payment successful - navigate to success page with payment info
        context.go('/payment-success', extra: {
          'paymentID': widget.paymentID,
          'idToken': widget.idToken,
          'bookingId': widget.bookingId,
        });
      } else if (status == 'failure' || status == 'cancel') {
        // Payment failed or cancelled
        _showPaymentFailedDialog(status == 'cancel' ? 'Payment was cancelled' : 'Payment failed');
      }
    }
  }

  void _showPaymentFailedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/my-trips');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: const Text(
          'bKash Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text('Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/my-trips');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
