import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/user_hotels_service.dart';
import 'package:gotravel/data/services/remote/user_packages_service.dart';

class UserHomeProvider extends ChangeNotifier {
  final UserPackagesService _packagesService = UserPackagesService();
  final UserHotelsService _hotelsService = UserHotelsService();

  List<TourPackage> _recommendedPackages = [];
  List<TourPackage> _allPackages = [];
  List<TourPackage> _latestPackages = [];
  List<TourPackage> _topPackages = [];
  List<Hotel> _recommendedHotels = [];
  List<String> _countries = [];
  List<String> _categories = [];
  int _totalPackagesCount = 0;
  Map<String, int>? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TourPackage> get recommendedPackages => _recommendedPackages;
  List<TourPackage> get allPackages => _allPackages;
  List<TourPackage> get latestPackages => _latestPackages;
  List<TourPackage> get topPackages => _topPackages;
  List<TourPackage> get packages => _allPackages; // Alias for compatibility
  List<Hotel> get recommendedHotels => _recommendedHotels;
  List<String> get countries => _countries;
  List<String> get categories => _categories;
  int get totalPackagesCount => _totalPackagesCount;
  Map<String, int>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeData(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all home data in parallel
      final results = await Future.wait([
        _packagesService.getRecommendedPackages(limit: 5),
        _packagesService.fetchActivePackages(), // Get latest 5 packages sorted by created_at
        _hotelsService.getRecommendedHotels(limit: 5),
        _packagesService.getAvailableCountries(),
        _packagesService.getAvailableCategories(),
      ]);

      _recommendedPackages = results[0] as List<TourPackage>;
      final allPackagesList = results[1] as List<TourPackage>;

      // Debug logging
      // print('DEBUG: Recommended packages count: ${_recommendedPackages.length}');
      // print('DEBUG: All packages list count: ${allPackagesList.length}');

      // Keep the full active packages list
      _allPackages = allPackagesList;

      // Latest 5 packages (sorted by created_at descending in service)
      _latestPackages = allPackagesList.take(5).toList();

      // Total packages count
      _totalPackagesCount = allPackagesList.length;

      // Compute top packages by rating (descending). If no ratings exist, fall back to latest 5
      final rated = List<TourPackage>.from(allPackagesList.where((p) => p.rating > 0));
      if (rated.isNotEmpty) {
        rated.sort((a, b) => b.rating.compareTo(a.rating));
        _topPackages = rated.take(5).toList();
      } else {
        _topPackages = _latestPackages;
      }
      
      _recommendedHotels = results[2] as List<Hotel>;
      _countries = results[3] as List<String>;
      _categories = results[4] as List<String>;
      
      // Load stats
      _stats = {
        'packages': _totalPackagesCount,
        'recommended_packages': _recommendedPackages.length,
        'hotels': _recommendedHotels.length,
        'countries': _countries.length,
      };

      _error = null;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text('Error loading home data: $_error'),
            backgroundColor: Colors.red,
          ),
          
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(BuildContext context) async {
    await loadHomeData(context);
  }

  // Statistics
  int get totalPackages => _totalPackagesCount;
  int get recommendedPackagesCount => _recommendedPackages.length;
  int get allPackagesCount => _allPackages.length;
  int get latestPackagesCount => _latestPackages.length;
  int get topPackagesCount => _topPackages.length;
  int get totalHotels => _recommendedHotels.length;
  int get totalCountries => _countries.length;
  int get totalCategories => _categories.length;
}