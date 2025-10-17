class PackageBooking {
  final String id;
  final String userId;
  final String packageId;
  final String? packageDateId;
  final String bookingReference;
  final String primaryGuestName;
  final String primaryGuestEmail;
  final String primaryGuestPhone;
  final int totalParticipants;
  final Map<String, dynamic>? guestDetails;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final double basePrice;
  final double additionalCosts;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String bookingStatus; // pending, confirmed, cancelled, completed
  final String paymentStatus; // pending, paid, failed, refunded
  final String? paymentMethod;
  final String? paymentReference;
  final String? bkashPaymentId;
  final String? specialRequests;
  final String? dietaryRequirements;
  final String? accessibilityNeeds;
  final String? bookingNotes;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageBooking({
    required this.id,
    required this.userId,
    required this.packageId,
    this.packageDateId,
    required this.bookingReference,
    required this.primaryGuestName,
    required this.primaryGuestEmail,
    required this.primaryGuestPhone,
    required this.totalParticipants,
    this.guestDetails,
    this.departureDate,
    this.returnDate,
    required this.basePrice,
    this.additionalCosts = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.currency = 'USD',
    this.bookingStatus = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.paymentReference,
    this.bkashPaymentId,
    this.specialRequests,
    this.dietaryRequirements,
    this.accessibilityNeeds,
    this.bookingNotes,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageBooking.fromMap(Map<String, dynamic> map) {
    return PackageBooking(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      packageId: map['item_id'] ?? '',
      packageDateId: map['package_date_id'],
      bookingReference: map['booking_reference'] ?? '',
      primaryGuestName: map['primary_guest_name'] ?? '',
      primaryGuestEmail: map['primary_guest_email'] ?? '',
      primaryGuestPhone: map['primary_guest_phone'] ?? '',
      totalParticipants: map['total_participants'] ?? 1,
      guestDetails: map['guest_details'],
      departureDate: map['departure_date'] != null 
          ? DateTime.parse(map['departure_date']) 
          : null,
      returnDate: map['return_date'] != null 
          ? DateTime.parse(map['return_date']) 
          : null,
      basePrice: (map['base_price'] ?? 0).toDouble(),
      additionalCosts: (map['additional_costs'] ?? 0).toDouble(),
      discountAmount: (map['discount_amount'] ?? 0).toDouble(),
      taxAmount: (map['tax_amount'] ?? 0).toDouble(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      bookingStatus: map['booking_status'] ?? 'pending',
      paymentStatus: map['payment_status'] ?? 'pending',
      paymentMethod: map['payment_method'],
      paymentReference: map['payment_reference'],
      bkashPaymentId: map['bkash_payment_id'],
      specialRequests: map['special_requests'],
      dietaryRequirements: map['dietary_requirements'],
      accessibilityNeeds: map['accessibility_needs'],
      bookingNotes: map['booking_notes'],
      cancelledAt: map['cancelled_at'] != null 
          ? DateTime.parse(map['cancelled_at']) 
          : null,
      cancellationReason: map['cancellation_reason'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'booking_type': 'package',
      'item_id': packageId,
      'package_date_id': packageDateId,
      'booking_reference': bookingReference,
      'primary_guest_name': primaryGuestName,
      'primary_guest_email': primaryGuestEmail,
      'primary_guest_phone': primaryGuestPhone,
      'total_participants': totalParticipants,
      'guest_details': guestDetails,
      'departure_date': departureDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'base_price': basePrice,
      'additional_costs': additionalCosts,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'currency': currency,
      'booking_status': bookingStatus,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'bkash_payment_id': bkashPaymentId,
      'special_requests': specialRequests,
      'dietary_requirements': dietaryRequirements,
      'accessibility_needs': accessibilityNeeds,
      'booking_notes': bookingNotes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPastBooking {
    if (departureDate == null) return false;
    return departureDate!.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    if (departureDate == null) return false;
    return departureDate!.isAfter(DateTime.now()) && 
           bookingStatus != 'cancelled' && 
           bookingStatus != 'completed';
  }

  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isCompleted => bookingStatus == 'completed';
  bool get isPaid => paymentStatus == 'paid';
}
