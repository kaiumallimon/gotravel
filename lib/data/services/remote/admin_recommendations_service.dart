import 'dart:developer';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRecommendationsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all recommended packages
  Future<List<TourPackage>> getRecommendedPackages() async {
    try {
      // Step 1: Get recommended package IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'package');

      if (recommendedResponse.isEmpty) {
        return [];
      }

      final packageIds = recommendedResponse
          .map((item) => item['item_id'] as String)
          .toList();

      // Step 2: Fetch package data
      final packagesResponse = await _supabase
          .from('packages')
          .select('*, package_activities(*), package_dates(*)')
          .inFilter('id', packageIds)
          .order('created_at', ascending: false);

      final List data = packagesResponse;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      log('Error fetching recommended packages: $e');
      throw Exception('Failed to fetch recommended packages: $e');
    }
  }

  // Get all recommended hotels
  Future<List<Hotel>> getRecommendedHotels() async {
    try {
      // Step 1: Get recommended hotel IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'hotel');

      if (recommendedResponse.isEmpty) {
        return [];
      }

      final hotelIds = recommendedResponse
          .map((item) => item['item_id'] as String)
          .toList();

      // Step 2: Fetch hotel data
      final hotelsResponse = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .inFilter('id', hotelIds)
          .order('created_at', ascending: false);

      final List data = hotelsResponse;
      return data.map((hotel) => Hotel.fromMap(hotel)).toList();
    } catch (e) {
      log('Error fetching recommended hotels: $e');
      throw Exception('Failed to fetch recommended hotels: $e');
    }
  }

  // Get all packages with recommendation status
  Future<List<Map<String, dynamic>>> getAllPackagesWithStatus() async {
    try {
      // Step 1: Get all recommended package IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'package');
      final recommendedIds = recommendedResponse.map((item) => item['item_id'] as String).toSet();

      // Step 2: Get all packages
      final packagesResponse = await _supabase
          .from('packages')
          .select('*, package_activities(*), package_dates(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return packagesResponse.map((item) {
        final package = TourPackage.fromMap(item);
        final isRecommended = recommendedIds.contains(package.id);
        return {
          'package': package,
          'isRecommended': isRecommended,
          'recommendationId': isRecommended ? package.id : null,
        };
      }).toList();
    } catch (e) {
      log('Error fetching packages with status: $e');
      throw Exception('Failed to fetch packages with status: $e');
    }
  }

  // Get all hotels with recommendation status
  Future<List<Map<String, dynamic>>> getAllHotelsWithStatus() async {
    try {
      // Step 1: Get all recommended hotel IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'hotel');
      final recommendedIds = recommendedResponse.map((item) => item['item_id'] as String).toSet();

      // Step 2: Get all hotels
      final hotelsResponse = await _supabase
          .from('hotels')
          .select('*, rooms(*)')
          .order('created_at', ascending: false);

      return hotelsResponse.map((item) {
        final hotel = Hotel.fromMap(item);
        final isRecommended = recommendedIds.contains(hotel.id);
        return {
          'hotel': hotel,
          'isRecommended': isRecommended,
          'recommendationId': isRecommended ? hotel.id : null,
        };
      }).toList();
    } catch (e) {
      log('Error fetching hotels with status: $e');
      throw Exception('Failed to fetch hotels with status: $e');
    }
  }

  // Add package to recommendations
  Future<void> addPackageRecommendation(String packageId) async {
    try {
      await _supabase.from('recommendations').insert({
        'item_type': 'package',
        'item_id': packageId,
        'created_by': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      log('Error adding package recommendation: $e');
      throw Exception('Failed to add package recommendation: $e');
    }
  }

  // Add hotel to recommendations
  Future<void> addHotelRecommendation(String hotelId) async {
    try {
      await _supabase.from('recommendations').insert({
        'item_type': 'hotel',
        'item_id': hotelId,
        'created_by': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      log('Error adding hotel recommendation: $e');
      throw Exception('Failed to add hotel recommendation: $e');
    }
  }

  // Remove package from recommendations
  Future<void> removePackageRecommendation(String packageId) async {
    try {
      await _supabase
          .from('recommendations')
          .delete()
          .eq('item_type', 'package')
          .eq('item_id', packageId);
    } catch (e) {
      log('Error removing package recommendation: $e');
      throw Exception('Failed to remove package recommendation: $e');
    }
  }

  // Remove hotel from recommendations
  Future<void> removeHotelRecommendation(String hotelId) async {
    try {
      await _supabase
          .from('recommendations')
          .delete()
          .eq('item_type', 'hotel')
          .eq('item_id', hotelId);
    } catch (e) {
      log('Error removing hotel recommendation: $e');
      throw Exception('Failed to remove hotel recommendation: $e');
    }
  }

  // Get recommendation statistics
  Future<Map<String, int>> getRecommendationStats() async {
    try {
      final response = await _supabase
          .from('recommendations')
          .select('item_type');

      final stats = <String, int>{
        'packages': 0,
        'hotels': 0,
        'total': 0,
      };

      for (final item in response) {
        final type = item['item_type'] as String;
        if (type == 'package') {
          stats['packages'] = (stats['packages'] ?? 0) + 1;
        } else if (type == 'hotel') {
          stats['hotels'] = (stats['hotels'] ?? 0) + 1;
        }
        stats['total'] = (stats['total'] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      log('Error fetching recommendation stats: $e');
      throw Exception('Failed to fetch recommendation stats: $e');
    }
  }
}