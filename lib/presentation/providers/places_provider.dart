import 'package:flutter/material.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/services/remote/place_service.dart';

class PlacesProvider with ChangeNotifier {
  final PlaceService _placeService = PlaceService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<PlaceModel> _places = [];
  List<PlaceModel> _featuredPlaces = [];
  List<PlaceModel> _popularPlaces = [];
  List<String> _categories = [];
  List<String> _countries = [];
  PlaceModel? _selectedPlace;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PlaceModel> get places => _places;
  List<PlaceModel> get featuredPlaces => _featuredPlaces;
  List<PlaceModel> get popularPlaces => _popularPlaces;
  List<String> get categories => _categories;
  List<String> get countries => _countries;
  PlaceModel? get selectedPlace => _selectedPlace;
  
  // Get latest places (limit 5)
  List<PlaceModel> get latestPlaces {
    final sorted = List<PlaceModel>.from(_places);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }
  
  // Get total places count
  int get totalPlaces => _places.length;

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

  // Load all places
  Future<void> loadPlaces() async {
    _setLoading(true);
    _setError(null);

    try {
      _places = await _placeService.fetchActivePlaces();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load featured places
  Future<void> loadFeaturedPlaces({int limit = 10}) async {
    try {
      _featuredPlaces = await _placeService.fetchFeaturedPlaces(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load popular places
  Future<void> loadPopularPlaces({int limit = 20}) async {
    try {
      _popularPlaces = await _placeService.fetchPopularPlaces(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load place categories
  Future<void> loadCategories() async {
    try {
      _categories = await _placeService.getPlaceCategories();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load place countries
  Future<void> loadCountries() async {
    try {
      _countries = await _placeService.getPlaceCountries();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load places by category
  Future<void> loadPlacesByCategory(String category) async {
    _setLoading(true);
    _setError(null);

    try {
      _places = await _placeService.fetchPlacesByCategory(category);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load places by country
  Future<void> loadPlacesByCountry(String country) async {
    _setLoading(true);
    _setError(null);

    try {
      _places = await _placeService.fetchPlacesByCountry(country);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search places
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      await loadPlaces();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _places = await _placeService.searchPlaces(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Filter places
  Future<void> filterPlaces({
    String? query,
    String? country,
    String? category,
    double? minRating,
    List<String>? activities,
    String sortBy = 'popular_ranking',
    bool ascending = false,
    int limit = 50,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _places = await _placeService.filterPlaces(
        query: query,
        country: country,
        category: category,
        minRating: minRating,
        activities: activities,
        sortBy: sortBy,
        ascending: ascending,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load place details
  Future<void> loadPlaceDetails(String placeId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedPlace = await _placeService.fetchPlaceById(placeId);
      if (_selectedPlace != null) {
        // Increment visit count
        await _placeService.incrementVisitCount(placeId);
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Set selected place
  void setSelectedPlace(PlaceModel? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  // Clear selected place
  void clearSelectedPlace() {
    _selectedPlace = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadPlaces(),
      loadFeaturedPlaces(),
      loadPopularPlaces(),
      loadCategories(),
      loadCountries(),
    ]);
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadPlaces(),
      loadFeaturedPlaces(limit: 5),
      loadPopularPlaces(),
      loadCategories(),
      loadCountries(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}