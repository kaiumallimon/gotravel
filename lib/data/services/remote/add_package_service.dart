import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPackageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user is authenticated and has admin role
  Future<bool> _checkAuthentication() async {
    final user = _supabase.auth.currentUser;
    debugPrint('🔍 Current user: ${user?.id}');
    debugPrint('🔍 User email: ${user?.email}');
    
    if (user == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }
    
    // Check if user has admin role
    try {
      debugPrint('🔍 Checking user role for ID: ${user.id}');
      final userData = await _supabase
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();
      
      debugPrint('🔍 User data from DB: $userData');
      
      if (userData['role'] != 'admin') {
        throw Exception('Unauthorized. Current role: ${userData['role']}, Admin access required.');
      }
      
      debugPrint('✅ Authentication successful - Admin user confirmed');
    } catch (e) {
      debugPrint('❌ Authentication check failed: $e');
      throw Exception('Failed to verify user permissions: $e');
    }
    
    return true;
  }

  /// Debug method to check current auth status
  Future<Map<String, dynamic>> getCurrentAuthStatus() async {
    final user = _supabase.auth.currentUser;
    
    if (user == null) {
      return {
        'isAuthenticated': false,
        'user': null,
        'userData': null,
      };
    }
    
    try {
      final userData = await _supabase
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();
      
      return {
        'isAuthenticated': true,
        'user': {
          'id': user.id,
          'email': user.email,
        },
        'userData': userData,
      };
    } catch (e) {
      return {
        'isAuthenticated': true,
        'user': {
          'id': user.id,
          'email': user.email,
        },
        'userData': null,
        'error': e.toString(),
      };
    }
  }

  /// Add package activities
  Future<void> addActivities(List<Map<String, dynamic>> activitiesData, String packageId) async {
    try {
      await _checkAuthentication();
      
      debugPrint('🔍 Adding ${activitiesData.length} activities for package: $packageId');
      
      for (int i = 0; i < activitiesData.length; i++) {
        var activity = Map<String, dynamic>.from(activitiesData[i]);
        activity['package_id'] = packageId;
        
        debugPrint('🔍 Activity ${i + 1} data before insertion: $activity');
        
        try {
          final response = await _supabase.from('package_activities').insert(activity);
          debugPrint('✅ Activity ${i + 1} added successfully: $response');
        } catch (activityError) {
          debugPrint('❌ Failed to add activity ${i + 1}: $activityError');
          debugPrint('❌ Activity data that failed: $activity');
          throw Exception('Failed to add activity ${i + 1}: $activityError');
        }
      }
      
      debugPrint('✅ All activities added successfully');
    } catch (error) {
      debugPrint('❌ addActivities failed: $error');
      rethrow;
    }
  }

  /// Add package dates
  Future<void> addPackageDates(List<Map<String, dynamic>> datesData, String packageId) async {
    try {
      await _checkAuthentication();
      
      debugPrint('🔍 Adding ${datesData.length} dates for package: $packageId');
      
      for (int i = 0; i < datesData.length; i++) {
        var date = Map<String, dynamic>.from(datesData[i]);
        date['package_id'] = packageId;
        
        debugPrint('🔍 Date ${i + 1} data before insertion: $date');
        
        try {
          final response = await _supabase.from('package_dates').insert(date);
          debugPrint('✅ Date ${i + 1} added successfully: $response');
        } catch (dateError) {
          debugPrint('❌ Failed to add date ${i + 1}: $dateError');
          debugPrint('❌ Date data that failed: $date');
          throw Exception('Failed to add date ${i + 1}: $dateError');
        }
      }
      
      debugPrint('✅ All dates added successfully');
    } catch (error) {
      debugPrint('❌ addPackageDates failed: $error');
      rethrow;
    }
  }

  /// Add a new package
  Future<void> addPackage(
    Map<String, dynamic> packageData, 
    List<Map<String, dynamic>> activitiesData,
    List<Map<String, dynamic>> datesData
  ) async {
    try {
      await _checkAuthentication();
      
      debugPrint('🔍 Package data before insertion: $packageData');
      
      // Insert package and return the inserted data to get the ID
      final packageResponse = await _supabase
          .from('packages')
          .insert(packageData)
          .select('id');
      
      debugPrint('✅ Package added successfully: $packageResponse');

      // Get package ID from response
      String? packageId;
      
      if (packageResponse.isNotEmpty && packageResponse[0]['id'] != null) {
        packageId = packageResponse[0]['id'];
        debugPrint('🔍 Package ID from response: $packageId');
      } else if (packageData.containsKey('id') && packageData['id'] != null) {
        packageId = packageData['id'];
        debugPrint('🔍 Package ID from data: $packageId');
      }

      if (packageId != null) {
        // Add activities if any
        if (activitiesData.isNotEmpty) {
          debugPrint('🔍 Starting activities insertion for package: $packageId');
          await addActivities(activitiesData, packageId);
        }

        // Add dates if any
        if (datesData.isNotEmpty) {
          debugPrint('🔍 Starting dates insertion for package: $packageId');
          await addPackageDates(datesData, packageId);
        }
      } else if (activitiesData.isNotEmpty || datesData.isNotEmpty) {
        debugPrint('❌ Cannot add activities/dates - package ID not found');
        throw Exception('Package ID not found after insertion. Cannot add activities/dates.');
      } else {
        debugPrint('✅ Package added successfully - no activities/dates to add');
      }
    } catch (error) {
      debugPrint('❌ addPackage failed: $error');
      rethrow;
    }
  }

  // Upload image to supabase storage and return the public url
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      await _checkAuthentication();
      
      debugPrint('🔍 Attempting to upload image: $fileName');
      debugPrint('🔍 File path: $filePath');
      
      // Add timestamp to filename to avoid conflicts
      final timestampedFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage
          .from('cdn')
          .upload(timestampedFileName, File(filePath));

      final publicUrl = _supabase.storage.from('cdn').getPublicUrl(timestampedFileName);
      debugPrint('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (error) {
      debugPrint('❌ Image upload failed: $error');
      rethrow;
    }
  }

  /// Test method to check if we can read from packages table
  Future<void> testDatabaseAccess() async {
    try {
      debugPrint('🔍 Testing database access...');
      
      // Test if we can read from packages table
      final result = await _supabase
          .from('packages')
          .select('count')
          .limit(1);
      
      debugPrint('✅ Can read from packages table: $result');
      
      // Test authentication
      await _checkAuthentication();
      
    } catch (error) {
      debugPrint('❌ Database access test failed: $error');
      rethrow;
    }
  }

  /// Test storage access
  Future<void> testStorageAccess() async {
    try {
      debugPrint('🔍 Testing storage access...');
      
      // Try to list files in cdn bucket
      final result = await _supabase.storage
          .from('cdn')
          .list();
      
      debugPrint('✅ Can access storage bucket. Files: ${result.length}');
      
    } catch (error) {
      debugPrint('❌ Storage access test failed: $error');
      rethrow;
    }
  }

  /// Simplified method to add package without authentication check (for debugging)
  Future<void> addPackageWithoutRLS(
    Map<String, dynamic> packageData, 
    List<Map<String, dynamic>> activitiesData,
    List<Map<String, dynamic>> datesData
  ) async {
    try {
      debugPrint('🔍 Attempting to add package without RLS check...');
      debugPrint('🔍 Package data: $packageData');
      
      final packageResponse = await _supabase
          .from('packages')
          .insert(packageData)
          .select('id');
      debugPrint('✅ Package added successfully: $packageResponse');

      // Get package ID from response
      String? packageId;
      
      if (packageResponse.isNotEmpty && packageResponse[0]['id'] != null) {
        packageId = packageResponse[0]['id'];
        debugPrint('🔍 Package ID from response: $packageId');
      } else if (packageData.containsKey('id') && packageData['id'] != null) {
        packageId = packageData['id'];
        debugPrint('🔍 Package ID from data: $packageId');
      }

      if (packageId != null) {
        // If activities are provided, add them
        if (activitiesData.isNotEmpty) {
          debugPrint('🔍 Adding ${activitiesData.length} activities...');
          for (int i = 0; i < activitiesData.length; i++) {
            var activity = Map<String, dynamic>.from(activitiesData[i]);
            activity['package_id'] = packageId;
            
            debugPrint('🔍 Activity ${i + 1} data: $activity');
            
            try {
              final activityResponse = await _supabase.from('package_activities').insert(activity);
              debugPrint('✅ Activity ${i + 1} added: $activityResponse');
            } catch (activityError) {
              debugPrint('❌ Failed to add activity ${i + 1}: $activityError');
              throw Exception('Failed to add activity ${i + 1}: $activityError');
            }
          }
        }

        // If dates are provided, add them
        if (datesData.isNotEmpty) {
          debugPrint('🔍 Adding ${datesData.length} dates...');
          for (int i = 0; i < datesData.length; i++) {
            var date = Map<String, dynamic>.from(datesData[i]);
            date['package_id'] = packageId;
            
            debugPrint('🔍 Date ${i + 1} data: $date');
            
            try {
              final dateResponse = await _supabase.from('package_dates').insert(date);
              debugPrint('✅ Date ${i + 1} added: $dateResponse');
            } catch (dateError) {
              debugPrint('❌ Failed to add date ${i + 1}: $dateError');
              throw Exception('Failed to add date ${i + 1}: $dateError');
            }
          }
        }
      } else {
        debugPrint('❌ Package ID not found in the response. Cannot add activities/dates.');
      }
    } catch (error) {
      debugPrint('❌ Error in addPackageWithoutRLS: $error');
      rethrow;
    }
  }
}