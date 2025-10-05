import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/services/remote/admin_hotel_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminHotelsProvider extends ChangeNotifier {
  List<Hotel> _hotels = [];
  List<Hotel> get hotels => _hotels;
  set hotels(List<Hotel> value) {
    _hotels = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() {
    _hotels = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHotels(BuildContext context) async {
    isLoading = true;

    try {
      final response = await AdminHotelService().fetchHotels();
      log('Fetched ${response.length} hotels');
      if (response.isNotEmpty) {
        log('First hotel: ${response.first.name}');
        log('First hotel rooms count: ${response.first.rooms.length}');
        if (response.first.rooms.isNotEmpty) {
          log('First room: ${response.first.rooms.first.toMap()}');
        }
      }
      hotels = response;
    } catch (error) {
      isLoading = false;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Failed to load hotels: $error',
      );
    } finally {
      isLoading = false;
    }
  }
}
