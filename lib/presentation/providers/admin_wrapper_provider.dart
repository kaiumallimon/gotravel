import 'package:flutter/material.dart';
import 'package:gotravel/data/models/user_account.dart';
import 'package:gotravel/data/services/local/hive_service.dart';
import 'package:gotravel/presentation/views/admin/hotels/pages/hotels_page.dart';
import 'package:gotravel/presentation/views/admin/packages/pages/packages_page.dart';
import 'package:gotravel/presentation/views/admin/places/pages/places_page.dart';
import 'package:gotravel/presentation/views/admin/recommendations/pages/admin_recommendations_page.dart';
import 'package:gotravel/presentation/views/admin/users/pages/admin_manage_users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gotravel/presentation/views/admin/home/tabs/admin_home_tab.dart';

class AdminWrapperProvider extends ChangeNotifier {
  UserAccountModel? _accountData;
  TabController? _tabController;

  UserAccountModel? get accountData => _accountData;
  TabController? get tabController => _tabController;

  AdminWrapperProvider() {
    loadAccountData(); // auto load
  }

  void setTabController(TabController controller) {
    _tabController = controller;
    // No need to call notifyListeners() here as this is just setting up the controller
  }

  void switchToTab(int index) {
    if (_tabController != null && index >= 0 && index < tabs.length) {
      _tabController!.animateTo(index);
    }
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
    {"title": "Home", "child": const AdminHomeTab()},
    {"title": "Packages", "child": AdminPackagesPage()},
    {"title": "Places", "child": AdminPlacesPage()},
    {"title": "Hotels", "child": AdminHotelsPage()},
    {"title": "Users", "child": AdminManageUsers()},
    {"title": "Recommendations", "child": AdminRecommendationsPage()},
  ];

  Future<Map<String, int>> fetchOverallStats() async {
    try {
      final supabase = Supabase.instance.client;
      final results = await Future.wait([
        supabase.from('packages').select('id'),
        supabase.from('places').select('id'),
        supabase.from('hotels').select('id'),
        supabase.from('users').select('id'),
        supabase.from('recommendations').select('item_id').eq('item_type', 'package'),
        supabase.from('recommendations').select('item_id').eq('item_type', 'hotel'),
      ]);
      return {
        'packages': (results[0] as List).length,
        'places': (results[1] as List).length,
        'hotels': (results[2] as List).length,
        'users': (results[3] as List).length,
        'recommendedPackages': (results[4] as List).length,
        'recommendedHotels': (results[5] as List).length,
      };
    } catch (e) {
      return {
        'packages': 0,
        'places': 0,
        'hotels': 0,
        'users': 0,
        'recommendedPackages': 0,
        'recommendedHotels': 0,
      };
    }
  }
}
