import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHotelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all hotels with their related rooms
  Future<List<Hotel>> fetchHotels() async {
    try {
      // ✅ Supabase can perform a relational join
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)') // fetch rooms from the related table
          .order('created_at', ascending: false);

      final List data = response;

      // Convert response into List<Hotel>
      final hotels = data.map((hotel) => Hotel.fromMap(hotel)).toList();

      return hotels;
    } catch (e) {
      throw Exception('Failed to fetch hotels: $e');
    }
  }

  /// Fetch a single hotel by its ID (with its rooms)
  Future<Hotel?> fetchHotelById(String hotelId) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .eq('id', hotelId)
          .maybeSingle();

      if (response == null) return null;

      return Hotel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch hotel: $e');
    }
  }

  /// Fetch rooms for a specific hotel
  Future<List<Room>> fetchRoomsByHotelId(String hotelId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('hotel_id', hotelId)
          .order('created_at', ascending: false);

      final List data = response;

      return data.map((room) => Room.fromMap(room)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  /// Delete a hotel and its associated rooms
  Future<void> deleteHotel(String hotelId) async {
    try {
      // First delete all rooms associated with this hotel
      await _supabase
          .from('rooms')
          .delete()
          .eq('hotel_id', hotelId);

      // Then delete the hotel
      await _supabase
          .from('hotels')
          .delete()
          .eq('id', hotelId);
    } catch (e) {
      throw Exception('Failed to delete hotel: $e');
    }
  }
}
