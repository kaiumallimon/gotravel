import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/services/remote/user_hotels_service.dart';

class UserHotelsProvider with ChangeNotifier {
  final UserHotelsService _service = UserHotelsService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<Hotel> _allHotels = [];
  List<Hotel> _recommendedHotels = [];
  List<String> _cities = [];
  List<String> _countries = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Hotel> get hotels => _allHotels;
  List<Hotel> get recommendedHotels => _recommendedHotels;
  List<String> get cities => _cities;
  List<String> get countries => _countries;
  
  // Get latest hotels (limit 5)
  List<Hotel> get latestHotels {
    return _allHotels.take(5).toList();
  }
  
  // Get featured hotels (top 5 rated)
  List<Hotel> get featuredHotels {
    final sorted = List<Hotel>.from(_allHotels);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }
  
  // Get total hotels count
  int get totalHotels => _allHotels.length;

  // Initialize provider
  Future<void> initialize() async {
    Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final results = await Future.wait([
        _service.fetchActiveHotels(),
        _service.getRecommendedHotels(limit: 10),
        _service.getAvailableCities(),
        _service.getAvailableCountries(),
      ]);

      _allHotels = results[0] as List<Hotel>;
      _recommendedHotels = results[1] as List<Hotel>;
      _cities = results[2] as List<String>;
      _countries = results[3] as List<String>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
