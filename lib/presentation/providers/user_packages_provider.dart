import 'package:flutter/material.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/user_packages_service.dart';

class UserPackagesProvider extends ChangeNotifier {
  final UserPackagesService _service = UserPackagesService();

  List<TourPackage> _allPackages = [];
  List<TourPackage> _packages = [];
  List<String> _countries = [];
  List<String> _categories = [];
  TourPackage? _selectedPackage;
  bool _isLoading = false;
  String? _error;
  String _selectedCountry = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'latest'; // latest, name, price-low, price-high, rating

  List<TourPackage> get packages => _packages;
  List<String> get countries => ['All', ..._countries];
  List<String> get categories => ['All', ..._categories];
  TourPackage? get selectedPackage => _selectedPackage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCountry => _selectedCountry;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  int get totalPackagesCount => _allPackages.length;
  int get filteredPackagesCount => _packages.length;

  Future<void> loadPackages(BuildContext context) async {
    // Schedule the initial state change after the current frame
    Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      // Load packages and filters in parallel
      final results = await Future.wait([
        _service.fetchActivePackages(),
        _service.getAvailableCountries(),
        _service.getAvailableCategories(),
      ]);

      _allPackages = results[0] as List<TourPackage>;
      _countries = results[1] as List<String>;
      _categories = results[2] as List<String>;

      _applyFiltersAndSort();
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
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    // Start with all packages
    List<TourPackage> filtered = List.from(_allPackages);

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((package) =>
        package.name.toLowerCase().contains(lowercaseQuery) ||
        package.destination.toLowerCase().contains(lowercaseQuery) ||
        package.country.toLowerCase().contains(lowercaseQuery) ||
        package.category.toLowerCase().contains(lowercaseQuery) ||
        package.description.toLowerCase().contains(lowercaseQuery)
      ).toList();
    }

    // Apply country filter
    if (_selectedCountry != 'All') {
      filtered = filtered.where((package) => 
        package.country.toLowerCase() == _selectedCountry.toLowerCase()
      ).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((package) => 
        package.category.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'price-low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'latest':
      default:
        // Already sorted by created_at from service
        break;
    }

    _packages = filtered;
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
    _searchQuery = '';
    _sortBy = 'latest';
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> loadPackageDetails(String packageId) async {
    // Schedule the initial state change after the current frame
    Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      _selectedPackage = await _service.getPackageById(packageId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedPackage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}