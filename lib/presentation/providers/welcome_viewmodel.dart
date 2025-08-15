import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/constants/app_data.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/models/welcome_model.dart';
import 'package:gotravel/data/services/local/hive_service.dart';

class WelcomeProvider extends ChangeNotifier {
  /// Welcome data list
  List<WelcomeModel>? _welcomeData;

  /// Loading state
  bool _isLoading = false;

  /// Error state
  String? _error;

  /// Welcome data getter
  List<WelcomeModel>? get welcomeData => _welcomeData;

  /// Loading state getter
  bool get isLoading => _isLoading;

  /// Error state getter
  String? get error => _error;

  /// Set welcome data
  void setWelcomeData(List<WelcomeModel>? welcomeData) {
    if (_welcomeData != welcomeData) {
      _welcomeData = welcomeData;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void setError(String? error) {
    if (_error != error) {
      _error = error;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load welcome data from static data source
  void loadWelcomeData() {
    // Prevent multiple calls
    if (_isLoading || _welcomeData != null) return;

    try {
      setLoading(true);
      final data = AppStaticData.welcomePage
          .map((item) => WelcomeModel.fromJson(item))
          .toList();
      setWelcomeData(data);
    } catch (e) {
      setError('Failed to load welcome data: $e');
    }
  }

  void getStartedOrSkip(BuildContext context) {
    HiveService.saveData('welcome', 'hasSeen', true);
    context.go(AppRoutes.login);
  }
}
