import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/presentation/providers/booking_provider.dart';
import 'package:provider/provider.dart';

class BkashWebviewPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String bookingId;
  final String paymentId;
  final String idToken;
  
  const BkashWebviewPaymentPage({
    super.key,
    required this.paymentUrl,
    required this.bookingId,
    required this.paymentId,
    required this.idToken,
  });

  @override
  State<BkashWebviewPaymentPage> createState() => _BkashWebviewPaymentPageState();
}

class _BkashWebviewPaymentPageState extends State<BkashWebviewPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessingPayment = false;

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
          onProgress: (int progress) {
            debugPrint('🔄 WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('📄 Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('✅ Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            
            // Check if the URL contains the callback
            _checkPaymentCallback(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔀 Navigation request: ${request.url}');
            
            // Check if this is a callback URL
            _checkPaymentCallback(request.url);
            
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentCallback(String url) {
    debugPrint('🔍 Checking URL for callback: $url');
    
    // Don't process if already processing
    if (_isProcessingPayment) {
      debugPrint('⏭️ Already processing payment, skipping...');
      return;
    }
    
    // Convert URL to lowercase for case-insensitive matching
    final urlLower = url.toLowerCase();
    
    // Check if URL contains status parameter (e.g., ?status=success)
    final uri = Uri.parse(url);
    final status = uri.queryParameters['status'];
    
    if (status != null) {
      debugPrint('💳 Payment callback detected with status parameter: $status');
      _handlePaymentCallback(status);
      return;
    }
    
    // Also check if URL ends with success/failure/cancel pages
    if (urlLower.contains('success.html') || urlLower.contains('/success')) {
      debugPrint('💳 Payment callback detected: Success page loaded');
      _handlePaymentCallback('success');
    } else if (urlLower.contains('failure.html') || urlLower.contains('/failure')) {
      debugPrint('💳 Payment callback detected: Failure page loaded');
      _handlePaymentCallback('failure');
    } else if (urlLower.contains('cancel') || urlLower.contains('cancelled.html')) {
      debugPrint('💳 Payment callback detected: Cancel page loaded');
      _handlePaymentCallback('cancel');
    }
  }

  Future<void> _handlePaymentCallback(String status) async {
    if (_isProcessingPayment) return;
    
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      if (status == 'success') {
        debugPrint('✅ Payment successful! Auto-closing WebView and executing payment...');
        
        // Show processing dialog (this also visually hides the WebView)
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PopScope(
              canPop: false, // Prevent back button during processing
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing payment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        
        // Execute the payment on backend
        debugPrint('📡 Calling executePayment API...');
        final success = await bookingProvider.executePayment(
          bookingId: widget.bookingId,
          paymentId: widget.paymentId,
          idToken: widget.idToken,
        );
        
        if (mounted) {
          // Close processing dialog
          Navigator.of(context).pop();
          
          if (success) {
            debugPrint('✅ Payment executed successfully! Updating bookings...');
            
            // Reload bookings to get updated data
            await bookingProvider.loadBookings();
            
            debugPrint('✅ Bookings reloaded. Closing WebView and navigating to My Trips...');
            
            // Close the WebView page and navigate to My Trips
            context.go('/my-trips');
            
            // Show success snackbar after navigation
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Payment successful! Your booking is confirmed.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            });
          } else {
            // Show error
            debugPrint('❌ Payment execution failed!');
            _showErrorDialog('Payment execution failed. Please contact support with your booking reference.');
          }
        }
      } else if (status == 'failure') {
        debugPrint('❌ Payment failed! Auto-closing WebView...');
        if (mounted) {
          // Small delay to let user see the failure page briefly
          await Future.delayed(const Duration(milliseconds: 500));
          _showErrorDialog('Payment failed. Please try again or use a different payment method.');
        }
      } else if (status == 'cancel') {
        debugPrint('🚫 Payment cancelled by user! Auto-closing WebView...');
        if (mounted) {
          // Small delay to let user see the cancel page briefly
          await Future.delayed(const Duration(milliseconds: 500));
          _showCancelDialog();
        }
      }
    } catch (e) {
      debugPrint('💥 Error handling payment callback: $e');
      if (mounted) {
        // Close processing dialog if open
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        _showErrorDialog('An error occurred while processing your payment. Please check your bookings or contact support.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/my-trips'); // Go back to My Trips
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Payment Cancelled'),
          ],
        ),
        content: const Text('You have cancelled the payment. Your booking has not been confirmed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/my-trips'); // Go back to My Trips
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
        title: const Text('bKash Payment'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
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
                      Navigator.of(context).pop(); // Close dialog
                      context.go('/my-trips'); // Go back
                    },
                    child: const Text('Yes'),
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
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: theme.scaffoldBackgroundColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading bKash payment...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
