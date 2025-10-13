import 'package:gotravel/data/models/user_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AdminUsersService handles user management operations
/// 
/// For complete user deletion (from both auth and public tables), you need to create
/// a database function in Supabase called 'delete_user_complete':
/// 
/// ```sql
/// CREATE OR REPLACE FUNCTION delete_user_complete(user_id UUID)
/// RETURNS void
/// LANGUAGE plpgsql
/// SECURITY DEFINER
/// AS $$
/// BEGIN
///   -- Delete from auth.users (requires service role)
///   DELETE FROM auth.users WHERE id = user_id;
///   -- The foreign key constraint will cascade delete from public.users
/// END;
/// $$;
/// ```
class AdminUsersService {
	final SupabaseClient _supabase = Supabase.instance.client;

	/// Fetch all users ordered by creation date (newest first)
	Future<List<UserAccountModel>> fetchUsers() async {
		try {
			final response = await _supabase
					.from('users')
					.select('*')
					.order('created_at', ascending: false);

			final List data = response;
			return data
					.map((u) => UserAccountModel.fromJson(u as Map<String, dynamic>))
					.toList();
		} catch (e) {
			throw Exception('Failed to fetch users: $e');
		}
	}

	/// Update a user's role (admin | user | moderator)
	Future<void> updateUserRole({required String userId, required String role}) async {
		try {
			await _supabase.from('users').update({'role': role}).eq('id', userId);
		} catch (e) {
			throw Exception('Failed to update user role: $e');
		}
	}

	/// Delete a user (removes from both public.users table and Supabase Auth)
	Future<void> deleteUser(String userId) async {
		try {
			// Option 1: Try using admin API (requires service role key)
			try {
				await _supabase.auth.admin.deleteUser(userId);
			} catch (adminError) {
				// Option 2: If admin API fails, call a database function that uses service role
				// You'll need to create this function in your Supabase dashboard
				await _supabase.rpc('delete_user_complete', params: {'user_id': userId});
			}
		} catch (e) {
			throw Exception('Failed to delete user: $e');
		}
	}
}

