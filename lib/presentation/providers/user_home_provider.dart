import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/user_hotels_service.dart';
import 'package:gotravel/data/services/remote/user_packages_service.dart';

class UserHomeProvider extends ChangeNotifier {
  final UserPackagesService _packagesService = UserPackagesService();
  final UserHotelsService _hotelsService = UserHotelsService();

  List<TourPackage> _recommendedPackages = [];
  List<Hotel> _recommendedHotels = [];
  List<String> _countries = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<TourPackage> get recommendedPackages => _recommendedPackages;
  List<Hotel> get recommendedHotels => _recommendedHotels;
  List<String> get countries => _countries;
  List<String> get categories => _categories;
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
        _hotelsService.getRecommendedHotels(limit: 5),
        _packagesService.getAvailableCountries(),
        _packagesService.getAvailableCategories(),
      ]);

      _recommendedPackages = results[0] as List<TourPackage>;
      _recommendedHotels = results[1] as List<Hotel>;
      _countries = results[2] as List<String>;
      _categories = results[3] as List<String>;

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
  int get totalPackages => _recommendedPackages.length;
  int get totalHotels => _recommendedHotels.length;
  int get totalCountries => _countries.length;
  int get totalCategories => _categories.length;
}