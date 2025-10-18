import 'package:flutter/material.dart';
import 'package:gotravel/data/models/search_model.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/services/remote/search_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchProvider with ChangeNotifier {
  final SearchService _searchService = SearchService();

  // State variables
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  SearchFilter _searchFilter = SearchFilter();
  List<SearchHistoryModel> _searchHistory = [];
  List<String> _searchSuggestions = [];
  List<String> _popularQueries = [];

  // Search results
  Map<String, List<dynamic>> _globalResults = {};
  List<PlaceModel> _placeResults = [];
  List<TourPackage> _packageResults = [];
  List<Hotel> _hotelResults = [];

  // Current search context
  String? _currentSearchType;
  SearchHistoryModel? _currentSearch;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  SearchFilter get searchFilter => _searchFilter;
  List<SearchHistoryModel> get searchHistory => _searchHistory;
  List<String> get searchSuggestions => _searchSuggestions;
  List<String> get popularQueries => _popularQueries;
  Map<String, List<dynamic>> get globalResults => _globalResults;
  List<PlaceModel> get placeResults => _placeResults;
  List<TourPackage> get packageResults => _packageResults;
  List<Hotel> get hotelResults => _hotelResults;
  String? get currentSearchType => _currentSearchType;
  SearchHistoryModel? get currentSearch => _currentSearch;

  // Calculated getters
  int get totalResults => _placeResults.length + _packageResults.length + _hotelResults.length;
  bool get hasResults => totalResults > 0;
  bool get hasPlaceResults => _placeResults.isNotEmpty;
  bool get hasPackageResults => _packageResults.isNotEmpty;
  bool get hasHotelResults => _hotelResults.isNotEmpty;

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

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set search filter
  void setSearchFilter(SearchFilter filter) {
    _searchFilter = filter;
    notifyListeners();
  }

  // Update specific filter properties
  void updateDestination(String? destination) {
    _searchFilter = _searchFilter.copyWith(destination: destination);
    notifyListeners();
  }

  void updateCountry(String? country) {
    _searchFilter = _searchFilter.copyWith(country: country);
    notifyListeners();
  }

  void updateCategory(String? category) {
    _searchFilter = _searchFilter.copyWith(category: category);
    notifyListeners();
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    _searchFilter = _searchFilter.copyWith(minPrice: minPrice, maxPrice: maxPrice);
    notifyListeners();
  }

  void updateRating(double? minRating) {
    _searchFilter = _searchFilter.copyWith(minRating: minRating);
    notifyListeners();
  }

  void updateDurationRange(int? minDuration, int? maxDuration) {
    _searchFilter = _searchFilter.copyWith(minDuration: minDuration, maxDuration: maxDuration);
    notifyListeners();
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    _searchFilter = _searchFilter.copyWith(startDate: startDate, endDate: endDate);
    notifyListeners();
  }

  void updateParticipants(int? participants) {
    _searchFilter = _searchFilter.copyWith(participants: participants);
    notifyListeners();
  }

  void updateAmenities(List<String>? amenities) {
    _searchFilter = _searchFilter.copyWith(amenities: amenities);
    notifyListeners();
  }

  void updateSorting(String? sortBy, String? sortOrder) {
    _searchFilter = _searchFilter.copyWith(sortBy: sortBy, sortOrder: sortOrder);
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchFilter = SearchFilter();
    notifyListeners();
  }

  // Perform global search
  Future<void> performGlobalSearch(String query, {SearchFilter? filters}) async {
    if (query.isEmpty) return;

    _setLoading(true);
    _setError(null);
    _searchQuery = query;
    _currentSearchType = 'global';

    if (filters != null) {
      _searchFilter = filters;
    }

    try {
      _globalResults = await _searchService.globalSearch(query, filters: _searchFilter);
      
      // Update individual result lists
      _placeResults = List<PlaceModel>.from(_globalResults['places'] ?? []);
      _packageResults = List<TourPackage>.from(_globalResults['packages'] ?? []);
      _hotelResults = List<Hotel>.from(_globalResults['hotels'] ?? []);

      // Record search history
      await _recordSearch(query, 'global', totalResults);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search places only
  Future<void> searchPlaces(String query, {SearchFilter? filters}) async {
    _setLoading(true);
    _setError(null);
    _searchQuery = query;
    _currentSearchType = 'places';

    if (filters != null) {
      _searchFilter = filters;
    }

    try {
      _placeResults = await _searchService.searchPlaces(query, filters: _searchFilter);
      
      // Clear other results
      _packageResults.clear();
      _hotelResults.clear();
      _globalResults.clear();

      // Record search history
      await _recordSearch(query, 'places', _placeResults.length);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search packages only
  Future<void> searchPackages(String query, {SearchFilter? filters}) async {
    _setLoading(true);
    _setError(null);
    _searchQuery = query;
    _currentSearchType = 'packages';

    if (filters != null) {
      _searchFilter = filters;
    }

    try {
      _packageResults = await _searchService.searchPackages(query, filters: _searchFilter);
      
      // Clear other results
      _placeResults.clear();
      _hotelResults.clear();
      _globalResults.clear();

      // Record search history
      await _recordSearch(query, 'packages', _packageResults.length);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search hotels only
  Future<void> searchHotels(String query, {SearchFilter? filters}) async {
    _setLoading(true);
    _setError(null);
    _searchQuery = query;
    _currentSearchType = 'hotels';

    if (filters != null) {
      _searchFilter = filters;
    }

    try {
      _hotelResults = await _searchService.searchHotels(query, filters: _searchFilter);
      
      // Clear other results
      _placeResults.clear();
      _packageResults.clear();
      _globalResults.clear();

      // Record search history
      await _recordSearch(query, 'hotels', _hotelResults.length);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get search suggestions
  Future<void> getSearchSuggestions(String query) async {
    if (query.isEmpty) {
      _searchSuggestions.clear();
      notifyListeners();
      return;
    }

    try {
      _searchSuggestions = await _searchService.getSearchSuggestions(query);
      notifyListeners();
    } catch (e) {
      // Don't show error for suggestions failure
      _searchSuggestions.clear();
      notifyListeners();
    }
  }

  // Load search history
  Future<void> loadSearchHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      _searchHistory = await _searchService.getUserSearchHistory(user.id);
      notifyListeners();
    } catch (e) {
      // Don't show error for history loading failure
      print('Failed to load search history: $e');
    }
  }

  // Load popular queries
  Future<void> loadPopularQueries() async {
    try {
      _popularQueries = await _searchService.getPopularSearchQueries();
      notifyListeners();
    } catch (e) {
      // Don't show error for popular queries failure
      print('Failed to load popular queries: $e');
    }
  }

  // Record search history
  Future<void> _recordSearch(String query, String searchType, int resultsCount) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    try {
      _currentSearch = await _searchService.recordSearch(
        userId: user?.id,
        searchQuery: query,
        searchType: searchType,
        searchFilters: _searchFilter.isEmpty ? null : _searchFilter,
        resultsCount: resultsCount,
      );
    } catch (e) {
      // Don't throw error for search recording failure
      print('Failed to record search: $e');
    }
  }

  // Track search result click
  Future<void> trackSearchClick(String itemId, String itemType) async {
    if (_currentSearch != null) {
      try {
        await _searchService.updateSearchClick(
          _currentSearch!.id,
          itemId,
          itemType,
        );
      } catch (e) {
        // Don't throw error for click tracking failure
        print('Failed to track search click: $e');
      }
    }
  }

  // Clear search results
  void clearResults() {
    _placeResults.clear();
    _packageResults.clear();
    _hotelResults.clear();
    _globalResults.clear();
    _searchQuery = '';
    _currentSearchType = null;
    _currentSearch = null;
    notifyListeners();
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await _searchService.clearUserSearchHistory(user.id);
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Delete individual search history item
  Future<void> deleteSearchHistoryItem(String searchHistoryId) async {
    try {
      await _searchService.deleteSearchHistoryItem(searchHistoryId);
      _searchHistory.removeWhere((item) => item.id == searchHistoryId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      throw e;
    }
  }

  // Search from history
  Future<void> searchFromHistory(SearchHistoryModel historyItem) async {
    if (historyItem.searchFilters != null) {
      _searchFilter = SearchFilter.fromMap(historyItem.searchFilters!);
    }

    switch (historyItem.searchType) {
      case 'places':
        await searchPlaces(historyItem.searchQuery, filters: _searchFilter);
        break;
      case 'packages':
        await searchPackages(historyItem.searchQuery, filters: _searchFilter);
        break;
      case 'hotels':
        await searchHotels(historyItem.searchQuery, filters: _searchFilter);
        break;
      default:
        await performGlobalSearch(historyItem.searchQuery, filters: _searchFilter);
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Initialize search provider
  Future<void> initialize() async {
    await Future.wait([
      loadSearchHistory(),
      loadPopularQueries(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}