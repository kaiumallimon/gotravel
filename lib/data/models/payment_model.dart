class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final String paymentReference;
  
  // Payment Details
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? paymentProvider;
  final String? providerTransactionId;
  
  // Payment Status
  final PaymentStatus paymentStatus;
  final String? failureReason;
  
  // Payment Method Details
  final Map<String, dynamic>? paymentMethodDetails;
  
  // Refund Information
  final double refundAmount;
  final String? refundReason;
  final DateTime? refundedAt;
  final String? refundedBy;
  
  // Metadata
  final Map<String, dynamic>? paymentGatewayResponse;
  final String? paymentNotes;
  final DateTime? processedAt;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.paymentReference,
    required this.amount,
    this.currency = 'USD',
    required this.paymentMethod,
    this.paymentProvider,
    this.providerTransactionId,
    this.paymentStatus = PaymentStatus.pending,
    this.failureReason,
    this.paymentMethodDetails,
    this.refundAmount = 0.0,
    this.refundReason,
    this.refundedAt,
    this.refundedBy,
    this.paymentGatewayResponse,
    this.paymentNotes,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? paymentReference,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? paymentProvider,
    String? providerTransactionId,
    PaymentStatus? paymentStatus,
    String? failureReason,
    Map<String, dynamic>? paymentMethodDetails,
    double? refundAmount,
    String? refundReason,
    DateTime? refundedAt,
    String? refundedBy,
    Map<String, dynamic>? paymentGatewayResponse,
    String? paymentNotes,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      paymentReference: paymentReference ?? this.paymentReference,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      failureReason: failureReason ?? this.failureReason,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundedBy: refundedBy ?? this.refundedBy,
      paymentGatewayResponse: paymentGatewayResponse ?? this.paymentGatewayResponse,
      paymentNotes: paymentNotes ?? this.paymentNotes,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'payment_reference': paymentReference,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_provider': paymentProvider,
      'provider_transaction_id': providerTransactionId,
      'payment_status': paymentStatus.value,
      'failure_reason': failureReason,
      'payment_method_details': paymentMethodDetails,
      'refund_amount': refundAmount,
      'refund_reason': refundReason,
      'refunded_at': refundedAt?.toIso8601String(),
      'refunded_by': refundedBy,
      'payment_gateway_response': paymentGatewayResponse,
      'payment_notes': paymentNotes,
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      userId: map['user_id'] ?? '',
      paymentReference: map['payment_reference'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'USD',
      paymentMethod: map['payment_method'] ?? '',
      paymentProvider: map['payment_provider'],
      providerTransactionId: map['provider_transaction_id'],
      paymentStatus: PaymentStatus.fromString(map['payment_status'] ?? 'pending'),
      failureReason: map['failure_reason'],
      paymentMethodDetails: map['payment_method_details'] != null
          ? Map<String, dynamic>.from(map['payment_method_details'])
          : null,
      refundAmount: map['refund_amount']?.toDouble() ?? 0.0,
      refundReason: map['refund_reason'],
      refundedAt: map['refunded_at'] != null ? DateTime.parse(map['refunded_at']) : null,
      refundedBy: map['refunded_by'],
      paymentGatewayResponse: map['payment_gateway_response'] != null
          ? Map<String, dynamic>.from(map['payment_gateway_response'])
          : null,
      paymentNotes: map['payment_notes'],
      processedAt: map['processed_at'] != null ? DateTime.parse(map['processed_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, paymentReference: $paymentReference, amount: $amount, status: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled'),
  refunded('refunded');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}