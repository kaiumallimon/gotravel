import 'package:gotravel/data/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _supabase
          .from('bookings')
          .insert(booking.toMap())
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Update booking
  Future<BookingModel> updateBooking(BookingModel booking) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update(booking.toMap())
          .eq('id', booking.id)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  /// Get user bookings
  Future<List<BookingModel>> getUserBookings(String userId, {
    BookingStatus? status,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('bookings')
          .select('*')
          .eq('user_id', userId);

      if (status != null) {
        queryBuilder = queryBuilder.eq('booking_status', status.value);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((booking) => BookingModel.fromMap(booking)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  /// Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch booking: $e');
    }
  }

  /// Get booking by reference
  Future<BookingModel?> getBookingByReference(String reference) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('booking_reference', reference)
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch booking: $e');
    }
  }

  /// Cancel booking
  Future<BookingModel> cancelBooking(String bookingId, String reason, String cancelledBy) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update({
        'booking_status': BookingStatus.cancelled.value,
        'cancelled_at': DateTime.now().toIso8601String(),
        'cancellation_reason': reason,
        'cancelled_by': cancelledBy,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  /// Confirm booking (update status to confirmed)
  Future<BookingModel> confirmBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update({
        'booking_status': BookingStatus.confirmed.value,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  /// Complete booking (update status to completed)
  Future<BookingModel> completeBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update({
        'booking_status': BookingStatus.completed.value,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  /// Update payment status
  Future<BookingModel> updatePaymentStatus(String bookingId, PaymentStatus status, {
    String? paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final updateData = {
        'payment_status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (paymentMethod != null) {
        updateData['payment_method'] = paymentMethod;
      }

      if (paymentReference != null) {
        updateData['payment_reference'] = paymentReference;
      }

      final response = await _supabase
          .from('bookings')
          .update(updateData)
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get bookings by item (package or hotel)
  Future<List<BookingModel>> getBookingsByItem(String itemId, BookingType type) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*')
          .eq('item_id', itemId)
          .eq('booking_type', type.value)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((booking) => BookingModel.fromMap(booking)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings by item: $e');
    }
  }

  /// Generate unique booking reference
  Future<String> generateBookingReference() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'BK$timestamp$random';
  }

  /// Check booking availability for package dates
  Future<bool> checkPackageAvailability(String packageDateId, int participants) async {
    try {
      final response = await _supabase
          .from('package_dates')
          .select('available_slots')
          .eq('id', packageDateId)
          .single();

      final availableSlots = response['available_slots'] as int;
      return availableSlots >= participants;
    } catch (e) {
      throw Exception('Failed to check package availability: $e');
    }
  }

  /// Check room availability
  Future<bool> checkRoomAvailability(String roomId, int roomCount, DateTime checkIn, DateTime checkOut) async {
    try {
      // Get total available rooms
      final roomResponse = await _supabase
          .from('rooms')
          .select('available_count')
          .eq('id', roomId)
          .single();

      final totalRooms = roomResponse['available_count'] as int;

      // Get booked rooms for the date range
      final bookingResponse = await _supabase
          .from('bookings')
          .select('room_count')
          .eq('room_id', roomId)
          .eq('booking_type', 'hotel')
          .neq('booking_status', 'cancelled')
          .gte('check_in_date', checkIn.toIso8601String().split('T')[0])
          .lte('check_out_date', checkOut.toIso8601String().split('T')[0]);

      final List bookings = bookingResponse;
      final bookedRooms = bookings.fold<int>(0, (sum, booking) => sum + (booking['room_count'] as int));

      return (totalRooms - bookedRooms) >= roomCount;
    } catch (e) {
      throw Exception('Failed to check room availability: $e');
    }
  }

  /// Get booking statistics for admin
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final response = await _supabase.rpc('get_booking_statistics');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      // If the function doesn't exist, calculate manually
      try {
        final allBookings = await _supabase.from('bookings').select('booking_status, payment_status, total_amount');
        final List data = allBookings;

        int totalBookings = data.length;
        int pendingBookings = data.where((b) => b['booking_status'] == 'pending').length;
        int confirmedBookings = data.where((b) => b['booking_status'] == 'confirmed').length;
        int cancelledBookings = data.where((b) => b['booking_status'] == 'cancelled').length;
        int completedBookings = data.where((b) => b['booking_status'] == 'completed').length;

        double totalRevenue = data
            .where((b) => b['payment_status'] == 'paid')
            .fold(0.0, (sum, b) => sum + (b['total_amount'] as num).toDouble());

        return {
          'total_bookings': totalBookings,
          'pending_bookings': pendingBookings,
          'confirmed_bookings': confirmedBookings,
          'cancelled_bookings': cancelledBookings,
          'completed_bookings': completedBookings,
          'total_revenue': totalRevenue,
        };
      } catch (e2) {
        throw Exception('Failed to get booking statistics: $e2');
      }
    }
  }
}