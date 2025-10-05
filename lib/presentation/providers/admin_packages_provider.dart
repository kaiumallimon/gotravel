import 'package:flutter/material.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/admin_package_service.dart';

class AdminPackagesProvider extends ChangeNotifier {
  final AdminPackageService _packageService = AdminPackageService();
  
  List<TourPackage> _packages = [];
  bool _isLoading = false;
  String? _error;

  List<TourPackage> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all packages from the database
  Future<void> loadPackages(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await _packageService.fetchPackages();
      _error = null;
      debugPrint('✅ Loaded ${_packages.length} packages');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading packages: $e');
      
      // Show error to user if context is available
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading packages: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh packages
  Future<void> refreshPackages(BuildContext context) async {
    await loadPackages(context);
  }

  /// Get package by ID
  TourPackage? getPackageById(String id) {
    try {
      return _packages.firstWhere((package) => package.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete a package
  Future<void> deletePackage(String packageId, BuildContext context) async {
    try {
      await _packageService.deletePackage(packageId);
      
      // Remove from local list
      _packages.removeWhere((package) => package.id == packageId);
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting package: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting package: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Toggle package status (active/inactive)
  Future<void> togglePackageStatus(String packageId, BuildContext context) async {
    try {
      final package = getPackageById(packageId);
      if (package == null) return;

      final newStatus = !package.isActive;
      await _packageService.updatePackageStatus(packageId, newStatus);
      
      // Update local list
      final index = _packages.indexWhere((p) => p.id == packageId);
      if (index != -1) {
        // Create a new package with updated status
        final updatedPackage = TourPackage(
          id: package.id,
          name: package.name,
          description: package.description,
          destination: package.destination,
          country: package.country,
          category: package.category,
          durationDays: package.durationDays,
          price: package.price,
          currency: package.currency,
          maxParticipants: package.maxParticipants,
          availableSlots: package.availableSlots,
          difficultyLevel: package.difficultyLevel,
          minimumAge: package.minimumAge,
          includedServices: package.includedServices,
          excludedServices: package.excludedServices,
          itinerary: package.itinerary,
          contactEmail: package.contactEmail,
          contactPhone: package.contactPhone,
          rating: package.rating,
          reviewsCount: package.reviewsCount,
          coverImage: package.coverImage,
          images: package.images,
          isActive: newStatus,
          activities: package.activities,
          packageDates: package.packageDates,
        );
        
        _packages[index] = updatedPackage;
        notifyListeners();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Package ${newStatus ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error toggling package status: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating package status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Search packages
  List<TourPackage> searchPackages(String query) {
    if (query.isEmpty) return _packages;
    
    final lowercaseQuery = query.toLowerCase();
    return _packages.where((package) =>
      package.name.toLowerCase().contains(lowercaseQuery) ||
      package.destination.toLowerCase().contains(lowercaseQuery) ||
      package.country.toLowerCase().contains(lowercaseQuery) ||
      package.category.toLowerCase().contains(lowercaseQuery) ||
      package.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Filter packages by category
  List<TourPackage> getPackagesByCategory(String category) {
    return _packages.where((package) => 
      package.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Get packages by country
  List<TourPackage> getPackagesByCountry(String country) {
    return _packages.where((package) => 
      package.country.toLowerCase() == country.toLowerCase()
    ).toList();
  }

  /// Get active packages only
  List<TourPackage> getActivePackages() {
    return _packages.where((package) => package.isActive).toList();
  }

  /// Clear packages (useful for logout)
  void clearPackages() {
    _packages.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}