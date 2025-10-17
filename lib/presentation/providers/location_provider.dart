import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotravel/data/services/local/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  String _currentAddress = 'Getting location...';
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get the user's current location and address
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current position
      final position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        _currentPosition = position;
        
        // Get address from coordinates
        final address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );
        
        _currentAddress = _formatAddress(address);
      } else {
        _currentAddress = 'Location unavailable';
        _error = 'Could not get location';
      }
    } catch (e) {
      _error = e.toString();
      _currentAddress = 'Location unavailable';
      
      // Handle specific error messages
      if (e.toString().contains('disabled')) {
        _currentAddress = 'Enable location services';
      } else if (e.toString().contains('denied')) {
        _currentAddress = 'Location permission denied';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Format the address to be more concise for display
  String _formatAddress(String fullAddress) {
    try {
      // Try to extract city and country
      final parts = fullAddress.split(',');
      if (parts.length >= 2) {
        // Get the last two parts (usually city and country)
        final city = parts[parts.length - 3].trim();
        final country = parts[parts.length - 1].trim();
        return '$city, $country';
      }
      return fullAddress;
    } catch (e) {
      return fullAddress;
    }
  }

  /// Reset location data
  void reset() {
    _currentPosition = null;
    _currentAddress = 'Getting location...';
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Set a manual location (for testing or user selection)
  void setManualLocation(String address) {
    _currentAddress = address;
    notifyListeners();
  }
}
