import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/services/remote/admin_recommendations_service.dart';

class AdminRecommendationsProvider extends ChangeNotifier {
  final AdminRecommendationsService _service = AdminRecommendationsService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _packagesWithStatus = [];
  List<Map<String, dynamic>> _hotelsWithStatus = [];
  Map<String, int> _stats = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get packagesWithStatus => _packagesWithStatus;
  List<Map<String, dynamic>> get hotelsWithStatus => _hotelsWithStatus;
  Map<String, int> get stats => _stats;

  // Get recommended packages only
  List<TourPackage> get recommendedPackages {
    return _packagesWithStatus
        .where((item) => item['isRecommended'] == true)
        .map((item) => item['package'] as TourPackage)
        .toList();
  }

  // Get recommended hotels only
  List<Hotel> get recommendedHotels {
    return _hotelsWithStatus
        .where((item) => item['isRecommended'] == true)
        .map((item) => item['hotel'] as Hotel)
        .toList();
  }

  // Load all data
  Future<void> loadRecommendationsData() async {
    try {
      _setLoading(true);
      _clearError();

      // Load packages with status
      final packagesData = await _service.getAllPackagesWithStatus();
      _packagesWithStatus = packagesData;

      // Load hotels with status
      final hotelsData = await _service.getAllHotelsWithStatus();
      _hotelsWithStatus = hotelsData;

      // Load stats
      final statsData = await _service.getRecommendationStats();
      _stats = statsData;

      log('Loaded ${_packagesWithStatus.length} packages and ${_hotelsWithStatus.length} hotels');

    } catch (e) {
      log('Error loading recommendations data: $e');
      _setError('Failed to load recommendations data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle package recommendation
  Future<void> togglePackageRecommendation(String packageId, bool isCurrentlyRecommended) async {
    try {
      if (isCurrentlyRecommended) {
        await _service.removePackageRecommendation(packageId);
      } else {
        await _service.addPackageRecommendation(packageId);
      }

      // Update local state
      final index = _packagesWithStatus.indexWhere(
        (item) => (item['package'] as TourPackage).id == packageId
      );

      if (index != -1) {
        _packagesWithStatus[index]['isRecommended'] = !isCurrentlyRecommended;
        _packagesWithStatus[index]['recommendationId'] = isCurrentlyRecommended ? null : 'new';
        
        // Update stats
        if (isCurrentlyRecommended) {
          _stats['packages'] = (_stats['packages'] ?? 1) - 1;
          _stats['total'] = (_stats['total'] ?? 1) - 1;
        } else {
          _stats['packages'] = (_stats['packages'] ?? 0) + 1;
          _stats['total'] = (_stats['total'] ?? 0) + 1;
        }
        
        notifyListeners();
      }

      log('Toggled package recommendation for $packageId');

    } catch (e) {
      log('Error toggling package recommendation: $e');
      _setError('Failed to update package recommendation: $e');
      rethrow;
    }
  }

  // Toggle hotel recommendation
  Future<void> toggleHotelRecommendation(String hotelId, bool isCurrentlyRecommended) async {
    try {
      if (isCurrentlyRecommended) {
        await _service.removeHotelRecommendation(hotelId);
      } else {
        await _service.addHotelRecommendation(hotelId);
      }

      // Update local state
      final index = _hotelsWithStatus.indexWhere(
        (item) => (item['hotel'] as Hotel).id == hotelId
      );

      if (index != -1) {
        _hotelsWithStatus[index]['isRecommended'] = !isCurrentlyRecommended;
        _hotelsWithStatus[index]['recommendationId'] = isCurrentlyRecommended ? null : 'new';
        
        // Update stats
        if (isCurrentlyRecommended) {
          _stats['hotels'] = (_stats['hotels'] ?? 1) - 1;
          _stats['total'] = (_stats['total'] ?? 1) - 1;
        } else {
          _stats['hotels'] = (_stats['hotels'] ?? 0) + 1;
          _stats['total'] = (_stats['total'] ?? 0) + 1;
        }
        
        notifyListeners();
      }

      log('Toggled hotel recommendation for $hotelId');

    } catch (e) {
      log('Error toggling hotel recommendation: $e');
      _setError('Failed to update hotel recommendation: $e');
      rethrow;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadRecommendationsData();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Search packages
  List<Map<String, dynamic>> searchPackages(String query) {
    if (query.isEmpty) return _packagesWithStatus;
    
    return _packagesWithStatus.where((item) {
      final package = item['package'] as TourPackage;
      return package.name.toLowerCase().contains(query.toLowerCase()) ||
             package.description.toLowerCase().contains(query.toLowerCase()) ||
             package.country.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Search hotels
  List<Map<String, dynamic>> searchHotels(String query) {
    if (query.isEmpty) return _hotelsWithStatus;
    
    return _hotelsWithStatus.where((item) {
      final hotel = item['hotel'] as Hotel;
      return hotel.name.toLowerCase().contains(query.toLowerCase()) ||
             hotel.description.toLowerCase().contains(query.toLowerCase()) ||
             hotel.address.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter packages by recommendation status
  List<Map<String, dynamic>> filterPackages(String filter) {
    switch (filter) {
      case 'recommended':
        return _packagesWithStatus.where((item) => item['isRecommended'] == true).toList();
      case 'not_recommended':
        return _packagesWithStatus.where((item) => item['isRecommended'] != true).toList();
      default:
        return _packagesWithStatus;
    }
  }

  // Filter hotels by recommendation status
  List<Map<String, dynamic>> filterHotels(String filter) {
    switch (filter) {
      case 'recommended':
        return _hotelsWithStatus.where((item) => item['isRecommended'] == true).toList();
      case 'not_recommended':
        return _hotelsWithStatus.where((item) => item['isRecommended'] != true).toList();
      default:
        return _hotelsWithStatus;
    }
  }
}