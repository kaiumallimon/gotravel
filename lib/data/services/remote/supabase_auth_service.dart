import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with email & password
  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign up with email, password, and full name
  /// Also inserts into `public.users` table
  Future<AuthResponse?> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // 1. Create the user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // 2. Insert into `public.users` table
        await _supabase.from('users').insert({
          'id': userId,
          'email': email,
          'role': 'user', // default role
          // Extra field example:
          'full_name': fullName,
        });
      }
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
}
