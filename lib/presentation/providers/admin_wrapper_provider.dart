import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/data/services/local/hive_service.dart';

class AdminWrapperProvider extends ChangeNotifier {
  UserAccountModel? _accountData;

  UserAccountModel? get accountData => _accountData;

  AdminWrapperProvider() {
    loadAccountData(); // auto load
  }

  void loadAccountData() {
    final userData = HiveService.getData(
      'user',
      'accountData',
      defaultValue: null,
    );
    _accountData = userData == null
        ? null
        : UserAccountModel.fromJson(userData);
    notifyListeners();
    print("Admin Account data loaded");
  }

  final List<Map<String, dynamic>> tabs = [
    {"title": "Home", "child": Container(color: Colors.blue)},
    {"title": "Packages", "child": Container(color: Colors.green)},
    {"title": "Flights", "child": Container(color: Colors.orange)},
    {"title": "Places", "child": Container(color: Colors.yellow)},
    {"title": "Hotels", "child": Container(color: Colors.red)},
  ];
}
