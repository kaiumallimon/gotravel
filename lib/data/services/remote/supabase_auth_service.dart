import 'package:flutter/widgets.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with email & password
  Future<UserAccountModel?> signIn(String email, String password) async {
    try {
      // 1. Sign in
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        debugPrint('Sign in failed: no user returned');
        return null;
      }

      final userId = response.user!.id;

      // 2. Fetch user data from `users` table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserAccountModel.fromJson(userData);
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign up with email, password, and full name
  /// Also inserts into `public.users` table
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create the user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // 2. Insert into `public.users` table
        await _supabase.from('users').upsert({
          'id': userId,
          'email': email,
          'role': 'user',
          'name': fullName,
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
