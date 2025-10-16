import 'package:gotravel/data/models/user_favorite_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserFavoritesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add item to favorites
  Future<UserFavoriteModel> addToFavorites({
    required String userId,
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .insert({
        'user_id': userId,
        'item_type': itemType.value,
        'item_id': itemId,
      })
          .select()
          .single();

      return UserFavoriteModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove item from favorites
  Future<void> removeFromFavorites({
    required String userId,
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    try {
      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('item_type', itemType.value)
          .eq('item_id', itemId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Check if item is favorited by user
  Future<bool> isFavorited({
    required String userId,
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('item_type', itemType.value)
          .eq('item_id', itemId)
          .limit(1);

      final List data = response;
      return data.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  /// Get user's favorite items
  Future<List<UserFavoriteModel>> getUserFavorites(String userId, {
    FavoriteItemType? itemType,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('user_favorites')
          .select('*')
          .eq('user_id', userId);

      if (itemType != null) {
        queryBuilder = queryBuilder.eq('item_type', itemType.value);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      final List data = response;
      return data.map((favorite) => UserFavoriteModel.fromMap(favorite)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user favorites: $e');
    }
  }

  /// Get favorite packages with details
  Future<List<Map<String, dynamic>>> getFavoritePackages(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('''
            *,
            packages:item_id (
              *,
              package_activities(*),
              package_dates(*)
            )
          ''')
          .eq('user_id', userId)
          .eq('item_type', 'package')
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite packages: $e');
    }
  }

  /// Get favorite hotels with details
  Future<List<Map<String, dynamic>>> getFavoriteHotels(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('''
            *,
            hotels:item_id (
              *,
              rooms(*)
            )
          ''')
          .eq('user_id', userId)
          .eq('item_type', 'hotel')
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite hotels: $e');
    }
  }

  /// Get favorite places with details
  Future<List<Map<String, dynamic>>> getFavoritePlaces(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('''
            *,
            places:item_id (*)
          ''')
          .eq('user_id', userId)
          .eq('item_type', 'place')
          .order('created_at', ascending: false);

      final List data = response;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite places: $e');
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite({
    required String userId,
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    try {
      final isFav = await isFavorited(
        userId: userId,
        itemType: itemType,
        itemId: itemId,
      );

      if (isFav) {
        await removeFromFavorites(
          userId: userId,
          itemType: itemType,
          itemId: itemId,
        );
        return false;
      } else {
        await addToFavorites(
          userId: userId,
          itemType: itemType,
          itemId: itemId,
        );
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Get favorite counts by type for user
  Future<Map<String, int>> getFavoriteCounts(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorites')
          .select('item_type')
          .eq('user_id', userId);

      final List data = response;
      final counts = <String, int>{};

      for (final item in data) {
        final itemType = item['item_type'] as String;
        counts[itemType] = (counts[itemType] ?? 0) + 1;
      }

      return {
        'packages': counts['package'] ?? 0,
        'hotels': counts['hotel'] ?? 0,
        'places': counts['place'] ?? 0,
        'total': data.length,
      };
    } catch (e) {
      throw Exception('Failed to get favorite counts: $e');
    }
  }

  /// Clear all favorites for user
  Future<void> clearAllFavorites(String userId) async {
    try {
      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  /// Get popular items based on favorite counts
  Future<List<Map<String, dynamic>>> getPopularFavorites(FavoriteItemType itemType, {int limit = 10}) async {
    try {
      final response = await _supabase.rpc('get_popular_favorites', params: {
        'item_type_param': itemType.value,
        'limit_param': limit,
      });

      final List data = response;
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      // If the function doesn't exist, return empty list
      return [];
    }
  }
}