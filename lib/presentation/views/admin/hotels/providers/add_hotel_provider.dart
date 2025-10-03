import 'package:flutter/cupertino.dart';
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
    if (hotelContactEmailController.text.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ).hasMatch(hotelContactEmailController.text)) {
      return "Valid contact email is required.";
    }
    if (hotelPhoneController.text.isEmpty) {
      return "Hotel phone number is required.";
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
    }
    return null; // All inputs are valid
  }

  /// Convert all controllers into a hotel data map
  Map<String, dynamic> buildHotelData() {
    rooms.clear();
    for (var room in roomControllers) {
      rooms.add({
        "id": uuid.v4(), // UUID v4 for Supabase
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
      });
    }

    return {
      "id": uuid.v4(), // UUID v4 for Supabase
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
      "cover_image": "",
      "images": [],
      "rooms": rooms,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    };
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
}
