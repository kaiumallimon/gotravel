import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPackagesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch active packages only (for regular users)
  Future<List<TourPackage>> fetchActivePackages() async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to fetch packages: $e');
    }
  }

  /// Fetch packages by category
  Future<List<TourPackage>> fetchPackagesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('is_active', true)
          .eq('category', category)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to fetch packages by category: $e');
    }
  }

  /// Fetch packages by country
  Future<List<TourPackage>> fetchPackagesByCountry(String country) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('is_active', true)
          .eq('country', country)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to fetch packages by country: $e');
    }
  }

  /// Get unique countries from packages
  Future<List<String>> getAvailableCountries() async {
    try {
      final response = await _supabase
          .from('packages')
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
      throw Exception('Failed to fetch countries: $e');
    }
  }

  /// Get unique categories from packages
  Future<List<String>> getAvailableCategories() async {
    try {
      final response = await _supabase
          .from('packages')
          .select('category')
          .eq('is_active', true);

      final List data = response;
      final categories = data
          .map((item) => item['category'] as String)
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get recommended packages (from admin recommendations)
  Future<List<TourPackage>> getRecommendedPackages({int limit = 10}) async {
    try {
      // First get the recommended package IDs
      final recommendedResponse = await _supabase
          .from('recommendations')
          .select('item_id')
          .eq('item_type', 'package')
          .limit(limit);

      if (recommendedResponse.isEmpty) {
        return [];
      }

      // Extract package IDs
      final packageIds = recommendedResponse
          .map((item) => item['item_id'] as String)
          .toList();

      // Then fetch the actual package data with related tables
      final packagesResponse = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .inFilter('id', packageIds)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List data = packagesResponse;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommended packages: $e');
    }
  }

  /// Search packages by name, destination, or description
  Future<List<TourPackage>> searchPackages(String query) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('is_active', true)
          .or('name.ilike.%$query%,destination.ilike.%$query%,description.ilike.%$query%')
          .order('rating', ascending: false);

      final List data = response;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to search packages: $e');
    }
  }

  /// Get package by ID
  Future<TourPackage> getPackageById(String packageId) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('id', packageId)
          .eq('is_active', true)
          .single();

      return TourPackage.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch package details: $e');
    }
  }

  /// Fetch packages by place_id
  Future<List<TourPackage>> fetchPackagesByPlace(String placeId) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('place_id', placeId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((package) => TourPackage.fromMap(package)).toList();
    } catch (e) {
      throw Exception('Failed to fetch packages by place: $e');
    }
  }
}