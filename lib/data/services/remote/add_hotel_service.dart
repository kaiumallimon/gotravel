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
      
      debugPrint('🔍 Adding ${roomData.length} rooms for hotel: $hotelId');
      
      for (int i = 0; i < roomData.length; i++) {
        var room = Map<String, dynamic>.from(roomData[i]); // Create a copy
        room['hotel_id'] = hotelId; // Associate room with hotel
        
        debugPrint('🔍 Room ${i + 1} data before insertion: $room');
        
        try {
          final response = await _supabase.from('rooms').insert(room);
          debugPrint('✅ Room ${i + 1} added successfully: $response');
        } catch (roomError) {
          debugPrint('❌ Failed to add room ${i + 1}: $roomError');
          debugPrint('❌ Room data that failed: $room');
          throw Exception('Failed to add room ${i + 1}: $roomError');
        }
      }
      
      debugPrint('✅ All rooms added successfully');
    } catch (error) {
      debugPrint('❌ addRoom failed: $error');
      rethrow;
    }
  }

  /// add a new hotel
  Future<void> addHotel(Map<String, dynamic> hotelData, List<Map<String, dynamic>> roomData) async {
    try {
      await _checkAuthentication();
      
      debugPrint('🔍 Hotel data before insertion: $hotelData');
      
      // Insert hotel and return the inserted data to get the ID
      final hotelResponse = await _supabase
          .from('hotels')
          .insert(hotelData)
          .select('id');
      
      debugPrint('✅ Hotel added successfully: $hotelResponse');

      // Get hotel ID from response or from original data
      String? hotelId;
      
      if (hotelResponse.isNotEmpty && hotelResponse[0]['id'] != null) {
        hotelId = hotelResponse[0]['id'];
        debugPrint('🔍 Hotel ID from response: $hotelId');
      } else if (hotelData.containsKey('id') && hotelData['id'] != null) {
        hotelId = hotelData['id'];
        debugPrint('🔍 Hotel ID from data: $hotelId');
      }

      if (hotelId != null && roomData.isNotEmpty) {
        debugPrint('🔍 Starting room insertion for hotel: $hotelId');
        await addRoom(roomData, hotelId);
      } else if (roomData.isNotEmpty) {
        debugPrint('❌ Cannot add rooms - hotel ID not found');
        throw Exception('Hotel ID not found after insertion. Cannot add rooms.');
      } else {
        debugPrint('✅ Hotel added successfully - no rooms to add');
      }
    } catch (error) {
      debugPrint('❌ addHotel failed: $error');
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
      
      final hotelResponse = await _supabase
          .from('hotels')
          .insert(hotelData)
          .select('id');
      debugPrint('✅ Hotel added successfully: $hotelResponse');

      // Get hotel ID from response or from original data
      String? hotelId;
      
      if (hotelResponse.isNotEmpty && hotelResponse[0]['id'] != null) {
        hotelId = hotelResponse[0]['id'];
        debugPrint('🔍 Hotel ID from response: $hotelId');
      } else if (hotelData.containsKey('id') && hotelData['id'] != null) {
        hotelId = hotelData['id'];
        debugPrint('🔍 Hotel ID from data: $hotelId');
      }

      if (hotelId != null) {

        // If rooms are provided, add them
        if (roomData.isNotEmpty) {
          debugPrint('🔍 Adding ${roomData.length} rooms...');
          for (int i = 0; i < roomData.length; i++) {
            var room = Map<String, dynamic>.from(roomData[i]);
            room['hotel_id'] = hotelId;
            
            debugPrint('🔍 Room ${i + 1} data: $room');
            
            try {
              final roomResponse = await _supabase.from('rooms').insert(room);
              debugPrint('✅ Room ${i + 1} added: $roomResponse');
            } catch (roomError) {
              debugPrint('❌ Failed to add room ${i + 1}: $roomError');
              throw Exception('Failed to add room ${i + 1}: $roomError');
            }
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
