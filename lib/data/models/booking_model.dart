class BookingModel {
  final String id;
  final String userId;
  final BookingType bookingType;
  final String itemId;
  final String bookingReference;
  
  // Guest Information
  final String primaryGuestName;
  final String primaryGuestEmail;
  final String primaryGuestPhone;
  final int totalParticipants;
  final List<GuestDetail>? guestDetails;
  
  // Booking Details
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String? packageDateId;
  final String? roomId;
  final int roomCount;
  
  // Pricing
  final double basePrice;
  final double additionalCosts;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  
  // Status & Payment
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  
  // Special Requests
  final String? specialRequests;
  final String? dietaryRequirements;
  final String? accessibilityNeeds;
  
  // Metadata
  final String bookingSource;
  final String? bookingNotes;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.itemId,
    required this.bookingReference,
    required this.primaryGuestName,
    required this.primaryGuestEmail,
    required this.primaryGuestPhone,
    this.totalParticipants = 1,
    this.guestDetails,
    this.checkInDate,
    this.checkOutDate,
    this.departureDate,
    this.returnDate,
    this.packageDateId,
    this.roomId,
    this.roomCount = 1,
    required this.basePrice,
    this.additionalCosts = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.currency = 'USD',
    this.bookingStatus = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    this.paymentReference,
    this.specialRequests,
    this.dietaryRequirements,
    this.accessibilityNeeds,
    this.bookingSource = 'web',
    this.bookingNotes,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    required this.createdAt,
    required this.updatedAt,
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    BookingType? bookingType,
    String? itemId,
    String? bookingReference,
    String? primaryGuestName,
    String? primaryGuestEmail,
    String? primaryGuestPhone,
    int? totalParticipants,
    List<GuestDetail>? guestDetails,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    DateTime? departureDate,
    DateTime? returnDate,
    String? packageDateId,
    String? roomId,
    int? roomCount,
    double? basePrice,
    double? additionalCosts,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    BookingStatus? bookingStatus,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? paymentReference,
    String? specialRequests,
    String? dietaryRequirements,
    String? accessibilityNeeds,
    String? bookingSource,
    String? bookingNotes,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingType: bookingType ?? this.bookingType,
      itemId: itemId ?? this.itemId,
      bookingReference: bookingReference ?? this.bookingReference,
      primaryGuestName: primaryGuestName ?? this.primaryGuestName,
      primaryGuestEmail: primaryGuestEmail ?? this.primaryGuestEmail,
      primaryGuestPhone: primaryGuestPhone ?? this.primaryGuestPhone,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      guestDetails: guestDetails ?? this.guestDetails,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      packageDateId: packageDateId ?? this.packageDateId,
      roomId: roomId ?? this.roomId,
      roomCount: roomCount ?? this.roomCount,
      basePrice: basePrice ?? this.basePrice,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      specialRequests: specialRequests ?? this.specialRequests,
      dietaryRequirements: dietaryRequirements ?? this.dietaryRequirements,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      bookingSource: bookingSource ?? this.bookingSource,
      bookingNotes: bookingNotes ?? this.bookingNotes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'booking_type': bookingType.value,
      'item_id': itemId,
      'booking_reference': bookingReference,
      'primary_guest_name': primaryGuestName,
      'primary_guest_email': primaryGuestEmail,
      'primary_guest_phone': primaryGuestPhone,
      'total_participants': totalParticipants,
      'guest_details': guestDetails?.map((x) => x.toMap()).toList(),
      'check_in_date': checkInDate?.toIso8601String().split('T')[0],
      'check_out_date': checkOutDate?.toIso8601String().split('T')[0],
      'departure_date': departureDate?.toIso8601String().split('T')[0],
      'return_date': returnDate?.toIso8601String().split('T')[0],
      'package_date_id': packageDateId,
      'room_id': roomId,
      'room_count': roomCount,
      'base_price': basePrice,
      'additional_costs': additionalCosts,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'currency': currency,
      'booking_status': bookingStatus.value,
      'payment_status': paymentStatus.value,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'special_requests': specialRequests,
      'dietary_requirements': dietaryRequirements,
      'accessibility_needs': accessibilityNeeds,
      'booking_source': bookingSource,
      'booking_notes': bookingNotes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      bookingType: BookingType.fromString(map['booking_type'] ?? 'package'),
      itemId: map['item_id'] ?? '',
      bookingReference: map['booking_reference'] ?? '',
      primaryGuestName: map['primary_guest_name'] ?? '',
      primaryGuestEmail: map['primary_guest_email'] ?? '',
      primaryGuestPhone: map['primary_guest_phone'] ?? '',
      totalParticipants: map['total_participants']?.toInt() ?? 1,
      guestDetails: map['guest_details'] != null
          ? List<GuestDetail>.from(map['guest_details']?.map((x) => GuestDetail.fromMap(x)))
          : null,
      checkInDate: map['check_in_date'] != null ? DateTime.parse(map['check_in_date']) : null,
      checkOutDate: map['check_out_date'] != null ? DateTime.parse(map['check_out_date']) : null,
      departureDate: map['departure_date'] != null ? DateTime.parse(map['departure_date']) : null,
      returnDate: map['return_date'] != null ? DateTime.parse(map['return_date']) : null,
      packageDateId: map['package_date_id'],
      roomId: map['room_id'],
      roomCount: map['room_count']?.toInt() ?? 1,
      basePrice: map['base_price']?.toDouble() ?? 0.0,
      additionalCosts: map['additional_costs']?.toDouble() ?? 0.0,
      discountAmount: map['discount_amount']?.toDouble() ?? 0.0,
      taxAmount: map['tax_amount']?.toDouble() ?? 0.0,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'USD',
      bookingStatus: BookingStatus.fromString(map['booking_status'] ?? 'pending'),
      paymentStatus: PaymentStatus.fromString(map['payment_status'] ?? 'pending'),
      paymentMethod: map['payment_method'],
      paymentReference: map['payment_reference'],
      specialRequests: map['special_requests'],
      dietaryRequirements: map['dietary_requirements'],
      accessibilityNeeds: map['accessibility_needs'],
      bookingSource: map['booking_source'] ?? 'web',
      bookingNotes: map['booking_notes'],
      cancelledAt: map['cancelled_at'] != null ? DateTime.parse(map['cancelled_at']) : null,
      cancellationReason: map['cancellation_reason'],
      cancelledBy: map['cancelled_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, bookingReference: $bookingReference, bookingStatus: $bookingStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class GuestDetail {
  final String name;
  final String? email;
  final String? phone;
  final int? age;
  final String? gender;
  final String? specialRequirements;

  GuestDetail({
    required this.name,
    this.email,
    this.phone,
    this.age,
    this.gender,
    this.specialRequirements,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'special_requirements': specialRequirements,
    };
  }

  factory GuestDetail.fromMap(Map<String, dynamic> map) {
    return GuestDetail(
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      age: map['age']?.toInt(),
      gender: map['gender'],
      specialRequirements: map['special_requirements'],
    );
  }
}

enum BookingType {
  package('package'),
  hotel('hotel');

  const BookingType(this.value);
  final String value;

  static BookingType fromString(String value) {
    return BookingType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingType.package,
    );
  }
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  failed('failed'),
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