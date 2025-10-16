import 'package:gotravel/data/models/place_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class PlaceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all active places
  Future<List<PlaceModel>> fetchActivePlaces() async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .order('popular_ranking', ascending: false);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch places: $e');
    }
  }

  /// Fetch featured places
  Future<List<PlaceModel>> fetchFeaturedPlaces({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('popular_ranking', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured places: $e');
    }
  }

  /// Fetch popular places
  Future<List<PlaceModel>> fetchPopularPlaces({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .order('visit_count', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular places: $e');
    }
  }

  /// Fetch places by category
  Future<List<PlaceModel>> fetchPlacesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .eq('category', category)
          .order('rating', ascending: false);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch places by category: $e');
    }
  }

  /// Fetch places by country
  Future<List<PlaceModel>> fetchPlacesByCountry(String country) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .eq('country', country)
          .order('popular_ranking', ascending: false);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch places by country: $e');
    }
  }

  /// Search places by text
  Future<List<PlaceModel>> searchPlaces(String query, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('is_active', true)
          .textSearch('name,description,country,city', query)
          .order('rating', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }

  /// Fetch place by ID
  Future<PlaceModel?> fetchPlaceById(String id) async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return PlaceModel.fromMap(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch place: $e');
    }
  }

  /// Get place categories
  Future<List<String>> getPlaceCategories() async {
    try {
      final response = await _supabase
          .from('places')
          .select('category')
          .eq('is_active', true)
          .not('category', 'is', null);

      final List data = response;
      final categories = data
          .map((item) => item['category'] as String)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch place categories: $e');
    }
  }

  /// Get place countries
  Future<List<String>> getPlaceCountries() async {
    try {
      final response = await _supabase
          .from('places')
          .select('country')
          .eq('is_active', true);

      final List data = response;
      final countries = data
          .map((item) => item['country'] as String)
          .where((country) => country.isNotEmpty)
          .toSet()
          .toList();
      
      countries.sort();
      return countries;
    } catch (e) {
      throw Exception('Failed to fetch place countries: $e');
    }
  }

  /// Increment visit count for a place
  Future<void> incrementVisitCount(String placeId) async {
    try {
      await _supabase.rpc('increment_place_visit_count', params: {'place_id': placeId});
    } catch (e) {
      // Don't throw error for visit count increment failure
      print('Failed to increment visit count: $e');
    }
  }

  /// Filter places with advanced search
  Future<List<PlaceModel>> filterPlaces({
    String? query,
    String? country,
    String? category,
    double? minRating,
    List<String>? activities,
    String sortBy = 'popular_ranking',
    bool ascending = false,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('places')
          .select('*')
          .eq('is_active', true);

      // Apply filters
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.textSearch('name,description,country,city', query);
      }

      if (country != null && country.isNotEmpty) {
        queryBuilder = queryBuilder.eq('country', country);
      }

      if (category != null && category.isNotEmpty) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      if (minRating != null) {
        queryBuilder = queryBuilder.gte('rating', minRating);
      }

      if (activities != null && activities.isNotEmpty) {
        queryBuilder = queryBuilder.overlaps('activities', activities);
      }

      // Apply sorting and limit
      final response = await queryBuilder
          .order(sortBy, ascending: ascending)
          .limit(limit);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to filter places: $e');
    }
  }

  // Admin methods for managing places

  /// Fetch all places for admin (including inactive)
  Future<List<PlaceModel>> getAllPlaces() async {
    try {
      final response = await _supabase
          .from('places')
          .select('*')
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((place) => PlaceModel.fromMap(place)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all places: $e');
    }
  }

  /// Add a new place
  Future<PlaceModel> addPlace(PlaceModel place) async {
    try {
      final response = await _supabase
          .from('places')
          .insert(place.toMap())
          .select()
          .single();

      return PlaceModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add place: $e');
    }
  }

  /// Update an existing place
  Future<PlaceModel> updatePlace(PlaceModel place) async {
    try {
      final response = await _supabase
          .from('places')
          .update(place.toMap())
          .eq('id', place.id)
          .select()
          .single();

      return PlaceModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update place: $e');
    }
  }

  /// Delete a place
  Future<void> deletePlace(String placeId) async {
    try {
      await _supabase
          .from('places')
          .delete()
          .eq('id', placeId);
    } catch (e) {
      throw Exception('Failed to delete place: $e');
    }
  }

  /// Toggle place active status
  Future<PlaceModel> togglePlaceStatus(String placeId, bool isActive) async {
    try {
      final response = await _supabase
          .from('places')
          .update({'is_active': isActive})
          .eq('id', placeId)
          .select()
          .single();

      return PlaceModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to toggle place status: $e');
    }
  }

  /// Toggle place featured status
  Future<PlaceModel> toggleFeaturedStatus(String placeId, bool isFeatured) async {
    try {
      final response = await _supabase
          .from('places')
          .update({'is_featured': isFeatured})
          .eq('id', placeId)
          .select()
          .single();

      return PlaceModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to toggle featured status: $e');
    }
  }

  /// Upload image to Supabase storage
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      // Add timestamp to filename to avoid conflicts
      final timestampedFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage
          .from('cdn')
          .upload(timestampedFileName, File(filePath));

      final publicUrl = _supabase.storage.from('cdn').getPublicUrl(timestampedFileName);
      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }
}