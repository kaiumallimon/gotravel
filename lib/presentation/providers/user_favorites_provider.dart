import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_favorite_model.dart';
import 'package:gotravel/data/services/remote/user_favorites_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserFavoritesProvider with ChangeNotifier {
  final UserFavoritesService _favoritesService = UserFavoritesService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<UserFavoriteModel> _favorites = [];
  List<Map<String, dynamic>> _favoritePackages = [];
  List<Map<String, dynamic>> _favoriteHotels = [];
  List<Map<String, dynamic>> _favoritePlaces = [];
  Map<String, int> _favoriteCounts = {};

  // Cache for favorite status checks
  final Map<String, bool> _favoriteStatusCache = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserFavoriteModel> get favorites => _favorites;
  List<Map<String, dynamic>> get favoritePackages => _favoritePackages;
  List<Map<String, dynamic>> get favoriteHotels => _favoriteHotels;
  List<Map<String, dynamic>> get favoritePlaces => _favoritePlaces;
  Map<String, int> get favoriteCounts => _favoriteCounts;

  // Calculated getters
  int get totalFavorites => _favorites.length;
  int get favoritePackagesCount => _favoriteCounts['packages'] ?? 0;
  int get favoriteHotelsCount => _favoriteCounts['hotels'] ?? 0;
  int get favoritePlacesCount => _favoriteCounts['places'] ?? 0;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load all user favorites
  Future<void> loadUserFavorites({FavoriteItemType? itemType}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    _setError(null);

    try {
      _favorites = await _favoritesService.getUserFavorites(user.id, itemType: itemType);
      
      // Update cache
      _updateFavoriteCache();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load favorite packages with details
  Future<void> loadFavoritePackages() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      _favoritePackages = await _favoritesService.getFavoritePackages(user.id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load favorite hotels with details
  Future<void> loadFavoriteHotels() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      _favoriteHotels = await _favoritesService.getFavoriteHotels(user.id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load favorite places with details
  Future<void> loadFavoritePlaces() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      _favoritePlaces = await _favoritesService.getFavoritePlaces(user.id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load favorite counts
  Future<void> loadFavoriteCounts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      _favoriteCounts = await _favoritesService.getFavoriteCounts(user.id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Add to favorites
  Future<bool> addToFavorites({
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    try {
      final favorite = await _favoritesService.addToFavorites(
        userId: user.id,
        itemType: itemType,
        itemId: itemId,
      );

      // Add to local list
      _favorites.add(favorite);
      
      // Update cache
      final cacheKey = '${itemType.value}:$itemId';
      _favoriteStatusCache[cacheKey] = true;
      
      // Update counts
      await loadFavoriteCounts();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites({
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    try {
      await _favoritesService.removeFromFavorites(
        userId: user.id,
        itemType: itemType,
        itemId: itemId,
      );

      // Remove from local list
      _favorites.removeWhere((f) => f.itemType == itemType && f.itemId == itemId);
      
      // Update cache
      final cacheKey = '${itemType.value}:$itemId';
      _favoriteStatusCache[cacheKey] = false;
      
      // Update counts
      await loadFavoriteCounts();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite({
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    try {
      final isFavorited = await _favoritesService.toggleFavorite(
        userId: user.id,
        itemType: itemType,
        itemId: itemId,
      );

      // Update local data based on result
      if (isFavorited) {
        // Item was added to favorites
        final cacheKey = '${itemType.value}:$itemId';
        _favoriteStatusCache[cacheKey] = true;
      } else {
        // Item was removed from favorites
        _favorites.removeWhere((f) => f.itemType == itemType && f.itemId == itemId);
        final cacheKey = '${itemType.value}:$itemId';
        _favoriteStatusCache[cacheKey] = false;
      }

      // Update counts
      await loadFavoriteCounts();
      
      notifyListeners();
      return isFavorited;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Check if item is favorited
  Future<bool> isFavorited({
    required FavoriteItemType itemType,
    required String itemId,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final cacheKey = '${itemType.value}:$itemId';
    
    // Check cache first
    if (_favoriteStatusCache.containsKey(cacheKey)) {
      return _favoriteStatusCache[cacheKey]!;
    }

    try {
      final isFav = await _favoritesService.isFavorited(
        userId: user.id,
        itemType: itemType,
        itemId: itemId,
      );

      // Update cache
      _favoriteStatusCache[cacheKey] = isFav;
      
      return isFav;
    } catch (e) {
      return false;
    }
  }

  // Check if item is favorited (synchronous from cache)
  bool isFavoritedFromCache({
    required FavoriteItemType itemType,
    required String itemId,
  }) {
    final cacheKey = '${itemType.value}:$itemId';
    return _favoriteStatusCache[cacheKey] ?? false;
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _favoritesService.clearAllFavorites(user.id);
      
      // Clear local data
      _favorites.clear();
      _favoritePackages.clear();
      _favoriteHotels.clear();
      _favoritePlaces.clear();
      _favoriteCounts.clear();
      _favoriteStatusCache.clear();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update favorite cache from loaded favorites
  void _updateFavoriteCache() {
    _favoriteStatusCache.clear();
    for (final favorite in _favorites) {
      final cacheKey = '${favorite.itemType.value}:${favorite.itemId}';
      _favoriteStatusCache[cacheKey] = true;
    }
  }

  // Refresh all favorite data
  Future<void> refresh() async {
    await Future.wait([
      loadUserFavorites(),
      loadFavoritePackages(),
      loadFavoriteHotels(),
      loadFavoritePlaces(),
      loadFavoriteCounts(),
    ]);
  }

  // Initialize favorites provider
  Future<void> initialize() async {
    await Future.wait([
      loadUserFavorites(),
      loadFavoriteCounts(),
    ]);
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    super.dispose();
  }
}