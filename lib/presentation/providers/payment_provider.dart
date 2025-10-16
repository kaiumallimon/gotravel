import 'package:flutter/material.dart';
import 'package:gotravel/data/models/payment_model.dart';
import 'package:gotravel/data/services/remote/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<PaymentModel> _userPayments = [];
  PaymentModel? _currentPayment;
  PaymentModel? _selectedPayment;

  // Payment form data
  String _bookingId = '';
  double _amount = 0.0;
  String _currency = 'USD';
  String _paymentMethod = '';
  String? _paymentProvider;
  Map<String, dynamic>? _paymentMethodDetails;
  Map<String, dynamic>? _gatewayResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentModel> get userPayments => _userPayments;
  PaymentModel? get currentPayment => _currentPayment;
  PaymentModel? get selectedPayment => _selectedPayment;

  // Form getters
  String get bookingId => _bookingId;
  double get amount => _amount;
  String get currency => _currency;
  String get paymentMethod => _paymentMethod;
  String? get paymentProvider => _paymentProvider;
  Map<String, dynamic>? get paymentMethodDetails => _paymentMethodDetails;
  Map<String, dynamic>? get gatewayResponse => _gatewayResponse;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Form setters
  void setBookingId(String id) {
    _bookingId = id;
    notifyListeners();
  }

  void setAmount(double amt) {
    _amount = amt;
    notifyListeners();
  }

  void setCurrency(String curr) {
    _currency = curr;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setPaymentProvider(String? provider) {
    _paymentProvider = provider;
    notifyListeners();
  }

  void setPaymentMethodDetails(Map<String, dynamic>? details) {
    _paymentMethodDetails = details;
    notifyListeners();
  }

  void setGatewayResponse(Map<String, dynamic>? response) {
    _gatewayResponse = response;
    notifyListeners();
  }

  // Load user payments
  Future<void> loadUserPayments({PaymentStatus? status}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _setError(null);

    try {
      _userPayments = await _paymentService.getUserPayments(user.id, status: status);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load payments by booking
  Future<void> loadPaymentsByBooking(String bookingId) async {
    _setLoading(true);
    _setError(null);

    try {
      final payments = await _paymentService.getPaymentsByBooking(bookingId);
      _userPayments = payments;
      if (payments.isNotEmpty) {
        _currentPayment = payments.first;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Initialize payment
  Future<Map<String, dynamic>?> initializePayment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _paymentService.initializePayment(
        bookingId: _bookingId,
        userId: user.id,
        amount: _amount,
        currency: _currency,
        paymentMethod: _paymentMethod,
        paymentProvider: _paymentProvider,
      );

      // Update current payment with the created payment ID
      if (result['payment_id'] != null) {
        _currentPayment = await _paymentService.getPaymentById(result['payment_id']);
      }

      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Process payment (simulate payment gateway integration)
  Future<bool> processPayment(String paymentReference) async {
    _setLoading(true);
    _setError(null);

    try {
      // In a real app, this would involve actual payment gateway integration
      // For now, we'll simulate the process
      
      // Update payment status to processing
      if (_currentPayment != null) {
        await _paymentService.updatePaymentStatus(
          _currentPayment!.id,
          PaymentStatus.processing,
        );
      }

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 3));

      // Verify payment
      _currentPayment = await _paymentService.verifyPayment(paymentReference);
      notifyListeners();

      return _currentPayment?.paymentStatus == PaymentStatus.completed;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String paymentId, PaymentStatus status, {
    String? failureReason,
    String? providerTransactionId,
    Map<String, dynamic>? gatewayResponse,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentPayment = await _paymentService.updatePaymentStatus(
        paymentId,
        status,
        failureReason: failureReason,
        providerTransactionId: providerTransactionId,
        gatewayResponse: gatewayResponse,
      );

      // Update payment in the list
      final index = _userPayments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _userPayments[index] = _currentPayment!;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Process refund
  Future<bool> processRefund(String paymentId, double refundAmount, String reason) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final refundedPayment = await _paymentService.processRefund(
        paymentId,
        refundAmount,
        reason,
        user.id,
      );

      // Update payment in the list
      final index = _userPayments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _userPayments[index] = refundedPayment;
      }

      // Update current payment if it's the same
      if (_currentPayment?.id == paymentId) {
        _currentPayment = refundedPayment;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load payment by ID
  Future<void> loadPaymentById(String paymentId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedPayment = await _paymentService.getPaymentById(paymentId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load payment by reference
  Future<void> loadPaymentByReference(String reference) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedPayment = await _paymentService.getPaymentByReference(reference);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Retry failed payment
  Future<bool> retryPayment(String paymentId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Reset payment status to pending
      await updatePaymentStatus(paymentId, PaymentStatus.pending);
      
      // Get the payment reference and process again
      final payment = await _paymentService.getPaymentById(paymentId);
      if (payment != null) {
        return await processPayment(payment.paymentReference);
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set selected payment
  void setSelectedPayment(PaymentModel? payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  // Set current payment
  void setCurrentPayment(PaymentModel? payment) {
    _currentPayment = payment;
    notifyListeners();
  }

  // Clear form data
  void clearFormData() {
    _bookingId = '';
    _amount = 0.0;
    _currency = 'USD';
    _paymentMethod = '';
    _paymentProvider = null;
    _paymentMethodDetails = null;
    _gatewayResponse = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Get payment methods (in a real app, this might come from a service)
  List<Map<String, dynamic>> getAvailablePaymentMethods() {
    return [
      {
        'id': 'card',
        'name': 'Credit/Debit Card',
        'icon': 'credit_card',
        'providers': ['stripe', 'paypal'],
      },
      {
        'id': 'bank_transfer',
        'name': 'Bank Transfer',
        'icon': 'account_balance',
        'providers': ['local_bank'],
      },
      {
        'id': 'mobile_money',
        'name': 'Mobile Money',
        'icon': 'phone_android',
        'providers': ['bkash', 'nagad', 'rocket'],
      },
      {
        'id': 'digital_wallet',
        'name': 'Digital Wallet',
        'icon': 'account_balance_wallet',
        'providers': ['paypal', 'google_pay', 'apple_pay'],
      },
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}