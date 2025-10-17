import 'package:gotravel/data/models/hotel_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHotelsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch active hotels only (for regular users)
  Future<List<Hotel>> fetchActiveHotels() async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hotels: $e');
    }
  }

  /// Fetch hotels by city
  Future<List<Hotel>> fetchHotelsByCity(String city) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .eq('city', city)
          .order('rating', ascending: false);

      final List data = response;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hotels by city: $e');
    }
  }

  /// Fetch hotels by country
  Future<List<Hotel>> fetchHotelsByCountry(String country) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .eq('country', country)
          .order('rating', ascending: false);

      final List data = response;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      throw Exception('Failed to fetch hotels by country: $e');
    }
  }

  /// Get unique cities from hotels
  Future<List<String>> getAvailableCities() async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('city');

      final List data = response;
      final cities = data
          .map((item) => item['city'] as String)
          .where((city) => city.isNotEmpty)
          .toSet()
          .toList();
      
      cities.sort();
      return cities;
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  /// Get unique countries from hotels
  Future<List<String>> getAvailableCountries() async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('country');

      final List data = response;
      final countries = data
          .map((item) => item['country'] as String)
          .where((country) => country.isNotEmpty)
          .toSet()
          .toList();
      
      countries.sort();
      return countries;
    } catch (e) {
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Get recommended hotels (from admin recommendations)
  Future<List<Hotel>> getRecommendedHotels({int limit = 10}) async {
    try {
      // First get the recommended hotel IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'hotel')
          .limit(limit);

      if (recommendedResponse.isEmpty) {
        return [];
      }

      // Extract hotel IDs
      final hotelIds = recommendedResponse
          .map((item) => item['item_id'] as String)
          .toList();

      // Then fetch the actual hotel data with rooms
      final hotelsResponse = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .inFilter('id', hotelIds)
          .order('created_at', ascending: false);

      final List data = hotelsResponse;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommended hotels: $e');
    }
  }

  /// Search hotels by name, city, or amenities
  Future<List<Hotel>> searchHotels(String query) async {
    try {
      final response = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .or('name.ilike.%$query%,city.ilike.%$query%,address.ilike.%$query%')
          .order('rating', ascending: false);

      final List data = response;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      throw Exception('Failed to search hotels: $e');
    }
  }
}