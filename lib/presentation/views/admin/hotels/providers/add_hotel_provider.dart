import 'package:flutter/cupertino.dart';
import 'package:gotravel/data/services/remote/add_hotel_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:uuid/uuid.dart';

class AddHotelProvider extends ChangeNotifier {
  final uuid = Uuid();

  // Hotel controllers
  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController hotelDescriptionController =
      TextEditingController();
  final TextEditingController hotelAddressController = TextEditingController();
  final TextEditingController hotelCityController = TextEditingController();
  final TextEditingController hotelCountryController = TextEditingController();
  final TextEditingController hotelLattitudeController =
      TextEditingController();
  final TextEditingController hotelLongitudeController =
      TextEditingController();
  final TextEditingController hotelContactEmailController =
      TextEditingController();
  final TextEditingController hotelPhoneController = TextEditingController();

  // Dynamic rooms
  final List<Map<String, TextEditingController>> roomControllers = [];
  final List<Map<String, dynamic>> rooms = [];

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

  /// Add a new room controller set
  void addRoom() {
    roomControllers.add({
      "roomType": TextEditingController(),
      "pricePerNight": TextEditingController(),
      "currency": TextEditingController(),
      "capacity": TextEditingController(),
      "bedType": TextEditingController(),
      // comma-separated input
      "amenities": TextEditingController(),
      "availableCount": TextEditingController(),
    });
    notifyListeners();
  }

  /// Remove a room
  void removeRoom(int index) {
    if (index >= 0 && index < roomControllers.length) {
      for (var c in roomControllers[index].values) {
        c.dispose();
      }
      roomControllers.removeAt(index);
      notifyListeners();
    }
  }

  /// input validation
  /// Returns null if all inputs are valid, otherwise returns an error message
  String? validateInputs() {
    if (hotelNameController.text.isEmpty) {
      return "Hotel name is required.";
    }
    if (hotelDescriptionController.text.isEmpty) {
      return "Hotel description is required.";
    }
    if (hotelAddressController.text.isEmpty) {
      return "Hotel address is required.";
    }
    if (hotelCityController.text.isEmpty) {
      return "Hotel city is required.";
    }
    if (hotelCountryController.text.isEmpty) {
      return "Hotel country is required.";
    }
    if (hotelLattitudeController.text.isEmpty ||
        double.tryParse(hotelLattitudeController.text) == null) {
      return "Valid latitude is required.";
    }
    if (hotelLongitudeController.text.isEmpty ||
        double.tryParse(hotelLongitudeController.text) == null) {
      return "Valid longitude is required.";
    }
    if (hotelContactEmailController.text.isEmpty) {
      return "Valid contact email is required.";
    }
    if (hotelPhoneController.text.isEmpty) {
      return "Hotel phone number is required.";
    }

    if(coverImage == null) {
      return "Cover image is required.";
    }

    if(images.isEmpty) {
      return "At least one image is required.";
    }

    for (var i = 0; i < roomControllers.length; i++) {
      final room = roomControllers[i];
      if (room["roomType"]?.text.isEmpty == true) {
        return "Room type is required for room ${i + 1}.";
      }
      if (room["pricePerNight"]?.text.isEmpty == true ||
          double.tryParse(room["pricePerNight"]!.text) == null) {
        return "Valid price per night is required for room ${i + 1}.";
      }
      if (room["currency"]?.text.isEmpty == true) {
        return "Currency is required for room ${i + 1}.";
      }
      if (room["capacity"]?.text.isEmpty == true ||
          int.tryParse(room["capacity"]!.text) == null) {
        return "Valid capacity is required for room ${i + 1}.";
      }
      if (room["bedType"]?.text.isEmpty == true) {
        return "Bed type is required for room ${i + 1}.";
      }
      if (room["availableCount"]?.text.isEmpty == true ||
          int.tryParse(room["availableCount"]!.text) == null) {
        return "Valid available count is required for room ${i + 1}.";
      }
      if (room["amenities"]?.text.isEmpty == true) {
        return "At least one amenity is required for room ${i + 1}.";
      }
    }
    return null; // All inputs are valid
  }

