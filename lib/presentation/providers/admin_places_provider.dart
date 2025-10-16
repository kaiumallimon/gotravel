import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/services/remote/place_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AdminPlacesProvider with ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  final Uuid _uuid = Uuid();
  
  List<PlaceModel> _places = [];
  List<PlaceModel> _filteredPlaces = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = '';

  // Image handling
  XFile? _coverImage;
  List<XFile> _additionalImages = [];
  
  // JSON import
  final TextEditingController jsonController = TextEditingController();

  List<PlaceModel> get places => _places;
  List<PlaceModel> get filteredPlaces => _filteredPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  XFile? get coverImage => _coverImage;
  List<XFile> get additionalImages => _additionalImages;

  set coverImage(XFile? image) {
    _coverImage = image;
    notifyListeners();
  }

  set additionalImages(List<XFile> images) {
    _additionalImages = images;
    notifyListeners();
  }

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await _placeService.getAllPlaces();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPlaces(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPlaces = _places.where((place) {
      final matchesSearch = _searchQuery.isEmpty ||
          place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          place.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (place.city?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (place.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCategory = _selectedCategory.isEmpty ||
          place.category?.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by name
    _filteredPlaces.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<bool> addPlace(PlaceModel place) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload cover image if selected
      String coverImageUrl = place.coverImage;
      if (_coverImage != null) {
        coverImageUrl = await _uploadImage(_coverImage!);
      }

      // Upload additional images if selected
      List<String> imageUrls = [...place.images];
      if (_additionalImages.isNotEmpty) {
        for (final image in _additionalImages) {
          final imageUrl = await _uploadImage(image);
          imageUrls.add(imageUrl);
        }
      }

      // Create place with uploaded image URLs
      final updatedPlace = place.copyWith(
        id: _uuid.v4(),
        coverImage: coverImageUrl,
        images: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newPlace = await _placeService.addPlace(updatedPlace);
      _places.add(newPlace);
      _applyFilters();
      
      // Clear images after successful upload
      _clearImages();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlace(PlaceModel place) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload new cover image if selected
      String coverImageUrl = place.coverImage;
      if (_coverImage != null) {
        coverImageUrl = await _uploadImage(_coverImage!);
      }

      // Upload new additional images if selected
      List<String> imageUrls = [...place.images];
      if (_additionalImages.isNotEmpty) {
        for (final image in _additionalImages) {
          final imageUrl = await _uploadImage(image);
          imageUrls.add(imageUrl);
        }
      }

      // Create updated place with new image URLs
      final updatedPlace = place.copyWith(
        coverImage: coverImageUrl,
        images: imageUrls,
        updatedAt: DateTime.now(),
      );

      final resultPlace = await _placeService.updatePlace(updatedPlace);
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = resultPlace;
        _applyFilters();
      }
      
      // Clear images after successful upload
      _clearImages();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlace(String placeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _placeService.deletePlace(placeId);
      _places.removeWhere((place) => place.id == placeId);
      _applyFilters();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Image picking methods
  Future<void> pickCoverImage(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _coverImage = pickedFile;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error picking cover image: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $error')),
        );
      }
    }
  }

  Future<void> pickAdditionalImages(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty) {
        _additionalImages = pickedFiles;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error picking images: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $error')),
        );
      }
    }
  }

  Future<void> removeAdditionalImage(int index) async {
    if (index >= 0 && index < _additionalImages.length) {
      _additionalImages.removeAt(index);
      notifyListeners();
    }
  }

  void _clearImages() {
    _coverImage = null;
    _additionalImages = [];
  }

  // JSON Import functionality
  void importFromJson(BuildContext context) {
    final jsonString = jsonController.text;
    if (jsonString.isEmpty) return;

    try {
      final data = jsonDecode(jsonString);
      
      // Validate required fields
      if (data['name'] == null || data['country'] == null) {
        throw Exception('Missing required fields: name and country are required');
      }

      // Create place from JSON data
      final place = PlaceModel(
        id: _uuid.v4(),
        name: data['name'] ?? '',
        description: data['description'],
        country: data['country'] ?? '',
        stateProvince: data['state_province'],
        city: data['city'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        category: data['category'],
        popularRanking: data['popular_ranking'] ?? 0,
        visitCount: data['visit_count'] ?? 0,
        rating: (data['rating'] ?? 0.0).toDouble(),
        reviewsCount: data['reviews_count'] ?? 0,
        coverImage: data['cover_image'] ?? '',
        images: List<String>.from(data['images'] ?? []),
        bestTimeToVisit: data['best_time_to_visit'],
        averageTemperature: data['average_temperature'],
        currency: data['currency'] ?? 'USD',
        localLanguage: data['local_language'],
        timeZone: data['time_zone'],
        famousFor: List<String>.from(data['famous_for'] ?? []),
        activities: List<String>.from(data['activities'] ?? []),
        isFeatured: data['is_featured'] ?? false,
        isActive: data['is_active'] ?? true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add the place
      addPlace(place);

      // Clear JSON controller
      jsonController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Place imported successfully from JSON'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing JSON: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _uploadImage(XFile image) async {
    try {
      // Generate unique filename
      final fileName = '${_uuid.v4()}_${image.name}';
      
      // Use the same image upload service as packages
      final imageService = _placeService;
      return await imageService.uploadImage(image.path, fileName);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics methods
  Map<String, int> getPlaceStats() {
    final stats = <String, int>{};
    
    // Count by category
    for (final place in _places) {
      final category = place.category ?? 'Unknown';
      stats[category] = (stats[category] ?? 0) + 1;
    }
    
    return stats;
  }

  double getAverageRating() {
    if (_places.isEmpty) return 0.0;
    
    final totalRating = _places.fold<double>(0.0, (sum, place) => sum + place.rating);
    return totalRating / _places.length;
  }

  int getTotalPlaces() => _places.length;
}