import 'package:flutter/material.dart';
import 'package:gotravel/data/models/booking_model.dart';
import 'package:gotravel/data/services/remote/booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _userBookings = [];
  BookingModel? _currentBooking;
  BookingModel? _selectedBooking;
  
  // Payment state
  String? _pendingPaymentId;
  String? _pendingIdToken;
  String? _pendingBookingId;

  // Form data for creating bookings
  BookingType _bookingType = BookingType.package;
  String _itemId = '';
  String _primaryGuestName = '';
  String _primaryGuestEmail = '';
  String _primaryGuestPhone = '';
  int _totalParticipants = 1;
  List<GuestDetail> _guestDetails = [];
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime? _departureDate;
  DateTime? _returnDate;
  String? _packageDateId;
  String? _roomId;
  int _roomCount = 1;
  double _basePrice = 0.0;
  double _additionalCosts = 0.0;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;
  String _currency = 'USD';
  String? _specialRequests;
  String? _dietaryRequirements;
  String? _accessibilityNeeds;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get userBookings => _userBookings;
  BookingModel? get currentBooking => _currentBooking;
  BookingModel? get selectedBooking => _selectedBooking;

  // Form getters
  BookingType get bookingType => _bookingType;
  String get itemId => _itemId;
  String get primaryGuestName => _primaryGuestName;
  String get primaryGuestEmail => _primaryGuestEmail;
  String get primaryGuestPhone => _primaryGuestPhone;
  int get totalParticipants => _totalParticipants;
  List<GuestDetail> get guestDetails => _guestDetails;
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;
  DateTime? get departureDate => _departureDate;
  DateTime? get returnDate => _returnDate;
  String? get packageDateId => _packageDateId;
  String? get roomId => _roomId;
  int get roomCount => _roomCount;
  double get basePrice => _basePrice;
  double get additionalCosts => _additionalCosts;
  double get discountAmount => _discountAmount;
  double get taxAmount => _taxAmount;
  String get currency => _currency;
  String? get specialRequests => _specialRequests;
  String? get dietaryRequirements => _dietaryRequirements;
  String? get accessibilityNeeds => _accessibilityNeeds;

  // Calculated getters
  double get totalAmount => _basePrice + _additionalCosts + _taxAmount - _discountAmount;

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
  void setBookingType(BookingType type) {
    _bookingType = type;
    notifyListeners();
  }

  void setItemId(String id) {
    _itemId = id;
    notifyListeners();
  }

  void setPrimaryGuestName(String name) {
    _primaryGuestName = name;
    notifyListeners();
  }

  void setPrimaryGuestEmail(String email) {
    _primaryGuestEmail = email;
    notifyListeners();
  }

  void setPrimaryGuestPhone(String phone) {
    _primaryGuestPhone = phone;
    notifyListeners();
  }

  void setTotalParticipants(int participants) {
    _totalParticipants = participants;
    notifyListeners();
  }

  void setGuestDetails(List<GuestDetail> details) {
    _guestDetails = details;
    notifyListeners();
  }

  void addGuestDetail(GuestDetail detail) {
    _guestDetails.add(detail);
    notifyListeners();
  }

  void removeGuestDetail(int index) {
    if (index >= 0 && index < _guestDetails.length) {
      _guestDetails.removeAt(index);
      notifyListeners();
    }
  }

  void setCheckInDate(DateTime? date) {
    _checkInDate = date;
    notifyListeners();
  }

  void setCheckOutDate(DateTime? date) {
    _checkOutDate = date;
    notifyListeners();
  }

  void setDepartureDate(DateTime? date) {
    _departureDate = date;
    notifyListeners();
  }

  void setReturnDate(DateTime? date) {
    _returnDate = date;
    notifyListeners();
  }

  void setPackageDateId(String? id) {
    _packageDateId = id;
    notifyListeners();
  }

  void setRoomId(String? id) {
    _roomId = id;
    notifyListeners();
  }

  void setRoomCount(int count) {
    _roomCount = count;
    notifyListeners();
  }

  void setBasePrice(double price) {
    _basePrice = price;
    notifyListeners();
  }

  void setAdditionalCosts(double costs) {
    _additionalCosts = costs;
    notifyListeners();
  }

  void setDiscountAmount(double discount) {
    _discountAmount = discount;
    notifyListeners();
  }

  void setTaxAmount(double tax) {
    _taxAmount = tax;
    notifyListeners();
  }

  void setCurrency(String curr) {
    _currency = curr;
    notifyListeners();
  }

  void setSpecialRequests(String? requests) {
    _specialRequests = requests;
    notifyListeners();
  }

  void setDietaryRequirements(String? requirements) {
    _dietaryRequirements = requirements;
    notifyListeners();
  }

  void setAccessibilityNeeds(String? needs) {
    _accessibilityNeeds = needs;
    notifyListeners();
  }

  // Load user bookings
  Future<void> loadUserBookings({BookingStatus? status}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _setError(null);

    try {
      _userBookings = await _bookingService.getUserBookings(user.id, status: status);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create booking
  Future<BookingModel?> createBooking() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final bookingReference = await _bookingService.generateBookingReference();
      
      final booking = BookingModel(
        id: '', // Will be generated by database
        userId: user.id,
        bookingType: _bookingType,
        itemId: _itemId,
        bookingReference: bookingReference,
        primaryGuestName: _primaryGuestName,
        primaryGuestEmail: _primaryGuestEmail,
        primaryGuestPhone: _primaryGuestPhone,
        totalParticipants: _totalParticipants,
        guestDetails: _guestDetails.isNotEmpty ? _guestDetails : null,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        departureDate: _departureDate,
        returnDate: _returnDate,
        packageDateId: _packageDateId,
        roomId: _roomId,
        roomCount: _roomCount,
        basePrice: _basePrice,
        additionalCosts: _additionalCosts,
        discountAmount: _discountAmount,
        taxAmount: _taxAmount,
        totalAmount: totalAmount,
        currency: _currency,
        specialRequests: _specialRequests,
        dietaryRequirements: _dietaryRequirements,
        accessibilityNeeds: _accessibilityNeeds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentBooking = await _bookingService.createBooking(booking);
      notifyListeners();
      return _currentBooking;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update booking
  Future<bool> updateBooking(BookingModel booking) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentBooking = await _bookingService.updateBooking(booking);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final cancelledBooking = await _bookingService.cancelBooking(bookingId, reason, user.id);
      
      // Update the booking in the list
      final index = _userBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _userBookings[index] = cancelledBooking;
      }
      
      // Update current booking if it's the same
      if (_currentBooking?.id == bookingId) {
        _currentBooking = cancelledBooking;
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

  // Load booking by ID
  Future<void> loadBookingById(String bookingId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load booking by reference
  Future<void> loadBookingByReference(String reference) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedBooking = await _bookingService.getBookingByReference(reference);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Check availability
  Future<bool> checkAvailability() async {
    try {
      if (_bookingType == BookingType.package && _packageDateId != null) {
        return await _bookingService.checkPackageAvailability(_packageDateId!, _totalParticipants);
      } else if (_bookingType == BookingType.hotel && _roomId != null && _checkInDate != null && _checkOutDate != null) {
        return await _bookingService.checkRoomAvailability(_roomId!, _roomCount, _checkInDate!, _checkOutDate!);
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Set selected booking
  void setSelectedBooking(BookingModel? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // Clear form data
  void clearFormData() {
    _itemId = '';
    _primaryGuestName = '';
    _primaryGuestEmail = '';
    _primaryGuestPhone = '';
    _totalParticipants = 1;
    _guestDetails.clear();
    _checkInDate = null;
    _checkOutDate = null;
    _departureDate = null;
    _returnDate = null;
    _packageDateId = null;
    _roomId = null;
    _roomCount = 1;
    _basePrice = 0.0;
    _additionalCosts = 0.0;
    _discountAmount = 0.0;
    _taxAmount = 0.0;
    _currency = 'USD';
    _specialRequests = null;
    _dietaryRequirements = null;
    _accessibilityNeeds = null;
    notifyListeners();
  }

  // Create booking with provided data
  Future<BookingModel?> createBookingWithData(Map<String, dynamic> bookingData) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final bookingReference = await _bookingService.generateBookingReference();
      
      final booking = BookingModel(
        id: '',
        userId: user.id,
        bookingType: BookingType.package,
        itemId: bookingData['packageId'],
        bookingReference: bookingReference,
        primaryGuestName: bookingData['customerName'],
        primaryGuestEmail: bookingData['customerEmail'],
        primaryGuestPhone: bookingData['customerPhone'],
        totalParticipants: bookingData['numberOfPeople'],
        guestDetails: null,
        checkInDate: null,
        checkOutDate: null,
        departureDate: DateTime.parse(bookingData['travelDate']),
        returnDate: null,
        packageDateId: null,
        roomId: null,
        roomCount: 1,
        basePrice: bookingData['totalAmount'],
        additionalCosts: 0.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        totalAmount: bookingData['totalAmount'],
        currency: bookingData['currency'],
        bookingStatus: BookingStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: null,
        paymentReference: null,
        specialRequests: bookingData['specialRequests'],
        dietaryRequirements: null,
        accessibilityNeeds: null,
        bookingSource: 'mobile_app',
        bookingNotes: null,
        cancelledAt: null,
        cancellationReason: null,
        cancelledBy: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentBooking = await _bookingService.createBooking(booking);
      
      _setLoading(false);
      return _currentBooking;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
  
  // New methods for booking system with bKash
  
  /// Load all bookings for current user
  Future<void> loadBookings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _userBookings = await _bookingService.getUserBookings(user.id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get upcoming package bookings
  List<BookingModel> get upcomingPackageBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => 
            b.bookingType == BookingType.package &&
            b.departureDate != null &&
            b.departureDate!.isAfter(now) &&
            b.bookingStatus != BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => a.departureDate!.compareTo(b.departureDate!));
  }
  
  /// Get upcoming hotel bookings
  List<BookingModel> get upcomingHotelBookings {
    final now = DateTime.now();
    return _userBookings
        .where((b) => 
            b.bookingType == BookingType.hotel &&
            b.checkInDate != null &&
            b.checkInDate!.isAfter(now) &&
            b.bookingStatus != BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => a.checkInDate!.compareTo(b.checkInDate!));
  }
  
  /// Get past bookings
  List<BookingModel> get pastBookings {
    final now = DateTime.now();
    return _userBookings.where((b) {
      if (b.bookingType == BookingType.package && b.departureDate != null) {
        return b.departureDate!.isBefore(now);
      } else if (b.bookingType == BookingType.hotel && b.checkOutDate != null) {
        return b.checkOutDate!.isBefore(now);
      }
      return false;
    }).toList()
      ..sort((a, b) {
        final dateA = a.bookingType == BookingType.package ? a.departureDate : a.checkOutDate;
        final dateB = b.bookingType == BookingType.package ? b.departureDate : b.checkOutDate;
        return dateB!.compareTo(dateA!);
      });
  }
  
  /// Create package booking with bKash payment
  Future<Map<String, dynamic>?> createPackageBooking({
    required String packageId,
    String? packageDateId, // Optional - only if booking specific package date
    required String primaryGuestName,
    required String primaryGuestEmail,
    required String primaryGuestPhone,
    required int totalParticipants,
    required DateTime departureDate,
    DateTime? returnDate,
    required double basePrice,
    required String currency,
    List<GuestDetail>? guestDetails,
    String? specialRequests,
    String? dietaryRequirements,
    String? accessibilityNeeds,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _bookingService.createBookingWithPayment(
        bookingType: 'package',
        itemId: packageId,
        primaryGuestName: primaryGuestName,
        primaryGuestEmail: primaryGuestEmail,
        primaryGuestPhone: primaryGuestPhone,
        totalParticipants: totalParticipants,
        totalAmountUSD: basePrice,
        additionalData: {
          'departure_date': departureDate.toIso8601String(),
          if (returnDate != null) 'return_date': returnDate.toIso8601String(),
          if (packageDateId != null) 'package_date_id': packageDateId, // Only include if provided
          if (guestDetails != null) 'guest_details': guestDetails.map((g) => g.toMap()).toList(),
          if (specialRequests != null) 'special_requests': specialRequests,
          if (dietaryRequirements != null) 'dietary_requirements': dietaryRequirements,
          if (accessibilityNeeds != null) 'accessibility_needs': accessibilityNeeds,
        },
      );
      
      // Store payment info for later execution
      _pendingPaymentId = result['paymentID'];
      _pendingIdToken = result['idToken'];
      _pendingBookingId = result['booking'].id;
      
      _currentBooking = result['booking'];
      notifyListeners();
      
      _setLoading(false);
      // Return result - caller will navigate to WebView
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }
  
  /// Create hotel booking with bKash payment
  Future<Map<String, dynamic>?> createHotelBooking({
    required String hotelId,
    required String roomId,
    required String primaryGuestName,
    required String primaryGuestEmail,
    required String primaryGuestPhone,
    required int totalParticipants,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int roomCount,
    required double basePrice,
    required String currency,
    List<GuestDetail>? guestDetails,
    String? specialRequests,
    String? accessibilityNeeds,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _bookingService.createBookingWithPayment(
        bookingType: 'hotel',
        itemId: hotelId,
        primaryGuestName: primaryGuestName,
        primaryGuestEmail: primaryGuestEmail,
        primaryGuestPhone: primaryGuestPhone,
        totalParticipants: totalParticipants,
        totalAmountUSD: basePrice,
        additionalData: {
          'check_in_date': checkInDate.toIso8601String(),
          'check_out_date': checkOutDate.toIso8601String(),
          'room_id': roomId,
          'room_count': roomCount,
          if (guestDetails != null) 'guest_details': guestDetails.map((g) => g.toMap()).toList(),
          if (specialRequests != null) 'special_requests': specialRequests,
          if (accessibilityNeeds != null) 'accessibility_needs': accessibilityNeeds,
        },
      );
      
      // Store payment info for later execution
      _pendingPaymentId = result['paymentID'];
      _pendingIdToken = result['idToken'];
      _pendingBookingId = result['booking'].id;
      
      _currentBooking = result['booking'];
      notifyListeners();
      
      _setLoading(false);
      // Return result - caller will navigate to WebView
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }
  
  /// Execute payment after user completes bKash checkout
  Future<bool> executePayment({
    String? paymentId,
    String? idToken,
    String? bookingId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Use provided values or fall back to stored values
      final pId = paymentId ?? _pendingPaymentId;
      final token = idToken ?? _pendingIdToken;
      final bId = bookingId ?? _pendingBookingId;
      
      if (pId == null || token == null || bId == null) {
        _setError('Missing payment information');
        return false;
      }
      
      final result = await _bookingService.executeBookingPayment(
        paymentID: pId,
        idToken: token,
        bookingId: bId,
      );
      
      if (result['success'] != true) {
        _setError('Payment execution failed');
        return false;
      }
      
      // Clear pending payment info
      _pendingPaymentId = null;
      _pendingIdToken = null;
      _pendingBookingId = null;
      
      // Reload bookings to refresh list with updated booking
      await loadBookings();
      
      // Update current booking from the refreshed list
      _currentBooking = _userBookings.firstWhere(
        (b) => b.id == bId,
        orElse: () => _currentBooking!,
      );
      
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}