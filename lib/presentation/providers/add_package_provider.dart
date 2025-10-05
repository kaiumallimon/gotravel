import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gotravel/data/services/remote/add_package_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:uuid/uuid.dart';

class AddPackageProvider extends ChangeNotifier {
  final uuid = Uuid();

  // Package controllers
  final TextEditingController packageNameController = TextEditingController();
  final TextEditingController packageDescriptionController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController maxParticipantsController = TextEditingController();
  final TextEditingController availableSlotsController = TextEditingController();
  final TextEditingController difficultyLevelController = TextEditingController();
  final TextEditingController minimumAgeController = TextEditingController();
  final TextEditingController includedServicesController = TextEditingController();
  final TextEditingController excludedServicesController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController jsonController = TextEditingController();

  // Dynamic activities
  final List<Map<String, TextEditingController>> activityControllers = [];

  // Dynamic package dates
  final List<Map<String, TextEditingController>> packageDateControllers = [];

  XFile? _coverImage;
  XFile? get coverImage => _coverImage;
  set coverImage(XFile? image) {
    _coverImage = image;
    notifyListeners();
  }

  List<XFile> _images = [];
  List<XFile> get images => _images;
  set images(List<XFile> imgs) {
    _images = imgs;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Add a new activity controller set
  void addActivity() {
    activityControllers.add({
      "dayNumber": TextEditingController(),
      "activityName": TextEditingController(),
      "description": TextEditingController(),
      "location": TextEditingController(),
      "startTime": TextEditingController(),
      "endTime": TextEditingController(),
      "activityType": TextEditingController(),
      "isOptional": TextEditingController(text: "false"),
      "additionalCost": TextEditingController(text: "0"),
    });
    notifyListeners();
  }

  /// Remove an activity
  void removeActivity(int index) {
    if (index >= 0 && index < activityControllers.length) {
      for (var c in activityControllers[index].values) {
        c.dispose();
      }
      activityControllers.removeAt(index);
      notifyListeners();
    }
  }

  /// Add a new package date controller set
  void addPackageDate() {
    packageDateControllers.add({
      "departureDate": TextEditingController(),
      "returnDate": TextEditingController(),
      "availableSlots": TextEditingController(),
      "priceOverride": TextEditingController(),
    });
    notifyListeners();
  }

  /// Remove a package date
  void removePackageDate(int index) {
    if (index >= 0 && index < packageDateControllers.length) {
      for (var c in packageDateControllers[index].values) {
        c.dispose();
      }
      packageDateControllers.removeAt(index);
      notifyListeners();
    }
  }

  /// Input validation
  String? validateInputs() {
    if (packageNameController.text.isEmpty) {
      return "Package name is required.";
    }
    if (packageDescriptionController.text.isEmpty) {
      return "Package description is required.";
    }
    if (destinationController.text.isEmpty) {
      return "Destination is required.";
    }
    if (countryController.text.isEmpty) {
      return "Country is required.";
    }
    if (categoryController.text.isEmpty) {
      return "Category is required.";
    }
    if (durationController.text.isEmpty ||
        int.tryParse(durationController.text) == null) {
      return "Valid duration in days is required.";
    }
    if (priceController.text.isEmpty ||
        double.tryParse(priceController.text) == null) {
      return "Valid price is required.";
    }
    if (currencyController.text.isEmpty) {
      return "Currency is required.";
    }
    if (maxParticipantsController.text.isEmpty ||
        int.tryParse(maxParticipantsController.text) == null) {
      return "Valid max participants count is required.";
    }
    if (availableSlotsController.text.isEmpty ||
        int.tryParse(availableSlotsController.text) == null) {
      return "Valid available slots count is required.";
    }
    if (minimumAgeController.text.isNotEmpty &&
        int.tryParse(minimumAgeController.text) == null) {
      return "Valid minimum age is required.";
    }
    if (contactEmailController.text.isEmpty) {
      return "Contact email is required.";
    }
    if (contactPhoneController.text.isEmpty) {
      return "Contact phone is required.";
    }

    if (coverImage == null) {
      return "Cover image is required.";
    }

    if (images.isEmpty) {
      return "At least one image is required.";
    }

    // Validate activities
    for (var i = 0; i < activityControllers.length; i++) {
      final activity = activityControllers[i];
      if (activity["dayNumber"]?.text.isEmpty == true ||
          int.tryParse(activity["dayNumber"]?.text ?? "") == null) {
        return "Valid day number is required for activity ${i + 1}.";
      }
      if (activity["activityName"]?.text.isEmpty == true) {
        return "Activity name is required for activity ${i + 1}.";
      }
      if (activity["description"]?.text.isEmpty == true) {
        return "Description is required for activity ${i + 1}.";
      }
      if (activity["location"]?.text.isEmpty == true) {
        return "Location is required for activity ${i + 1}.";
      }
      if (activity["activityType"]?.text.isEmpty == true) {
        return "Activity type is required for activity ${i + 1}.";
      }
      if (activity["additionalCost"]?.text.isNotEmpty == true &&
          double.tryParse(activity["additionalCost"]?.text ?? "") == null) {
        return "Valid additional cost is required for activity ${i + 1}.";
      }
    }

    // Validate package dates
    for (var i = 0; i < packageDateControllers.length; i++) {
      final date = packageDateControllers[i];
      if (date["departureDate"]?.text.isEmpty == true) {
        return "Departure date is required for date ${i + 1}.";
      }
      if (date["returnDate"]?.text.isEmpty == true) {
        return "Return date is required for date ${i + 1}.";
      }
      if (date["availableSlots"]?.text.isEmpty == true ||
          int.tryParse(date["availableSlots"]?.text ?? "") == null) {
        return "Valid available slots is required for date ${i + 1}.";
      }
      if (date["priceOverride"]?.text.isNotEmpty == true &&
          double.tryParse(date["priceOverride"]?.text ?? "") == null) {
        return "Valid price override is required for date ${i + 1}.";
      }
    }

    return null; // All inputs are valid
  }

  /// Convert all controllers into a package data map
  Map<String, dynamic> buildPackageData(String coverImageUrl, List<String> imageUrls) {
    final packageId = uuid.v4(); // Generate package ID
    
    return {
      "id": packageId,
      "name": packageNameController.text,
      "description": packageDescriptionController.text,
      "destination": destinationController.text,
      "country": countryController.text,
      "category": categoryController.text,
      "duration_days": int.tryParse(durationController.text) ?? 0,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "currency": currencyController.text,
      "max_participants": int.tryParse(maxParticipantsController.text) ?? 0,
      "available_slots": int.tryParse(availableSlotsController.text) ?? 0,
      "difficulty_level": difficultyLevelController.text.isNotEmpty 
          ? difficultyLevelController.text 
          : null,
      "minimum_age": int.tryParse(minimumAgeController.text) ?? 0,
      "included_services": includedServicesController.text.isEmpty
          ? <String>[]
          : includedServicesController.text.split(',').map((s) => s.trim()).toList(),
      "excluded_services": excludedServicesController.text.isEmpty
          ? <String>[]
          : excludedServicesController.text.split(',').map((s) => s.trim()).toList(),
      "contact_email": contactEmailController.text,
      "contact_phone": contactPhoneController.text,
      "rating": 0.0,
      "reviews_count": 0,
      "cover_image": coverImageUrl,
      "images": imageUrls,
      "is_active": true,
    };
  }

  /// Build activity data list
  List<Map<String, dynamic>> buildActivityData() {
    final activities = <Map<String, dynamic>>[];
    
    for (var activity in activityControllers) {
      activities.add({
        "id": uuid.v4(),
        "day_number": int.tryParse(activity["dayNumber"]?.text ?? "1") ?? 1,
        "activity_name": activity["activityName"]?.text ?? "",
        "description": activity["description"]?.text ?? "",
        "location": activity["location"]?.text ?? "",
        "start_time": activity["startTime"]?.text.isNotEmpty == true 
            ? activity["startTime"]?.text 
            : null,
        "end_time": activity["endTime"]?.text.isNotEmpty == true 
            ? activity["endTime"]?.text 
            : null,
        "activity_type": activity["activityType"]?.text ?? "",
        "is_optional": activity["isOptional"]?.text.toLowerCase() == "true",
        "additional_cost": double.tryParse(activity["additionalCost"]?.text ?? "0") ?? 0.0,
      });
    }
    
    debugPrint('🔍 Built activity data: $activities');
    return activities;
  }

  /// Build package dates data list
  List<Map<String, dynamic>> buildPackageDatesData() {
    final dates = <Map<String, dynamic>>[];
    
    for (var date in packageDateControllers) {
      final priceOverrideText = date["priceOverride"]?.text ?? "";
      dates.add({
        "id": uuid.v4(),
        "departure_date": date["departureDate"]?.text ?? "",
        "return_date": date["returnDate"]?.text ?? "",
        "available_slots": int.tryParse(date["availableSlots"]?.text ?? "0") ?? 0,
        "price_override": priceOverrideText.isEmpty 
            ? null 
            : double.tryParse(priceOverrideText),
        "is_active": true,
      });
    }
    
    debugPrint('🔍 Built package dates data: $dates');
    return dates;
  }

  @override
  void dispose() {
    packageNameController.dispose();
    packageDescriptionController.dispose();
    destinationController.dispose();
    countryController.dispose();
    categoryController.dispose();
    durationController.dispose();
    priceController.dispose();
    currencyController.dispose();
    maxParticipantsController.dispose();
    availableSlotsController.dispose();
    difficultyLevelController.dispose();
    minimumAgeController.dispose();
    includedServicesController.dispose();
    excludedServicesController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    jsonController.dispose();

    for (var activity in activityControllers) {
      for (var c in activity.values) {
        c.dispose();
      }
    }

    for (var date in packageDateControllers) {
      for (var c in date.values) {
        c.dispose();
      }
    }
    
    super.dispose();
  }

  /// Reset function to clear all controllers
  void reset() {
    packageNameController.clear();
    packageDescriptionController.clear();
    destinationController.clear();
    countryController.clear();
    categoryController.clear();
    durationController.clear();
    priceController.clear();
    currencyController.clear();
    maxParticipantsController.clear();
    availableSlotsController.clear();
    difficultyLevelController.clear();
    minimumAgeController.clear();
    includedServicesController.clear();
    excludedServicesController.clear();
    contactEmailController.clear();
    contactPhoneController.clear();
    coverImage = null;
    jsonController.clear();
    images = [];

    for (var activity in activityControllers) {
      for (var c in activity.values) {
        c.dispose();
      }
    }
    activityControllers.clear();

    for (var date in packageDateControllers) {
      for (var c in date.values) {
        c.dispose();
      }
    }
    packageDateControllers.clear();
    
    notifyListeners();
  }

  /// Save package to Supabase
  Future<void> savePackageSupabase(BuildContext context) async {
    isLoading = true;
    try {
      // First, let's test authentication and database access
      debugPrint('🔍 Testing authentication and database access...');
      final service = AddPackageService();
      
      // Get current auth status
      final authStatus = await service.getCurrentAuthStatus();
      debugPrint('🔍 Auth status: $authStatus');
      
      // Test database access
      await service.testDatabaseAccess();
      debugPrint('✅ Database access test passed');

      // Validate inputs
      final validationError = validateInputs();
      if (validationError != null) {
        throw Exception(validationError);
      }

      // Upload cover image
      debugPrint('🔍 Uploading cover image...');
      final coverImageUrl = await service.uploadImage(
        coverImage!.path, 
        coverImage!.name
      );
      debugPrint('✅ Cover image uploaded: $coverImageUrl');

      // Upload additional images
      debugPrint('🔍 Uploading ${images.length} additional images...');
      final imageUrls = <String>[];
      for (int i = 0; i < images.length; i++) {
        final imageUrl = await service.uploadImage(
          images[i].path, 
          images[i].name
        );
        imageUrls.add(imageUrl);
        debugPrint('✅ Image ${i + 1} uploaded: $imageUrl');
      }

      // Build package data
      final packageData = buildPackageData(coverImageUrl, imageUrls);
      final activitiesData = buildActivityData();
      final datesData = buildPackageDatesData();

      // Save to database
      debugPrint('🔍 Saving package to database...');
      await service.addPackage(packageData, activitiesData, datesData);
      debugPrint('✅ Package saved successfully');

      // Show success message
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Package added successfully!",
        );
      }

      // Reset form
      reset();
    } catch (error) {
      debugPrint('❌ Error saving package: $error');
      
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Failed to add package: ${error.toString()}",
        );
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> pickCoverImage(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        coverImage = pickedFile;
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

  Future<void> pickImages(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        images = pickedFiles;
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

  Future<void> removeImage(int index) async {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      notifyListeners();
    }
  }

  /// Import everything from json
  void importFromJson(BuildContext context) {
    final jsonString = jsonController.text;
    if (jsonString.isEmpty) return;

    try {
      final data = jsonDecode(jsonString);
      
      // Import package data
      packageNameController.text = data['name'] ?? '';
      packageDescriptionController.text = data['description'] ?? '';
      destinationController.text = data['destination'] ?? '';
      countryController.text = data['country'] ?? '';
      categoryController.text = data['category'] ?? '';
      durationController.text = (data['duration_days'] ?? 0).toString();
      priceController.text = (data['price'] ?? 0.0).toString();
      currencyController.text = data['currency'] ?? 'USD';
      maxParticipantsController.text = (data['max_participants'] ?? 0).toString();
      availableSlotsController.text = (data['available_slots'] ?? 0).toString();
      difficultyLevelController.text = data['difficulty_level'] ?? '';
      minimumAgeController.text = (data['minimum_age'] ?? 0).toString();
      
      if (data['included_services'] is List) {
        includedServicesController.text = (data['included_services'] as List).join(', ');
      }
      if (data['excluded_services'] is List) {
        excludedServicesController.text = (data['excluded_services'] as List).join(', ');
      }
      
      contactEmailController.text = data['contact_email'] ?? '';
      contactPhoneController.text = data['contact_phone'] ?? '';

      // Import activities
      activityControllers.clear();
      if (data['activities'] is List) {
        for (var activity in data['activities']) {
          addActivity();
          final index = activityControllers.length - 1;
          activityControllers[index]["dayNumber"]?.text = (activity['day_number'] ?? 1).toString();
          activityControllers[index]["activityName"]?.text = activity['activity_name'] ?? '';
          activityControllers[index]["description"]?.text = activity['description'] ?? '';
          activityControllers[index]["location"]?.text = activity['location'] ?? '';
          activityControllers[index]["startTime"]?.text = activity['start_time'] ?? '';
          activityControllers[index]["endTime"]?.text = activity['end_time'] ?? '';
          activityControllers[index]["activityType"]?.text = activity['activity_type'] ?? '';
          activityControllers[index]["isOptional"]?.text = (activity['is_optional'] ?? false).toString();
          activityControllers[index]["additionalCost"]?.text = (activity['additional_cost'] ?? 0.0).toString();
        }
      }

      // Import package dates
      packageDateControllers.clear();
      if (data['package_dates'] is List) {
        for (var date in data['package_dates']) {
          addPackageDate();
          final index = packageDateControllers.length - 1;
          packageDateControllers[index]["departureDate"]?.text = date['departure_date'] ?? '';
          packageDateControllers[index]["returnDate"]?.text = date['return_date'] ?? '';
          packageDateControllers[index]["availableSlots"]?.text = (date['available_slots'] ?? 0).toString();
          packageDateControllers[index]["priceOverride"]?.text = (date['price_override'] ?? '').toString();
        }
      }

      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package data imported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing JSON: $e')),
        );
      }
    }
  }
}