import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/models/package_activity_model.dart';
import 'package:gotravel/data/models/package_date_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPackageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all packages with their related activities and dates
  Future<List<TourPackage>> fetchPackages() async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .order('created_at', ascending: false);

      final List data = response;

      // Convert response into List<TourPackage>
      final packages = data
          .map((package) => TourPackage.fromMap(package))
          .toList();

      print("Fetched packages: ${packages.first.toMap()}");

      return packages;
    } catch (e) {
      throw Exception('Failed to fetch packages: $e');
    }
  }

  /// Fetch a single package by its ID (with activities and dates)
  Future<TourPackage?> fetchPackageById(String packageId) async {
    try {
      final response = await _supabase
          .from('packages')
          .select('''
            *, 
            package_activities(*),
            package_dates(*)
          ''')
          .eq('id', packageId)
          .maybeSingle();

      if (response == null) return null;

      return TourPackage.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch package: $e');
    }
  }

  /// Fetch activities for a specific package
  Future<List<PackageActivity>> fetchActivitiesByPackageId(
    String packageId,
  ) async {
    try {
      final response = await _supabase
          .from('package_activities')
          .select()
          .eq('package_id', packageId)
          .order('day_number', ascending: true);

      final List data = response;

      return data.map((activity) => PackageActivity.fromMap(activity)).toList();
    } catch (e) {
      throw Exception('Failed to fetch activities: $e');
    }
  }

  /// Fetch dates for a specific package
  Future<List<PackageDate>> fetchDatesByPackageId(String packageId) async {
    try {
      final response = await _supabase
          .from('package_dates')
          .select()
          .eq('package_id', packageId)
          .order('departure_date', ascending: true);

      final List data = response;

      return data.map((date) => PackageDate.fromMap(date)).toList();
    } catch (e) {
      throw Exception('Failed to fetch package dates: $e');
    }
  }

  /// Delete a package (this will cascade delete activities and dates)
  Future<void> deletePackage(String packageId) async {
    try {
      await _supabase.from('packages').delete().eq('id', packageId);
    } catch (e) {
      throw Exception('Failed to delete package: $e');
    }
  }

  /// Update package status (active/inactive)
  Future<void> updatePackageStatus(String packageId, bool isActive) async {
    try {
      await _supabase
          .from('packages')
          .update({'is_active': isActive})
          .eq('id', packageId);
    } catch (e) {
      throw Exception('Failed to update package status: $e');
    }
  }
}
