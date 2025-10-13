import 'dart:developer';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRecommendationsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all recommended packages
  Future<List<TourPackage>> getRecommendedPackages() async {
    try {
      final response = await _supabase
          .from('recommendations')
          .select('''
            id,
            item_id,
            created_at,
            packages!inner(*)
          ''')
          .eq('item_type', 'package')
          .order('created_at', ascending: false);

      return response
          .map((item) => TourPackage.fromMap(item['packages']))
          .toList();
    } catch (e) {
      log('Error fetching recommended packages: $e');
      throw Exception('Failed to fetch recommended packages: $e');
    }
  }

  // Get all recommended hotels
  Future<List<Hotel>> getRecommendedHotels() async {
    try {
      final response = await _supabase
          .from('recommendations')
          .select('''
            id,
            item_id,
            created_at,
            hotels!inner(*)
          ''')
          .eq('item_type', 'hotel')
          .order('created_at', ascending: false);

      return response
          .map((item) => Hotel.fromMap(item['hotels']))
          .toList();
    } catch (e) {
      log('Error fetching recommended hotels: $e');
      throw Exception('Failed to fetch recommended hotels: $e');
    }
  }

  // Get all packages with recommendation status
  Future<List<Map<String, dynamic>>> getAllPackagesWithStatus() async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *,
            recommendations!left(id)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map((item) {
        final package = TourPackage.fromMap(item);
        final isRecommended = item['recommendations'] != null && 
                             (item['recommendations'] as List).isNotEmpty;
        
        return {
          'package': package,
          'isRecommended': isRecommended,
          'recommendationId': isRecommended 
              ? (item['recommendations'] as List).first['id'] 
              : null,
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
      final response = await _supabase
          .from('hotels')
          .select('''
            *,
            recommendations!left(id)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map((item) {
        final hotel = Hotel.fromMap(item);
        final isRecommended = item['recommendations'] != null && 
                             (item['recommendations'] as List).isNotEmpty;
        
        return {
          'hotel': hotel,
          'isRecommended': isRecommended,
          'recommendationId': isRecommended 
              ? (item['recommendations'] as List).first['id'] 
              : null,
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