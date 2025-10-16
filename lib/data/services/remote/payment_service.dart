import 'package:gotravel/data/models/payment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new payment record
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final response = await _supabase
          .from('payments')
          .insert(payment.toMap())
          .select()
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment
  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    try {
      final response = await _supabase
          .from('payments')
          .update(payment.toMap())
          .eq('id', payment.id)
          .select()
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  /// Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('id', paymentId)
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch payment: $e');
    }
  }

  /// Get payment by reference
  Future<PaymentModel?> getPaymentByReference(String reference) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('payment_reference', reference)
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch payment: $e');
    }
  }

  /// Get payments by booking ID
  Future<List<PaymentModel>> getPaymentsByBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*')
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((payment) => PaymentModel.fromMap(payment)).toList();
    } catch (e) {
      throw Exception('Failed to fetch payments by booking: $e');
    }
  }

  /// Get user payments
  Future<List<PaymentModel>> getUserPayments(String userId, {
    PaymentStatus? status,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('payments')
          .select('*')
          .eq('user_id', userId);

      if (status != null) {
        queryBuilder = queryBuilder.eq('payment_status', status.value);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((payment) => PaymentModel.fromMap(payment)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user payments: $e');
    }
  }

  /// Update payment status
  Future<PaymentModel> updatePaymentStatus(String paymentId, PaymentStatus status, {
    String? failureReason,
    String? providerTransactionId,
    Map<String, dynamic>? gatewayResponse,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'payment_status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == PaymentStatus.completed) {
        updateData['processed_at'] = DateTime.now().toIso8601String();
      }

      if (failureReason != null) {
        updateData['failure_reason'] = failureReason;
      }

      if (providerTransactionId != null) {
        updateData['provider_transaction_id'] = providerTransactionId;
      }

      if (gatewayResponse != null) {
        updateData['payment_gateway_response'] = gatewayResponse;
      }

      final response = await _supabase
          .from('payments')
          .update(updateData)
          .eq('id', paymentId)
          .select()
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Process refund
  Future<PaymentModel> processRefund(String paymentId, double refundAmount, String reason, String refundedBy) async {
    try {
      final response = await _supabase
          .from('payments')
          .update({
        'payment_status': PaymentStatus.refunded.value,
        'refund_amount': refundAmount,
        'refund_reason': reason,
        'refunded_at': DateTime.now().toIso8601String(),
        'refunded_by': refundedBy,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', paymentId)
          .select()
          .single();

      return PaymentModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }

  /// Generate unique payment reference
  Future<String> generatePaymentReference() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PAY$timestamp$random';
  }

  /// Initialize payment with payment gateway
  Future<Map<String, dynamic>> initializePayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? paymentProvider,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate payment reference
      final paymentReference = await generatePaymentReference();

      // Create payment record
      final payment = PaymentModel(
        id: '', // Will be generated by database
        bookingId: bookingId,
        userId: userId,
        paymentReference: paymentReference,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        paymentProvider: paymentProvider,
        paymentStatus: PaymentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdPayment = await createPayment(payment);

      // Here you would integrate with actual payment gateway
      // For now, return mock response
      return {
        'payment_id': createdPayment.id,
        'payment_reference': paymentReference,
        'status': 'initialized',
        'gateway_url': 'https://payment-gateway.example.com/pay/$paymentReference',
        'client_secret': 'mock_client_secret_${paymentReference}',
      };
    } catch (e) {
      throw Exception('Failed to initialize payment: $e');
    }
  }

  /// Verify payment with gateway
  Future<PaymentModel> verifyPayment(String paymentReference) async {
    try {
      // Get payment record
      final payment = await getPaymentByReference(paymentReference);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      // Here you would verify with actual payment gateway
      // For now, simulate verification
      final isVerified = await _simulatePaymentVerification(paymentReference);

      if (isVerified) {
        return await updatePaymentStatus(
          payment.id,
          PaymentStatus.completed,
          providerTransactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        return await updatePaymentStatus(
          payment.id,
          PaymentStatus.failed,
          failureReason: 'Payment verification failed',
        );
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  /// Simulate payment verification (replace with actual gateway integration)
  Future<bool> _simulatePaymentVerification(String paymentReference) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate 90% success rate
    return DateTime.now().millisecond % 10 != 0;
  }

  /// Get payment statistics for admin
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final response = await _supabase.rpc('get_payment_statistics');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      // If the function doesn't exist, calculate manually
      try {
        final allPayments = await _supabase.from('payments').select('payment_status, amount, currency, created_at');
        final List data = allPayments;

        int totalPayments = data.length;
        int completedPayments = data.where((p) => p['payment_status'] == 'completed').length;
        int failedPayments = data.where((p) => p['payment_status'] == 'failed').length;
        int pendingPayments = data.where((p) => p['payment_status'] == 'pending').length;

        double totalRevenue = data
            .where((p) => p['payment_status'] == 'completed')
            .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());

        return {
          'total_payments': totalPayments,
          'completed_payments': completedPayments,
          'failed_payments': failedPayments,
          'pending_payments': pendingPayments,
          'total_revenue': totalRevenue,
          'success_rate': totalPayments > 0 ? (completedPayments / totalPayments * 100).toStringAsFixed(2) : '0.00',
        };
      } catch (e2) {
        throw Exception('Failed to get payment statistics: $e2');
      }
    }
  }
}