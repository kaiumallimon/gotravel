import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddHotelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user is authenticated and has admin role
  Future<bool> _checkAuthentication() async {
    final user = _supabase.auth.currentUser;
    debugPrint('🔍 Current user: ${user?.id}');
    debugPrint('🔍 User email: ${user?.email}');
    
    if (user == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }
    
    // Optionally check if user has admin role
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

  /// add a new room
  Future<void> addRoom(List<Map<String, dynamic>> roomData, String hotelId) async {
    try {
      await _checkAuthentication();
      
      for (var room in roomData) {
        room['hotel_id'] = hotelId; // Associate room with hotel
        final response = await _supabase.from('rooms').insert(room);
        debugPrint('Room added: $response');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// add a new hotel
  Future<void> addHotel(Map<String, dynamic> hotelData, List<Map<String, dynamic>> roomData) async {
    try {
      await _checkAuthentication();
      
      final hotelResponse = await _supabase.from('hotels').insert(hotelData);
      debugPrint('Hotel added: $hotelResponse');

      // check if id exists in the response
      if (hotelData.containsKey('id') && hotelData['id'] != null) {
        final hotelId = hotelData['id'];

        // If rooms are provided, add them
        if (roomData.isNotEmpty) {
          await addRoom(roomData, hotelId);
        }
      } else {
        debugPrint('Hotel ID not found in the response. Cannot add rooms.');
      }
    } catch (error) {
      rethrow;
    }
  }


  // upload image to supabase storage and return the public url
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

  /// Test method to check if we can read from hotels table
  Future<void> testDatabaseAccess() async {
    try {
      debugPrint('🔍 Testing database access...');
      
      // Test if we can read from hotels table
      final result = await _supabase
          .from('hotels')
          .select('count')
          .limit(1);
      
      debugPrint('✅ Can read from hotels table: $result');
      
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

  /// Simplified method to add hotel without authentication check (for debugging)
  Future<void> addHotelWithoutRLS(Map<String, dynamic> hotelData, List<Map<String, dynamic>> roomData) async {
    try {
      debugPrint('🔍 Attempting to add hotel without RLS check...');
      debugPrint('🔍 Hotel data: $hotelData');
      
      final hotelResponse = await _supabase.from('hotels').insert(hotelData);
      debugPrint('✅ Hotel added successfully: $hotelResponse');

      // check if id exists in the response
      if (hotelData.containsKey('id') && hotelData['id'] != null) {
        final hotelId = hotelData['id'];

        // If rooms are provided, add them
        if (roomData.isNotEmpty) {
          debugPrint('🔍 Adding ${roomData.length} rooms...');
          for (var room in roomData) {
            room['hotel_id'] = hotelId;
            final roomResponse = await _supabase.from('rooms').insert(room);
            debugPrint('✅ Room added: $roomResponse');
          }
        }
      } else {
        debugPrint('❌ Hotel ID not found in the response. Cannot add rooms.');
      }
    } catch (error) {
      debugPrint('❌ Error in addHotelWithoutRLS: $error');
      rethrow;
    }
  }
}
