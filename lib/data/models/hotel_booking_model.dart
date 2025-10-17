class HotelBooking {
  final String id;
  final String userId;
  final String hotelId;
  final String? roomId;
  final String bookingReference;
  final String primaryGuestName;
  final String primaryGuestEmail;
  final String primaryGuestPhone;
  final int totalParticipants; // Number of guests
  final Map<String, dynamic>? guestDetails;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int roomCount;
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

  HotelBooking({
    required this.id,
    required this.userId,
    required this.hotelId,
    this.roomId,
    required this.bookingReference,
    required this.primaryGuestName,
    required this.primaryGuestEmail,
    required this.primaryGuestPhone,
    required this.totalParticipants,
    this.guestDetails,
    this.checkInDate,
    this.checkOutDate,
    this.roomCount = 1,
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

  factory HotelBooking.fromMap(Map<String, dynamic> map) {
    return HotelBooking(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      hotelId: map['item_id'] ?? '',
      roomId: map['room_id'],
      bookingReference: map['booking_reference'] ?? '',
      primaryGuestName: map['primary_guest_name'] ?? '',
      primaryGuestEmail: map['primary_guest_email'] ?? '',
      primaryGuestPhone: map['primary_guest_phone'] ?? '',
      totalParticipants: map['total_participants'] ?? 1,
      guestDetails: map['guest_details'],
      checkInDate: map['check_in_date'] != null 
          ? DateTime.parse(map['check_in_date']) 
          : null,
      checkOutDate: map['check_out_date'] != null 
          ? DateTime.parse(map['check_out_date']) 
          : null,
      roomCount: map['room_count'] ?? 1,
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
      'booking_type': 'hotel',
      'item_id': hotelId,
      'room_id': roomId,
      'booking_reference': bookingReference,
      'primary_guest_name': primaryGuestName,
      'primary_guest_email': primaryGuestEmail,
      'primary_guest_phone': primaryGuestPhone,
      'total_participants': totalParticipants,
      'guest_details': guestDetails,
      'check_in_date': checkInDate?.toIso8601String(),
      'check_out_date': checkOutDate?.toIso8601String(),
      'room_count': roomCount,
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

  int get numberOfNights {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  bool get isPastBooking {
    if (checkInDate == null) return false;
    return checkInDate!.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    if (checkInDate == null) return false;
    return checkInDate!.isAfter(DateTime.now()) && 
           bookingStatus != 'cancelled' && 
           bookingStatus != 'completed';
  }

  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isCompleted => bookingStatus == 'completed';
  bool get isPaid => paymentStatus == 'paid';
}
