import 'package:flutter/material.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/user_packages_service.dart';

class UserPackagesProvider extends ChangeNotifier {
  final UserPackagesService _service = UserPackagesService();

  List<TourPackage> _packages = [];
  List<String> _countries = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCountry = 'All';
  String _selectedCategory = 'All';

  List<TourPackage> get packages => _packages;
  List<String> get countries => ['All', ..._countries];
  List<String> get categories => ['All', ..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCountry => _selectedCountry;
  String get selectedCategory => _selectedCategory;

  Future<void> loadPackages(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load packages and filters in parallel
      final results = await Future.wait([
        _service.fetchActivePackages(),
        _service.getAvailableCountries(),
        _service.getAvailableCategories(),
      ]);

      _packages = results[0] as List<TourPackage>;
      _countries = results[1] as List<String>;
      _categories = results[2] as List<String>;

      _error = null;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading packages: $_error'),
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
    await loadPackages(context);
  }

  void setCountryFilter(String country) {
    _selectedCountry = country;
    notifyListeners();
    _applyFilters();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedCountry == 'All' && _selectedCategory == 'All') {
        _packages = await _service.fetchActivePackages();
      } else if (_selectedCountry != 'All' && _selectedCategory == 'All') {
        _packages = await _service.fetchPackagesByCountry(_selectedCountry);
      } else if (_selectedCountry == 'All' && _selectedCategory != 'All') {
        _packages = await _service.fetchPackagesByCategory(_selectedCategory);
      } else {
        // Both filters applied - need to filter locally
        final countryPackages = await _service.fetchPackagesByCountry(_selectedCountry);
        _packages = countryPackages
            .where((package) => package.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TourPackage> searchPackages(String query) {
    if (query.trim().isEmpty) return _packages;
    
    final lowercaseQuery = query.toLowerCase();
    return _packages.where((package) =>
      package.name.toLowerCase().contains(lowercaseQuery) ||
      package.destination.toLowerCase().contains(lowercaseQuery) ||
      package.country.toLowerCase().contains(lowercaseQuery) ||
      package.category.toLowerCase().contains(lowercaseQuery) ||
      package.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  void clearFilters() {
    _selectedCountry = 'All';
    _selectedCategory = 'All';
    notifyListeners();
    _applyFilters();
  }
}