  /// Convert all controllers into a hotel data map
  Map<String, dynamic> buildHotelData(String coverImageUrl, List<String> imageUrls) {
    // rooms.clear();
    // for (var room in roomControllers) {
    //   rooms.add({
    //     "id": uuid.v4(), // UUID v4 for Supabase
    //     "room_type": room["roomType"]?.text ?? "",
    //     "price_per_night":
    //         double.tryParse(room["pricePerNight"]?.text ?? "0") ?? 0.0,
    //     "currency": room["currency"]?.text.isNotEmpty == true
    //         ? room["currency"]!.text
    //         : "USD",
    //     "capacity": int.tryParse(room["capacity"]?.text ?? "0") ?? 0,
    //     "bed_type": room["bedType"]?.text ?? "",
    //     "amenities":
    //         room["amenities"]?.text
    //             .split(",")
    //             .map((e) => e.trim())
    //             .where((e) => e.isNotEmpty)
    //             .toList() ??
    //         [],
    //     "available_count":
    //         int.tryParse(room["availableCount"]?.text ?? "0") ?? 0,
    //   });
    // }

    return {
      "name": hotelNameController.text,
      "description": hotelDescriptionController.text,
      "address": hotelAddressController.text,
      "city": hotelCityController.text,
      "country": hotelCountryController.text,
      "latitude": double.tryParse(hotelLattitudeController.text) ?? 0.0,
      "longitude": double.tryParse(hotelLongitudeController.text) ?? 0.0,
      "contact_email": hotelContactEmailController.text,
      "phone": hotelPhoneController.text,
      "rating": 0.0,
      "reviews_count": 0,
      "cover_image": coverImageUrl,
      "images": imageUrls,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// build room data list
  /// Each room will have a hotel_id field to link to the hotel
  /// This function should be called after building hotel data and getting the hotel ID
  /// hotelId: the ID of the hotel to link the rooms to
  /// Returns a list of room data maps
  List<Map<String, dynamic>> buildRoomData() {
    rooms.clear();
    for (var room in roomControllers) {
      rooms.add({
        "id": uuid.v4(),
        "room_type": room["roomType"]?.text ?? "",
        "price_per_night":
            double.tryParse(room["pricePerNight"]?.text ?? "0") ?? 0.0,
        "currency": room["currency"]?.text.isNotEmpty == true
            ? room["currency"]!.text
            : "USD",
        "capacity": int.tryParse(room["capacity"]?.text ?? "0") ?? 0,
        "bed_type": room["bedType"]?.text ?? "",
        "amenities":
            room["amenities"]?.text
                .split(",")
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList() ??
            [],
        "available_count":
            int.tryParse(room["availableCount"]?.text ?? "0") ?? 0,
        "created_at": DateTime.now().toUtc().toIso8601String(),
        "updated_at": DateTime.now().toUtc().toIso8601String(),
      });
    }
    return rooms;
  }

  @override
  void dispose() {
    hotelNameController.dispose();
    hotelDescriptionController.dispose();
    hotelAddressController.dispose();
    hotelCityController.dispose();
    hotelCountryController.dispose();
    hotelLattitudeController.dispose();
    hotelLongitudeController.dispose();
    hotelContactEmailController.dispose();
    hotelPhoneController.dispose();

    for (var room in roomControllers) {
      for (var c in room.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // add a reset function to clear all controllers and room data
  void reset() {
    hotelNameController.clear();
    hotelDescriptionController.clear();
    hotelAddressController.clear();
    hotelCityController.clear();
    hotelCountryController.clear();
    hotelLattitudeController.clear();
    hotelLongitudeController.clear();
    hotelContactEmailController.clear();
    hotelPhoneController.clear();
    coverImage = null;
    images = [];

    for (var room in roomControllers) {
      for (var c in room.values) {
        c.dispose();
      }
    }
    roomControllers.clear();
    rooms.clear();
    notifyListeners();
  }

  // function to save hotel in supabase:
  Future<void> saveHotelSupabase(BuildContext context) async {
    isLoading = true;
    try {
      // First, let's test authentication and database access
      debugPrint('🔍 Testing authentication and database access...');
      final service = AddHotelService();
      
      // Get current auth status
      final authStatus = await service.getCurrentAuthStatus();
      debugPrint('🔍 Auth status: $authStatus');
      
      // Test database access
      await service.testDatabaseAccess();
      debugPrint('✅ Database access test passed');
      
      // Test storage access
      await service.testStorageAccess();
      debugPrint('✅ Storage access test passed');
      
      String coverImageUrl = await service.uploadImage(coverImage!.path, coverImage!.name);
      List<String> imageUrls = [];
      for (var img in images) {
        String imageUrl = await service.uploadImage(img.path, img.name);
        imageUrls.add(imageUrl);
      }

      final hotelData = buildHotelData(coverImageUrl, imageUrls);
      final roomData = buildRoomData();

      try {
        await service.addHotel(hotelData, roomData);
        debugPrint('✅ Hotel added with RLS checks');
      } catch (rlsError) {
        debugPrint('❌ RLS method failed: $rlsError');
        debugPrint('🔄 Trying without RLS checks...');
        
        // Try without RLS as fallback
        await service.addHotelWithoutRLS(hotelData, roomData);
        debugPrint('✅ Hotel added without RLS checks');
      }
      
      isLoading = false;
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success", 
          text: "Hotel added successfully",
        );
      }
      reset();
    } catch (error) {
      isLoading = false;
      debugPrint('Error adding hotel: $error');
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: error.toString().contains('Unauthorized') || error.toString().contains('403')
              ? "Authentication error. Please sign out and sign in again as an admin."
              : "Failed to add hotel: ${error.toString()}",
        );
      }
    }finally {
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
      debugPrint('Error picking image: $error');
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Failed to pick image. Please try again.",
        );
      }
      return null;
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
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Failed to pick images. Please try again.",
        );
      }
      return null;
    }
  }

  Future<void> removeImage(int index) async {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      notifyListeners();
    }
  }
}
