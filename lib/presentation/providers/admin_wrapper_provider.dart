import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/data/services/local/hive_service.dart';
import 'package:gotravel/presentation/views/admin/hotels/pages/hotels_page.dart';
import 'package:gotravel/presentation/views/admin/packages/pages/packages_page.dart';
import 'package:gotravel/presentation/views/admin/recommendations/pages/admin_recommendations_page.dart';
import 'package:gotravel/presentation/views/admin/users/pages/admin_manage_users.dart';

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
    {"title": "Packages", "child": AdminPackagesPage()},
    {"title": "Hotels", "child": AdminHotelsPage()},
    {"title": "Users", "child": AdminManageUsers()},
    {"title": "Recommendations", "child": AdminRecommendationsPage()},
  ];
}
